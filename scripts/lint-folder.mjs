#!/usr/bin/env node
// Scans an arbitrary folder for *.abap files and lists skylint issues.
// Usage: node scripts/lint-folder.mjs <folder> [--filter <id>] [--json]
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import {
  Lexer,
  buildStatements,
  enrichStatementsWithAbaplint,
  feedRtti,
  extractAllProcedures,
} from '../test/ast.mjs';
import {
  buildProcedureValue,
  buildProceduresTable,
  buildObjectValue,
  createFakes,
} from '../test/harness.mjs';
import { initRuntime, createLoader } from '../test/run.mjs';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const rootDir = path.resolve(__dirname, '..');
const outDir = path.join(rootDir, 'output');
const projectDir = fs.existsSync(path.join(outDir, 'project')) ? path.join(outDir, 'project') : outDir;

function usage() {
  console.log('Usage: node scripts/lint-folder.mjs <folder> [--filter <id>] [--json]');
}

function parseArgs(argv) {
  const opts = { folder: null, filter: null, json: false };
  for (let i = 0; i < argv.length; i++) {
    const a = argv[i];
    if (a === '--filter' && i + 1 < argv.length) opts.filter = argv[++i];
    else if (a === '--json') opts.json = true;
    else if (a === '--help' || a === '-h') {
      usage();
      process.exit(0);
    } else if (!a.startsWith('-') && !opts.folder) opts.folder = a;
    else {
      console.error(`Unknown argument: ${a}`);
      usage();
      process.exit(2);
    }
  }
  if (!opts.folder) {
    usage();
    process.exit(2);
  }
  return opts;
}

function collectAbapFiles(dir, out = []) {
  for (const entry of fs.readdirSync(dir, { withFileTypes: true })) {
    const full = path.join(dir, entry.name);
    if (entry.isDirectory()) collectAbapFiles(full, out);
    else if (entry.isFile() && entry.name.toLowerCase().endsWith('.abap')) out.push(full);
  }
  return out.sort();
}

function discoverBuiltChecks() {
  if (!fs.existsSync(projectDir)) return [];
  return fs
    .readdirSync(projectDir)
    .filter((f) => /^zcl_skylint_check_\d+\.clas\.mjs$/.test(f))
    .map((f) => f.slice('zcl_skylint_check_'.length, -'.clas.mjs'.length))
    .sort();
}

function objectNameFromFile(file) {
  const base = path.basename(file).toLowerCase().replace(/\.abap$/, '');
  return (base.split('.')[0] || base).toUpperCase() || 'ZSKYLINT_TEST';
}

function strOf(v) {
  try {
    if (v && typeof v.get === 'function') return String(v.get()).trim();
    return String(v ?? '').trim();
  } catch {
    return '';
  }
}

const SEVERITY_BY_VALUE = { 0: 'error', 1: 'warning', 2: 'note' };

async function loadMeta(inst) {
  const info = {};
  try {
    const ref = await inst['if_ci_atc_check$get_meta_data']();
    const meta = ref && typeof ref.get === 'function' ? ref.get() : ref;
    const table = await meta['if_ci_atc_check_meta_data$get_finding_code_infos']();
    const rows = table.array ? table.array() : [];
    for (const r of rows) {
      const g = r.get();
      const sev = strOf(g.severity);
      info[strOf(g.code)] = { severity: SEVERITY_BY_VALUE[sev] || sev, text: strOf(g.text) };
    }
  } catch {}
  return info;
}

function readFindingDetails(g) {
  try {
    const d = g.details;
    const inner = d && typeof d.get === 'function' ? d.get() : d;
    if (inner) return { codes: Array.isArray(inner.codes) ? [...inner.codes] : [] };
  } catch {}
  return { codes: [] };
}

function toProcedures(fullLines, fallbackName) {
  const procs = extractAllProcedures(fullLines);
  if (procs.length > 0) return procs;
  return [
    {
      kind: 'METH',
      name: `${fallbackName}=>MAIN`,
      methodName: 'MAIN',
      mainKind: 'CLAS',
      mainName: fallbackName,
      snippet: fullLines,
      offset: 0,
    },
  ];
}

async function scanFile({ abap, getCheck, checkIds, metaByCheck, file }) {
  const text = fs.readFileSync(file, 'utf8');
  const fullLines = text.split('\n');
  if (fullLines.length > 0 && fullLines[fullLines.length - 1] === '') fullLines.pop();
  if (fullLines.length === 0) return [];
  const fallbackName = objectNameFromFile(file);
  const fullSource = fullLines.join('\n');
  const findings = [];

  for (const proc of toProcedures(fullLines, fallbackName)) {
    if (!proc.snippet || proc.snippet.length === 0) continue;
    const objectName = proc.mainName || fallbackName;
    const methodName = proc.kind === 'METH' ? proc.methodName || '' : '';
    const statements = buildStatements(new Lexer(proc.snippet.join('\n')).run());
    if (statements.length === 0) continue;
    await feedRtti(fullSource, objectName, abap);
    await enrichStatementsWithAbaplint(statements, fullSource, objectName, methodName, proc.offset);

    const procValue = buildProcedureValue(abap, {
      kind: proc.kind,
      name: proc.name,
      mainKind: proc.mainKind,
      mainName: objectName,
      statements,
    });
    const proceduresTable = buildProceduresTable(abap, [procValue]);
    const fakes = createFakes(abap, proceduresTable, objectName);

    for (const checkId of checkIds) {
      const { inst } = await getCheck(checkId);
      await inst['if_ci_atc_check$set_assistant_factory']({ factory: fakes.factory });
      let res;
      try {
        res = await inst['if_ci_atc_check$run']({
          object: buildObjectValue(abap, objectName),
          data_provider: fakes.provider,
        });
      } catch {
        continue;
      }
      const rows = res.array ? res.array() : [];
      for (const r of rows) {
        const g = r.get();
        const pos = g.location.get().position.get();
        const code = strOf(g.code);
        findings.push({
          file,
          line: proc.offset + pos.line.get(),
          column: pos.column.get(),
          check: checkId,
          code,
          severity: (metaByCheck[checkId] && metaByCheck[checkId][code] && metaByCheck[checkId][code].severity) || '',
          text: (metaByCheck[checkId] && metaByCheck[checkId][code] && metaByCheck[checkId][code].text) || '',
          quickfixes: readFindingDetails(g).codes,
        });
      }
    }
  }
  return findings;
}

async function main() {
  const opts = parseArgs(process.argv.slice(2));
  const folder = path.resolve(opts.folder);
  if (!fs.existsSync(folder) || !fs.statSync(folder).isDirectory()) {
    console.error(`Not a directory: ${opts.folder}`);
    process.exit(2);
  }
  if (!fs.existsSync(path.join(outDir, 'init.mjs'))) {
    console.error('Transpiled runtime not found. Run `npm run build` first.');
    process.exit(2);
  }

  let checkIds = discoverBuiltChecks();
  if (opts.filter) checkIds = checkIds.filter((id) => id.includes(opts.filter));
  if (checkIds.length === 0) {
    console.error('No built checks found. Run `npm run build` first.');
    process.exit(2);
  }

  const files = collectAbapFiles(folder);
  const abap = await initRuntime();
  const getCheck = createLoader(abap);
  const metaByCheck = {};
  for (const id of checkIds) {
    const { inst } = await getCheck(id);
    metaByCheck[id] = await loadMeta(inst);
  }

  let all = [];
  for (const file of files) {
    const found = await scanFile({ abap, getCheck, checkIds, metaByCheck, file });
    all = all.concat(found);
  }
  all.sort((a, b) => (a.file < b.file ? -1 : a.file > b.file ? 1 : a.line - b.line || a.column - b.column));

  if (opts.json) {
    console.log(JSON.stringify(all, null, 2));
  } else if (all.length === 0) {
    console.log(`OK: no issues in ${files.length} .abap file(s), ${checkIds.length} check(s).`);
  } else {
    for (const f of all) {
      const sev = f.severity ? f.severity + '/' : '';
      const qf = f.quickfixes.length > 0 ? ` [quickfix: ${f.quickfixes.join(',')}]` : '';
      console.log(`${f.file}:${f.line}:${f.column}: [${sev}${f.code} check_${f.check}] ${f.text}${qf}`);
    }
    console.log(`\n${all.length} issue(s) in ${files.length} .abap file(s), ${checkIds.length} check(s).`);
  }
  process.exit(all.length > 0 ? 1 : 0);
}

main();
