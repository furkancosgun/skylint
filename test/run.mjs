#!/usr/bin/env node
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath, pathToFileURL } from 'node:url';
import {
  Lexer,
  buildStatements,
  enrichStatements,
  extractAllProcedures,
  resolveProcedureForTarget,
} from '../lib/core/ast.mjs';
import { feedRtti } from '../lib/rtti-feeder.mjs';
import {
  buildProcedureValue,
  buildProceduresTable,
  buildObjectValue,
  createFakes,
} from '../lib/bridge/abap-fakes.mjs';
import { validateFix, validateFixtureSyntax } from '../lib/roundtrip.mjs';
import { initRuntime, createLoader } from '../lib/bridge/abap-runtime.mjs';
import { RULES, resolveRule } from '../scripts/rules-data.mjs';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const rootDir = path.resolve(__dirname, '..');
const fixturesDir = path.join(rootDir, 'test', 'fixtures');

export function loadFixture(key) {
  const rule = typeof key === 'object' && key !== null ? key : resolveRule(key);
  if (!rule) {
    throw new Error(`Rule not found for key: ${JSON.stringify(key)}`);
  }

  const dir = path.join(fixturesDir, rule.ruleId);
  if (!fs.existsSync(dir)) {
    throw new Error(`Fixture not found for rule: ${rule.ruleId} at ${dir}`);
  }

  const text = fs.readFileSync(path.join(dir, 'source.abap'), 'utf8');
  const lines = text.split('\n');
  if (lines.length > 0 && lines[lines.length - 1] === '') lines.pop();
  const expected = JSON.parse(fs.readFileSync(path.join(dir, 'expected.json'), 'utf8'));
  return { lines, expected };
}

export function discoverChecks() {
  return RULES.map((r) => r.ruleId);
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

const defaultAttributes = new WeakMap();

async function applyAttributes(inst, overrides) {
  const metaData = await inst['if_ci_atc_check$get_meta_data']();
  const attributes = await metaData.get()['if_ci_atc_check_meta_data$get_attributes']();
  const rows = attributes.array();

  if (!defaultAttributes.has(inst)) {
    const snapshot = new Map();
    for (const row of rows) {
      const attr = row.get();
      snapshot.set(attr.name.get(), attr.value.dereference().get());
    }
    defaultAttributes.set(inst, snapshot);
  }

  const snapshot = defaultAttributes.get(inst);
  for (const row of rows) {
    const attr = row.get();
    const name = attr.name.get();
    const target = attr.value.dereference();
    if (Object.prototype.hasOwnProperty.call(overrides, name)) {
      const raw = overrides[name];
      target.set(typeof raw === 'boolean' ? (raw ? 'X' : ' ') : String(raw));
    } else {
      target.set(snapshot.get(name));
    }
  }
}

/**
 * Runs a single expected row assertion against the ATC check instance.
 */
export async function runRow({ abap, getCheck, rule, fullLines, row, proceduresCache = null }) {
  const targetName = row.target || row.method;
  const procedures = proceduresCache || extractAllProcedures(fullLines);
  const targetProc = resolveProcedureForTarget(procedures, targetName);
  const checkId = rule.ruleId;

  if (!targetProc || targetProc.snippet.length === 0) {
    return {
      pass: false,
      message: `${checkId}/${targetName}: procedure could not be extracted`,
      findings: [],
    };
  }

  const objectName = targetProc.mainName || 'ZSKYLINT_TEST';
  const fullSource = fullLines.join('\n');
  const snippetSource = targetProc.snippet.join('\n');

  const statements = buildStatements(new Lexer(snippetSource).run());
  await feedRtti(fullSource, objectName, abap);
  const methodName = targetProc.kind === 'METH' ? targetProc.methodName || '' : '';
  await enrichStatements(statements, fullSource, objectName, methodName, targetProc.offset, {
    objectName,
    objectKind: targetProc.mainKind,
  });

  const procValue = buildProcedureValue(abap, {
    kind: targetProc.kind,
    name: targetProc.name,
    mainKind: targetProc.mainKind,
    mainName: objectName,
    statements,
  });

  const proceduresTable = buildProceduresTable(abap, [procValue]);
  const fakes = createFakes(abap, proceduresTable, objectName);

  const { inst } = await getCheck(rule);
  await applyAttributes(inst, row.attributes || {});
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

  // Validate QuickFix syntax roundtrip
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
          message: `${checkId}/${targetName}: quickfix ${fix.code} breaks syntax: ${errors.join('; ')}`,
          findings,
        };
      }
    }
  }

  // 1. Assert: No findings expected
  if (!row.code) {
    if (findings.length === 0) return { pass: true, findings };
    return {
      pass: false,
      message: `${checkId}/${targetName} [${targetProc.kind} ${targetProc.name}]: expected 0 findings, got ${JSON.stringify(findings)}`,
      findings,
    };
  }

  // 2. Assert: Specific finding expected
  const hit = findings.find((f) => f.code === row.code && f.line === row.line && f.column === row.column);
  if (!hit) {
    return {
      pass: false,
      message: `${checkId}/${targetName} [${targetProc.kind} ${targetProc.name}]: expected ${row.code} at ${row.line}:${row.column}, got ${JSON.stringify(findings)}`,
      findings,
    };
  }

  // 3. Assert: Quickfixes match
  if (row.quickfixes !== undefined && !sameCodes(hit.quickfixes, row.quickfixes)) {
    return {
      pass: false,
      message: `${checkId}/${targetName}: expected quickfixes ${JSON.stringify(row.quickfixes)}, got ${JSON.stringify(hit.quickfixes)}`,
      findings,
    };
  }

  return { pass: true, findings };
}

async function runCheck({ abap, getCheck, rule, verbose = false }) {
  const { lines, expected } = loadFixture(rule);
  const fullSource = lines.join('\n');
  const syntaxErrors = await validateFixtureSyntax(fullSource);
  if (syntaxErrors.length > 0) {
    return {
      passed: 0,
      failed: 1,
      failures: [`${rule.ruleId}: fixture source has syntax error: ${syntaxErrors.join('; ')}`],
    };
  }

  const procedures = extractAllProcedures(lines);
  const failures = [];
  let passed = 0;

  for (const row of expected) {
    const targetName = row.target || row.method;
    const res = await runRow({
      abap,
      getCheck,
      rule,
      fullLines: lines,
      row,
      proceduresCache: procedures,
    });
    if (res.pass) {
      passed += 1;
      if (verbose) {
        console.log(`  PASS ${rule.ruleId}/${targetName}`);
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

  const explicitKeys = args.filter((a) => !a.startsWith('-') && a !== filter);

  let targetRules = [];
  if (explicitKeys.length > 0) {
    for (const k of explicitKeys) {
      const r = resolveRule(k);
      if (r) targetRules.push(r);
      else console.warn(`Warning: Rule not recognized: ${k}`);
    }
  } else {
    targetRules = [...RULES];
  }

  if (filter) {
    targetRules = targetRules.filter(
      (r) => r.ruleId.includes(filter) || r.className.toLowerCase().includes(filter.toLowerCase())
    );
  }

  const abap = await initRuntime();
  const getCheck = createLoader(abap);

  let totalPassed = 0;
  let totalFailed = 0;
  const allFailures = [];

  for (const rule of targetRules) {
    try {
      const result = await runCheck({ abap, getCheck, rule, verbose });
      totalPassed += result.passed;
      totalFailed += result.failed;
      allFailures.push(...result.failures);

      if (bail && result.failed > 0) {
        break;
      }
    } catch (err) {
      totalFailed += 1;
      allFailures.push(`${rule.ruleId}: crash - ${err.message}`);
      if (bail) break;
    }
  }

  if (allFailures.length > 0) {
    console.error('\nFAILURES:');
    for (const f of allFailures) {
      console.error(`  - ${f}`);
    }
    console.error(`\n${totalPassed} passed, ${totalFailed} failed (${targetRules.length} checks)`);
    process.exit(1);
  }

  console.log(`\n${totalPassed} passed, 0 failed (${targetRules.length} checks)`);
  process.exit(0);
}

if (process.argv[1] && import.meta.url === pathToFileURL(process.argv[1]).href) {
  main();
}
