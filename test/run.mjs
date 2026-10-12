#!/usr/bin/env node
/**
 * test/run.mjs — ATC-native JS test runner.
 *
 * For every tests/fixtures/check_XXX/{source.abap, expected.json} row:
 *   slice -> lex/parse -> abaplint enrich -> RTTI feed -> ty_procedure
 *   -> if_ci_atc_check~run (with JS fakes for the SAP boundary)
 *   -> compare { code, line, column } with expected.json
 *
 * Usage: npm run build && node test/run.mjs [checkId ...]
 */
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { Lexer } from './lexer.mjs';
import { buildStatements } from './parser.mjs';
import { extractSnippet, describeTarget } from './slicer.mjs';
import { joinSource } from './codeblock.mjs';
import { enrichStatements } from './abaplint-bridge.mjs';
import { feedRtti } from './rtti.mjs';
import { buildProcedureValue, buildProceduresTable, buildObjectValue } from './atc-values.mjs';
import { createFakes } from './fakes.mjs';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const rootDir = path.resolve(__dirname, '..');
const outDir = path.join(rootDir, 'output');
const fixturesDir = path.join(rootDir, 'tests', 'fixtures');
const toFileUrl = (p) => 'file:///' + p.replace(/\\/g, '/');

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

async function initRuntime() {
  await import(toFileUrl(path.join(outDir, 'init.mjs')));
  return globalThis.abap;
}

function createLoader(abap) {
  const cache = new Map();
  return async function getCheck(checkId) {
    if (!cache.has(checkId)) {
      const mod = await import(toFileUrl(path.join(outDir, `zcl_skylint_check_${checkId}.clas.mjs`)));
      const inst = new mod[`zcl_skylint_check_${checkId}`]();
      await inst.constructor_();
      const factory = { provider: null, factory: null };
      cache.set(checkId, { inst, factory });
    }
    return cache.get(checkId);
  };
}

function procedureName(statements, isDef, object) {
  if (isDef) return object;
  for (const s of statements) {
    if (s.keyword === 'METHOD' && s.tokens.length >= 2) {
      return `${object}=>${s.tokens[1].lexeme.toUpperCase()}`;
    }
  }
  return `${object}=>TEST`;
}

/** Run one expected row; returns { pass, message, findings }. */
async function runRow({ abap, getCheck, checkId, fullLines, row }) {
  const { snippet, isDef, offset, object } = extractSnippet(fullLines, row.method);
  if (snippet.length === 0) return { pass: false, message: `${checkId}/${row.method}: empty slice`, findings: [] };
  const target = describeTarget(fullLines, row.method);
  if (target === 'class-fallback' || target === 'empty') {
    console.log(`WARN ${checkId}/${row.method}: resolved as ${target} (possible typo)`);
  }

  const objectName = object || 'ZSKYLINT_TEST';
  const statements = buildStatements(new Lexer(joinSource(snippet)).run());
  await feedRtti(joinSource(fullLines), objectName, abap);
  await enrichStatements(statements, joinSource(fullLines), objectName, offset);

  const procValue = buildProcedureValue(abap, {
    kind: isDef ? 'DECL' : 'METH',
    name: procedureName(statements, isDef, objectName),
    mainKind: 'CLAS',
    mainName: objectName,
    statements,
  });
  const procedures = buildProceduresTable(abap, [procValue]);
  const fakes = createFakes(abap, procedures, objectName);

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
    return { code: g.code.get().trim(), line: pos.line.get(), column: pos.column.get() };
  });

  if (!row.code) {
    if (findings.length === 0) return { pass: true, findings };
    return { pass: false, message: `${checkId}/${row.method}: expected 0 findings, got ${JSON.stringify(findings)}`, findings };
  }
  const hit = findings.find((f) => f.code === row.code && f.line === row.line && f.column === row.column);
  if (hit) return { pass: true, findings };
  return {
    pass: false,
    message: `${checkId}/${row.method}: expected ${row.code} at ${row.line}:${row.column}, got ${JSON.stringify(findings)}`,
    findings,
  };
}

async function main() {
  const args = process.argv.slice(2).filter((a) => !a.startsWith('--'));
  const abap = await initRuntime();
  const getCheck = createLoader(abap);

  let ids = discoverChecks();
  if (args.length > 0) ids = ids.filter((id) => args.includes(id));

  let pass = 0;
  let fail = 0;
  const failures = [];
  for (const id of ids) {
    const { lines, expected } = loadFixture(id);
    for (const row of expected) {
      try {
        const r = await runRow({ abap, getCheck, checkId: id, fullLines: lines, row });
        if (r.pass) pass++;
        else {
          fail++;
          failures.push(r.message);
        }
      } catch (e) {
        fail++;
        failures.push(`${id}/${row.method}: ERROR ${e.message}`);
      }
    }
  }

  for (const f of failures) console.log(`FAIL ${f}`);
  console.log(`\n${pass} passed, ${fail} failed (${ids.length} checks)`);
  process.exit(fail === 0 ? 0 : 1);
}

await main();
