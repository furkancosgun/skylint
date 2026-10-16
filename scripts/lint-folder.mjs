#!/usr/bin/env node
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
import { applyFix, syntaxErrors } from '../test/roundtrip.mjs';
import { initRuntime, createLoader } from '../test/run.mjs';
import {
  findConfigFile,
  loadConfig,
  defaultConfigText,
  isEnabled,
  severityOverride,
  matchesExclude,
  SEV_RANK,
} from './config.mjs';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const rootDir = path.resolve(__dirname, '..');
const outDir = path.join(rootDir, 'output');
const projectDir = fs.existsSync(path.join(outDir, 'project')) ? path.join(outDir, 'project') : outDir;

function usage() {
  console.log('Usage: node scripts/lint-folder.mjs <folder> [--filter <id>] [--json] [--sarif] [--config <file>] [--fix] [--dry-run] [-d [file]]');
}

function parseArgs(argv) {
  const opts = { folder: null, filter: null, json: false, sarif: false, config: null, fix: false, dryRun: false, init: null };
  for (let i = 0; i < argv.length; i++) {
    const a = argv[i];
    if (a === '--filter' && i + 1 < argv.length) opts.filter = argv[++i];
    else if (a === '--config' && i + 1 < argv.length) opts.config = argv[++i];
    else if (a === '-d' || a === '--init') {
      if (i + 1 < argv.length && !argv[i + 1].startsWith('-')) opts.init = argv[++i];
      else opts.init = true;
    } else if (a === '--json') opts.json = true;
    else if (a === '--sarif') opts.sarif = true;
    else if (a === '--fix') opts.fix = true;
    else if (a === '--dry-run') opts.dryRun = true;
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

function collectAbapFiles(dir, root, exclude, out = []) {
  for (const entry of fs.readdirSync(dir, { withFileTypes: true })) {
    const full = path.join(dir, entry.name);
    if (entry.isDirectory()) {
      collectAbapFiles(full, root, exclude, out);
    } else if (entry.isFile() && entry.name.toLowerCase().endsWith('.abap')) {
      const rel = path.relative(root, full).split(path.sep).join('/');
      if (!matchesExclude(rel, exclude)) out.push(full);
    }
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
    if (inner) {
      return {
        codes: Array.isArray(inner.codes) ? [...inner.codes] : [],
        fixes: Array.isArray(inner.fixes) ? [...inner.fixes] : [],
      };
    }
  } catch {}
  return { codes: [], fixes: [] };
}

function fixRange(proc, fix) {
  const ctx = fix && fix.context;
  if (!ctx) return null;
  let sf = Number(ctx.statements && ctx.statements.from) || 0;
  let st = Number(ctx.statements && ctx.statements.to) || 0;
  if (sf < 1) return null;
  if (st < sf) st = sf;
  const n = proc.statements.length;
  if (sf > n) return null;
  if (st > n) st = n;
  return {
    startAbs: proc.offset + proc.statements[sf - 1].position.line - 1,
    endAbs: st < n ? proc.offset + proc.statements[st].position.line - 1 : proc.offset + proc.count,
  };
}

function rangesOverlap(a, b) {
  return a.startAbs < b.endAbs && b.startAbs < a.endAbs;
}

async function applyFileFixes(fileCtx, visible) {
  const entries = [];
  for (const proc of fileCtx.procs) {
    for (const p of proc.plans) {
      if (!visible.has(p.finding)) continue;
      const range = fixRange(proc, p.fix);
      if (range) entries.push({ ...range, proc, fix: p.fix, finding: p.finding });
    }
  }
  entries.sort((a, b) => b.startAbs - a.startAbs || b.endAbs - a.endAbs);
  const taken = [];
  const applied = [];
  let lines = [...fileCtx.fullLines];
  for (const e of entries) {
    if (taken.some((r) => rangesOverlap(e, r))) continue;
    const res = applyFix(lines, e.proc.offset, e.proc.count, e.proc.statements, e.fix);
    if (!res.patched) continue;
    lines = res.patched;
    taken.push({ startAbs: e.startAbs, endAbs: e.endAbs });
    applied.push(e);
  }
  if (applied.length === 0) return { applied, lines: null, errors: [] };
  const baseline = await syntaxErrors(fileCtx.fullLines.join('\n'));
  const known = new Set(baseline);
  const fresh = (await syntaxErrors(lines.join('\n'))).filter((x) => !known.has(x));
  if (fresh.length > 0) return { applied: [], lines: null, errors: fresh };
  return { applied, lines, errors: [] };
}

function matchStatementInfo(statements, snippet, line, col) {
  let matchedStmt = null;
  let span = 0;

  for (const st of statements) {
    if (st.position.line === line && st.position.column === col) {
      matchedStmt = st;
      span = 0;
      break;
    }
  }
  if (!matchedStmt) {
    for (const st of statements) {
      for (const t of st.tokens) {
        if (t.position.line === line && t.position.column === col) {
          matchedStmt = st;
          span = t.lexeme.length;
          break;
        }
      }
      if (matchedStmt) break;
    }
  }
  if (!matchedStmt) {
    for (const st of statements) {
      if (st.tokens && st.tokens.length > 0) {
        const firstLine = st.position.line || st.tokens[0].position.line;
        const lastLine = st.tokens[st.tokens.length - 1].position.line;
        if (line >= firstLine && line <= lastLine) {
          matchedStmt = st;
          span = 0;
          break;
        }
      }
    }
  }

  if (!matchedStmt) {
    return { startLine: line, endLine: line, span: 0 };
  }

  const startLine = matchedStmt.position.line || (matchedStmt.tokens && matchedStmt.tokens.length > 0 ? matchedStmt.tokens[0].position.line : line);
  let endLine = startLine;
  if (matchedStmt.tokens && matchedStmt.tokens.length > 0) {
    for (const t of matchedStmt.tokens) {
      if (t.position.line > endLine) endLine = t.position.line;
    }
  }

  if (snippet) {
    let cur = endLine - 1;
    const curLine = snippet[cur] || '';
    if (!/[.,]\s*(?:".*)?$/.test(curLine.trim())) {
      for (let next = cur + 1; next < Math.min(snippet.length, cur + 5); next++) {
        const text = (snippet[next] || '').trim();
        if (text.startsWith('.') || text.startsWith(',')) {
          endLine = next + 1;
          break;
        }
        if (text !== '' && !text.startsWith('"') && !text.startsWith('*')) {
          break;
        }
      }
    }
  }

  return { startLine, endLine, span };
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

async function scanFile({ abap, getCheck, checkIds, metaByCheck, cfg, file }) {
  const text = fs.readFileSync(file, 'utf8');
  const eol = text.includes('\r\n') ? '\r\n' : '\n';
  const fullLines = text.split('\n').map((l) => (l.endsWith('\r') ? l.slice(0, -1) : l));
  if (fullLines.length > 0 && fullLines[fullLines.length - 1] === '') fullLines.pop();
  if (fullLines.length === 0) return { findings: [], ctx: null };
  const fallbackName = objectNameFromFile(file);
  const fullSource = fullLines.join('\n');
  const findings = [];
  const ctx = { file, fullLines, eol, trailingNewline: text.endsWith('\n'), procs: [] };

  for (const proc of toProcedures(fullLines, fallbackName)) {
    if (!proc.snippet || proc.snippet.length === 0) continue;
    const objectName = proc.mainName || fallbackName;
    const methodName = proc.kind === 'METH' ? proc.methodName || '' : '';
    const statements = buildStatements(new Lexer(proc.snippet.join('\n')).run());
    if (statements.length === 0) continue;
    const procCtx = { offset: proc.offset, count: proc.snippet.length, statements, plans: [] };
    ctx.procs.push(procCtx);
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
        const relLine = pos.line.get();
        const col = pos.column.get();
        const meta = (metaByCheck[checkId] && metaByCheck[checkId][code]) || {};
        const det = readFindingDetails(g);
        const info = matchStatementInfo(statements, proc.snippet, relLine, col);
        const finding = {
          file,
          line: proc.offset + relLine,
          startLine: proc.offset + info.startLine,
          endLine: proc.offset + info.endLine,
          column: col,
          span: info.span,
          check: checkId,
          code,
          severity: severityOverride(cfg, checkId) || meta.severity || '',
          text: meta.text || '',
          quickfixes: det.codes,
          fixes: det.fixes.map((fx) => ({ code: fx.code, newCode: fx.newCode || null })),
        };
        findings.push(finding);
        for (const fx of det.fixes) {
          if (fx && fx.context) procCtx.plans.push({ finding, fix: fx });
        }
      }
    }
  }
  return { findings, ctx };
}

const ANSI = {
  reset: '\x1b[0m',
  bold: '\x1b[1m',
  red: '\x1b[31m',
  yellow: '\x1b[33m',
  green: '\x1b[32m',
  blue: '\x1b[34m',
};
const USE_COLOR = Boolean(process.stdout.isTTY) && !process.env.NO_COLOR;

function paint(style, s) {
  return USE_COLOR ? ANSI[style] + s + ANSI.reset : s;
}

function expandTabs(s) {
  let out = '';
  let col = 0;
  for (const ch of s) {
    if (ch === '\t') {
      const n = 4 - (col % 4);
      out += ' '.repeat(n);
      col += n;
    } else {
      out += ch;
      col += 1;
    }
  }
  return out;
}

function renderFinding(f, getLines) {
  const sev = f.severity || 'warning';
  const sevStyle = sev === 'error' ? 'red' : sev === 'note' ? 'green' : 'yellow';
  const lines = [];
  lines.push(`${paint(sevStyle, paint('bold', sev))}: ${f.text || f.code}`);
  lines.push(`${paint('blue', paint('bold', ' -->'))} ${f.file}:${f.line}:${f.column + 1}`);
  const src = getLines(f.file);
  const startLine = f.startLine || f.line;
  const endLine = f.endLine || f.line;
  const maxLine = Math.max(f.line, endLine);
  const w = String(maxLine).length;
  const pad = ' '.repeat(w);

  if (src && startLine <= endLine && src[startLine - 1] !== undefined) {
    lines.push(paint('blue', `${pad} |`));

    if (startLine === endLine) {
      const raw = src[f.line - 1] !== undefined ? src[f.line - 1].replace(/\r$/, '') : '';
      const disp = expandTabs(raw);
      const caret = expandTabs(raw.slice(0, Math.min(f.column, raw.length))).length;
      let len;
      if (f.span > 0) {
        len = Math.max(1, expandTabs(raw.slice(f.column, f.column + f.span)).length);
      } else {
        len = Math.max(1, disp.replace(/\s+$/, '').length - caret);
      }
      lines.push(`${paint('blue', `${String(f.line).padStart(w)} |`)} ${disp}`);
      lines.push(`${paint('blue', `${pad} |`)} ${' '.repeat(caret)}${paint(sevStyle, '^'.repeat(len))}`);
    } else {
      const MAX_LINES = 25;
      if (endLine - startLine + 1 <= MAX_LINES) {
        for (let ln = startLine; ln <= endLine; ln++) {
          const raw = src[ln - 1] !== undefined ? src[ln - 1].replace(/\r$/, '') : '';
          const disp = expandTabs(raw);
          lines.push(`${paint('blue', `${String(ln).padStart(w)} |`)} ${disp}`);
          if (ln === f.line) {
            const caret = expandTabs(raw.slice(0, Math.min(f.column, raw.length))).length;
            let len;
            if (f.span > 0) {
              len = Math.max(1, expandTabs(raw.slice(f.column, f.column + f.span)).length);
            } else {
              len = Math.max(1, disp.replace(/\s+$/, '').length - caret);
            }
            lines.push(`${paint('blue', `${pad} |`)} ${' '.repeat(caret)}${paint(sevStyle, '^'.repeat(len))}`);
          }
        }
      } else {
        for (let ln = startLine; ln <= startLine + 4; ln++) {
          const raw = src[ln - 1] !== undefined ? src[ln - 1].replace(/\r$/, '') : '';
          lines.push(`${paint('blue', `${String(ln).padStart(w)} |`)} ${expandTabs(raw)}`);
        }
        lines.push(paint('blue', `${pad} ...`));
        for (let ln = endLine - 4; ln <= endLine; ln++) {
          const raw = src[ln - 1] !== undefined ? src[ln - 1].replace(/\r$/, '') : '';
          lines.push(`${paint('blue', `${String(ln).padStart(w)} |`)} ${expandTabs(raw)}`);
        }
      }
    }
  }
  const note = `[${f.code} check_${f.check}]`
    + (f.quickfixes.length > 0 ? ` quickfix: ${f.quickfixes.join(',')}` : '');
  lines.push(paint('blue', `${pad} |`));
  lines.push(`  ${paint('bold', '=')} ${paint('bold', 'note:')} ${note}`);
  return lines.join('\n');
}

function generateSarif(all, rootFolder, metaByCheck) {
  const rulesMap = new Map();
  const results = [];

  for (const f of all) {
    const ruleId = `skylint_${f.check}_${f.code}`;
    if (!rulesMap.has(ruleId)) {
      const meta = (metaByCheck[f.check] && metaByCheck[f.check][f.code]) || {};
      rulesMap.set(ruleId, {
        id: ruleId,
        name: `Check${f.check}_${f.code}`,
        shortDescription: {
          text: f.text || meta.text || `Check ${f.check} rule ${f.code}`,
        },
        defaultConfiguration: {
          level: f.severity === 'error' ? 'error' : f.severity === 'note' ? 'note' : 'warning',
        },
        helpUri: 'https://github.com/furkancosgun/skylint',
      });
    }

    const relPath = path.relative(rootFolder, f.file).split(path.sep).join('/');
    const level = f.severity === 'error' ? 'error' : f.severity === 'note' ? 'note' : 'warning';
    const spanLen = f.span > 0 ? f.span : 1;

    const resItem = {
      ruleId,
      level,
      message: {
        text: f.text || f.code,
      },
      locations: [
        {
          physicalLocation: {
            artifactLocation: {
              uri: relPath,
              uriBaseId: '%SRCROOT%',
            },
            region: {
              startLine: f.line,
              startColumn: f.column + 1,
              endLine: f.line,
              endColumn: f.column + 1 + spanLen,
            },
          },
        },
      ],
    };

    if (f.quickfixes && f.quickfixes.length > 0) {
      resItem.properties = {
        quickfixes: f.quickfixes,
      };
    }

    results.push(resItem);
  }

  return {
    $schema: 'https://raw.githubusercontent.com/oasis-tcs/sarif-spec/master/Schemata/sarif-schema-2.1.0.json',
    version: '2.1.0',
    runs: [
      {
        tool: {
          driver: {
            name: 'Skylint',
            version: '1.0.0',
            informationUri: 'https://github.com/furkancosgun/skylint',
            rules: Array.from(rulesMap.values()),
          },
        },
        results,
      },
    ],
  };
}

async function main() {
  const opts = parseArgs(process.argv.slice(2));
  const folder = path.resolve(opts.folder);
  if (!fs.existsSync(folder) || !fs.statSync(folder).isDirectory()) {
    console.error(`Not a directory: ${opts.folder}`);
    process.exit(2);
  }
  if (opts.init) {
    const target = opts.init === true ? path.join(folder, 'skylint.yaml') : path.resolve(opts.init);
    if (fs.existsSync(target)) {
      console.error(`Refusing to overwrite existing file: ${target}`);
      process.exit(2);
    }
    fs.writeFileSync(target, defaultConfigText());
    console.log(`Wrote default config: ${target}`);
    process.exit(0);
  }
  if (!fs.existsSync(path.join(outDir, 'init.mjs'))) {
    console.error('Transpiled runtime not found. Run `npm run build` first.');
    process.exit(2);
  }

  let cfgFile = null;
  try {
    cfgFile = findConfigFile(folder, opts.config);
  } catch (e) {
    console.error(e.message);
    process.exit(2);
  }
  let cfg;
  try {
    cfg = loadConfig(cfgFile);
  } catch (e) {
    console.error(e.message);
    process.exit(2);
  }
  if (cfgFile) console.error(`Using config: ${cfgFile}`);

  let checkIds = discoverBuiltChecks();
  if (opts.filter) checkIds = checkIds.filter((id) => id.includes(opts.filter));
  checkIds = checkIds.filter((id) => {
    if (!isEnabled(cfg, id)) {
      console.error(`note: check_${id} disabled by config`);
      return false;
    }
    return true;
  });
  if (checkIds.length === 0) {
    console.error('No checks selected (none built, or all filtered or disabled).');
    process.exit(2);
  }

  const files = collectAbapFiles(folder, folder, cfg.exclude);
  const abap = await initRuntime();
  const getCheck = createLoader(abap);
  const metaByCheck = {};
  for (const id of checkIds) {
    const { inst } = await getCheck(id);
    metaByCheck[id] = await loadMeta(inst);
  }

  let all = [];
  const ctxByFile = new Map();
  for (const file of files) {
    const { findings, ctx } = await scanFile({ abap, getCheck, checkIds, metaByCheck, cfg, file });
    all = all.concat(findings);
    if (ctx) ctxByFile.set(file, ctx);
  }
  all.sort((a, b) => (a.file < b.file ? -1 : a.file > b.file ? 1 : a.line - b.line || a.column - b.column));
  if (cfg.minSeverity) {
    const maxRank = SEV_RANK[cfg.minSeverity];
    all = all.filter((f) => (SEV_RANK[f.severity] ?? 2) <= maxRank);
  }

  const wantFix = opts.fix || opts.dryRun;
  let fixedCount = 0;
  if (wantFix && all.length > 0) {
    const visible = new Set(all);
    for (const [file, ctx] of ctxByFile) {
      const res = await applyFileFixes(ctx, visible);
      if (res.errors.length > 0) {
        console.error(`note: ${file}: fix reverted, would break syntax: ${res.errors.join('; ')}`);
        continue;
      }
      for (const e of res.applied) {
        e.finding.fixed = true;
        fixedCount += 1;
      }
      if (res.applied.length > 0 && opts.fix && !opts.dryRun) {
        fs.writeFileSync(file, res.lines.join(ctx.eol) + (ctx.trailingNewline ? ctx.eol : ''));
      }
    }
  }
  const remaining = all.filter((f) => !f.fixed);

  if (opts.sarif) {
    console.log(JSON.stringify(generateSarif(all, folder, metaByCheck), null, 2));
  } else if (opts.json) {
    console.log(JSON.stringify(all, null, 2));
  } else if (all.length === 0) {
    console.log(`OK: no issues in ${files.length} .abap file(s), ${checkIds.length} check(s).`);
  } else {
    const cache = new Map();
    for (const [file, ctx] of ctxByFile) cache.set(file, ctx.fullLines);
    const getLines = (file) => {
      if (!cache.has(file)) {
        try {
          cache.set(file, fs.readFileSync(file, 'utf8').split('\n'));
        } catch {
          cache.set(file, null);
        }
      }
      return cache.get(file);
    };
    for (const f of all) {
      if (f.fixed && opts.fix && !opts.dryRun) continue;
      console.log(renderFinding(f, getLines) + '\n');
    }
    if (wantFix) {
      const verb = opts.dryRun ? 'would fix' : 'fixed';
      for (const f of all) {
        if (!f.fixed) continue;
        const qf = f.quickfixes.length > 0 ? ` ${f.quickfixes.join(',')}` : '';
        console.log(`${verb} ${f.file}:${f.line}:${f.column + 1} [${f.code} check_${f.check}]${qf}`);
      }
    }
    const fixInfo = wantFix ? `, ${fixedCount} ${opts.dryRun ? 'would be fixed' : 'fixed'}` : '';
    console.log(`${remaining.length} remaining issue(s)${fixInfo} in ${files.length} .abap file(s), ${checkIds.length} check(s).`);
  }
  process.exit(remaining.length > 0 ? 1 : 0);
}

main();
