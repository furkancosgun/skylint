/**
 * scripts/skylint-test/harness.mjs
 *
 * JS replacement of zcl_skylint_test_runner=>run/run_all.
 * Runs transpiled checks against JS-pipeline code blocks for every fixture:
 *   tests/fixtures/check_XXX/{source.abap, expected.json}
 *
 * - expected row { method, code: null } => assert 0 findings
 * - expected row { method, code, line, column } => assert a finding with
 *   matching code+line+column exists (same semantics as ABAP run_all)
 */
import fs from 'node:fs';
import path from 'node:path';
import { Lexer } from './lexer.mjs';
import { buildStatements } from './parser.mjs';
import { extractSnippet } from './slicer.mjs';
import { sliceCodeBlock, joinSource } from './codeblock.mjs';
import { enrichStatements } from './abaplint-bridge.mjs';
import { feedRtti } from './rtti.mjs';
import { buildCodeBlockValue } from './abap-values.mjs';

export function loadFixture(fixturesDir, checkId) {
  const dir = path.join(fixturesDir, `check_${checkId}`);
  const text = fs.readFileSync(path.join(dir, 'source.abap'), 'utf8');
  const lines = text.split('\n');
  if (lines.length > 0 && lines[lines.length - 1] === '') lines.pop();
  const expected = JSON.parse(fs.readFileSync(path.join(dir, 'expected.json'), 'utf8'));
  return { lines, expected };
}

export function discoverChecks(fixturesDir) {
  return fs
    .readdirSync(fixturesDir)
    .filter((f) => f.startsWith('check_'))
    .map((f) => f.slice('check_'.length))
    .sort();
}

function createLoader(outDir, abap) {
  const toFileUrl = (p) => 'file:///' + p.replace(/\\/g, '/');
  const cache = new Map();
  return async function getCheck(checkId) {
    if (!cache.has(checkId)) {
      const mod = await import(toFileUrl(path.join(outDir, `zcl_skylint_check_${checkId}.clas.mjs`)));
      const inst = new mod[`zcl_skylint_check_${checkId}`]();
      await inst.constructor_();
      cache.set(checkId, inst);
    }
    return cache.get(checkId);
  };
}

export async function initRuntime(outDir) {
  const toFileUrl = (p) => 'file:///' + p.replace(/\\/g, '/');
  await import(toFileUrl(path.join(outDir, 'init.mjs')));
  return globalThis.abap;
}

/** Run one slice through the full JS pipeline and return plain findings. */
export async function runSlice({ abap, getCheck, checkId, fullLines, method }) {
  const { snippet, isDef, offset, object } = extractSnippet(fullLines, method);
  if (snippet.length === 0) return { empty: true, findings: [] };
  const statements = buildStatements(new Lexer(joinSource(snippet)).run());
  await feedRtti(joinSource(fullLines), object, abap);
  await enrichStatements(statements, joinSource(fullLines), object, offset);
  const jsBlock = sliceCodeBlock(statements, isDef, object);
  const ioCheck = await getCheck(checkId);
  const res = await ioCheck.lint({ is_code_block: buildCodeBlockValue(abap, jsBlock) });
  const rows = res.array ? res.array() : res.get();
  return {
    empty: false,
    findings: rows.map((r) => {
      const g = r.get();
      return {
        code: g.code.get().trim(),
        line: g.position.get().line.get(),
        column: g.position.get().column.get(),
      };
    }),
  };
}

/** Assert one expected row; returns { pass, message }. */
export function assertRow(checkId, row, findings) {
  if (!row.code) {
    if (findings.length === 0) return { pass: true };
    return { pass: false, message: `${checkId}/${row.method}: expected 0 findings, got ${findings.length}` };
  }
  const hit = findings.find((f) => f.code === row.code && f.line === row.line && f.column === row.column);
  if (hit) return { pass: true };
  return {
    pass: false,
    message: `${checkId}/${row.method}: expected ${row.code} at ${row.line}:${row.column}, got ${JSON.stringify(findings)}`,
  };
}

/** Run all fixtures; returns { pass, fail, failures[] }. */
export async function runAll({ rootDir, outDir, filter = null, quiet = false }) {
  const fixturesDir = path.join(rootDir, 'tests', 'fixtures');
  const abap = await initRuntime(outDir);
  const getCheck = createLoader(outDir, abap);
  let ids = discoverChecks(fixturesDir);
  if (filter) ids = ids.filter((id) => filter.includes(id));
  let pass = 0;
  let fail = 0;
  const failures = [];
  for (const id of ids) {
    const { lines, expected } = loadFixture(fixturesDir, id);
    for (const row of expected) {
      let findings;
      try {
        ({ findings } = await runSlice({ abap, getCheck, checkId: id, fullLines: lines, method: row.method }));
      } catch (e) {
        fail += 1;
        failures.push(`${id}/${row.method}: harness error: ${e.message}`);
        if (!quiet) console.log(`not ok ${id}/${row.method} — harness error: ${e.message}`);
        continue;
      }
      const r = assertRow(id, row, findings);
      if (r.pass) {
        pass += 1;
        if (!quiet) console.log(`ok ${id}/${row.method}`);
      } else {
        fail += 1;
        failures.push(r.message);
        if (!quiet) console.log(`not ok ${r.message}`);
      }
    }
  }
  return { pass, fail, failures };
}
