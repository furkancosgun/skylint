#!/usr/bin/env node
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath, pathToFileURL } from 'node:url';
import {
  Lexer,
  buildStatements,
  enrichStatementsWithAbaplint,
  feedRtti,
  extractAllProcedures,
  resolveProcedureForTarget,
} from './ast.mjs';
import {
  buildProcedureValue,
  buildProceduresTable,
  buildObjectValue,
  createFakes,
} from './harness.mjs';
import { validateFix } from './roundtrip.mjs';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const rootDir = path.resolve(__dirname, '..');
const outDir = path.join(rootDir, 'output');
const projectDir = fs.existsSync(path.join(outDir, 'project')) ? path.join(outDir, 'project') : outDir;
const fixturesDir = path.join(rootDir, 'tests', 'fixtures');
const toFileUrl = (p) => pathToFileURL(p).href;

export function loadFixture(id) {
  const dir = path.join(fixturesDir, `check_${id}`);
  const text = fs.readFileSync(path.join(dir, 'source.abap'), 'utf8');
  const lines = text.split('\n');
  if (lines.length > 0 && lines[lines.length - 1] === '') lines.pop();
  const expected = JSON.parse(fs.readFileSync(path.join(dir, 'expected.json'), 'utf8'));
  return { lines, expected };
}

export function discoverChecks() {
  return fs
    .readdirSync(fixturesDir)
    .filter((f) => f.startsWith('check_'))
    .map((f) => f.slice('check_'.length))
    .sort();
}

export async function initRuntime() {
  await import(toFileUrl(path.join(outDir, 'init.mjs')));
  return globalThis.abap;
}

export function createLoader(abap) {
  const cache = new Map();
  return async function getCheck(checkId) {
    if (!cache.has(checkId)) {
      const checkPath = path.join(projectDir, `zcl_skylint_check_${checkId}.clas.mjs`);
      const mod = await import(toFileUrl(checkPath));
      const inst = new mod[`zcl_skylint_check_${checkId}`]();
      await inst.constructor_();
      cache.set(checkId, { inst });
    }
    return cache.get(checkId);
  };
}

function sameCodes(a, b) {
  if (!Array.isArray(a) || !Array.isArray(b)) return false;
  if (a.length !== b.length) return false;
  const sa = [...a].sort();
  const sb = [...b].sort();
  return sa.every((val, idx) => val === sb[idx]);
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

async function runRow({ abap, getCheck, checkId, fullLines, row }) {
  const procedures = extractAllProcedures(fullLines);
  const targetProc = resolveProcedureForTarget(procedures, row.method);

  if (!targetProc || targetProc.snippet.length === 0) {
    return {
      pass: false,
      message: `${checkId}/${row.method}: procedure could not be extracted`,
      findings: [],
    };
  }

  const objectName = targetProc.mainName || 'ZSKYLINT_TEST';
  const fullSource = fullLines.join('\n');
  const snippetSource = targetProc.snippet.join('\n');

  const statements = buildStatements(new Lexer(snippetSource).run());
  await feedRtti(fullSource, objectName, abap);
  const methodName = targetProc.kind === 'METH' ? targetProc.methodName || '' : '';
  await enrichStatementsWithAbaplint(statements, fullSource, objectName, methodName, targetProc.offset);

  const procValue = buildProcedureValue(abap, {
    kind: targetProc.kind,
    name: targetProc.name,
    mainKind: targetProc.mainKind,
    mainName: objectName,
    statements,
  });

  const proceduresTable = buildProceduresTable(abap, [procValue]);
  const fakes = createFakes(abap, proceduresTable, objectName);

  const { inst } = await getCheck(checkId);
  await inst['if_ci_atc_check$set_assistant_factory']({ factory: fakes.factory });
  const res = await inst['if_ci_atc_check$run']({
    object: buildObjectValue(abap, objectName),
    data_provider: fakes.provider,
  });

  const rows = res.array ? res.array() : res.get();
  const findings = rows.map((r) => {
    const g = r.get();
    const pos = g.location.get().position.get();
    const det = readFindingDetails(g);
    return {
      code: g.code.get().trim(),
      line: pos.line.get(),
      column: pos.column.get(),
      quickfixes: det.codes,
      fixes: det.fixes,
    };
  });

  for (const f of findings) {
    for (const fix of f.fixes || []) {
      const errors = await validateFix(
        fullSource,
        fullLines,
        targetProc.offset,
        targetProc.snippet.length,
        statements,
        fix,
      );
      if (errors.length > 0) {
        return {
          pass: false,
          message: `${checkId}/${row.method}: quickfix ${fix.code} breaks syntax: ${errors.join('; ')}`,
          findings,
        };
      }
    }
  }

  if (!row.code) {
    if (findings.length === 0) return { pass: true, findings };
    return {
      pass: false,
      message: `${checkId}/${row.method}: expected 0 findings, got ${JSON.stringify(findings)}`,
      findings,
    };
  }

  const hit = findings.find((f) => f.code === row.code && f.line === row.line && f.column === row.column);
  if (!hit) {
    return {
      pass: false,
      message: `${checkId}/${row.method}: expected ${row.code} at ${row.line}:${row.column}, got ${JSON.stringify(findings)}`,
      findings,
    };
  }

  if (row.quickfixes !== undefined && !sameCodes(hit.quickfixes, row.quickfixes)) {
    return {
      pass: false,
      message: `${checkId}/${row.method}: expected quickfixes ${JSON.stringify(row.quickfixes)}, got ${JSON.stringify(hit.quickfixes)}`,
      findings,
    };
  }

  return { pass: true, findings };
}

async function runCheck({ abap, getCheck, checkId, verbose = false }) {
  const { lines, expected } = loadFixture(checkId);
  const failures = [];
  let passed = 0;

  for (const row of expected) {
    const res = await runRow({ abap, getCheck, checkId, fullLines: lines, row });
    if (res.pass) {
      passed += 1;
      if (verbose) {
        console.log(`  PASS ${checkId}/${row.method}`);
      }
    } else {
      failures.push(res.message);
      if (verbose) {
        console.log(`  FAIL ${res.message}`);
      }
    }
  }

  return { passed, failed: failures.length, failures };
}

async function main() {
  const args = process.argv.slice(2);
  const verbose = args.includes('--verbose') || args.includes('-v');
  const bail = args.includes('--bail');
  const filterArgIdx = args.findIndex((a) => a === '--filter');
  const filter = filterArgIdx >= 0 ? args[filterArgIdx + 1] : null;

  const explicitIds = args.filter((a) => !a.startsWith('-') && a !== filter);

  let targetIds = explicitIds.length > 0 ? explicitIds : discoverChecks();
  if (filter) {
    targetIds = targetIds.filter((id) => id.includes(filter));
  }

  const abap = await initRuntime();
  const getCheck = createLoader(abap);

  let totalPassed = 0;
  let totalFailed = 0;
  const allFailures = [];

  for (const id of targetIds) {
    const padId = id.padStart(3, '0');
    try {
      const result = await runCheck({ abap, getCheck, checkId: padId, verbose });
      totalPassed += result.passed;
      totalFailed += result.failed;
      allFailures.push(...result.failures);

      if (bail && result.failed > 0) {
        break;
      }
    } catch (err) {
      totalFailed += 1;
      allFailures.push(`${padId}: crash - ${err.message}`);
      if (bail) break;
    }
  }

  if (allFailures.length > 0) {
    console.error('\nFAILURES:');
    for (const f of allFailures) {
      console.error(`  - ${f}`);
    }
    console.error(`\n${totalPassed} passed, ${totalFailed} failed (${targetIds.length} checks)`);
    process.exit(1);
  }

  console.log(`\n${totalPassed} passed, 0 failed (${targetIds.length} checks)`);
  process.exit(0);
}

if (process.argv[1] && import.meta.url === pathToFileURL(process.argv[1]).href) {
  main();
}
