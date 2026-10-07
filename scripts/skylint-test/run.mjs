#!/usr/bin/env node
/**
 * scripts/skylint-test/run.mjs — JS test harness CLI (replaces ABAP test_runner).
 *
 * Usage:
 *   npm run build && node scripts/skylint-test/run.mjs [checkId ...]
 *   node scripts/skylint-test/run.mjs --fix-positions [checkId ...]
 *
 * --fix-positions recomputes line/column in expected.json from real runs
 * (replaces scripts/fill-positions.mjs).
 */
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { runAll, initRuntime, loadFixture, runSlice } from './harness.mjs';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const rootDir = path.resolve(__dirname, '..', '..');
const outDir = path.join(rootDir, 'output');
const fixturesDir = path.join(rootDir, 'tests', 'fixtures');

const args = process.argv.slice(2);
const fixPositions = args.includes('--fix-positions');
const filter = args.filter((a) => !a.startsWith('--'));

if (fixPositions) {
  const abap = await initRuntime(outDir);
  const { Lexer } = await import('./lexer.mjs');
  const { buildStatements } = await import('./parser.mjs');
  const { extractSnippet } = await import('./slicer.mjs');
  const { sliceCodeBlock, joinSource } = await import('./codeblock.mjs');
  const { enrichStatements } = await import('./abaplint-bridge.mjs');
  const { feedRtti } = await import('./rtti.mjs');
  const { buildCodeBlockValue } = await import('./abap-values.mjs');
  const toFileUrl = (p) => 'file:///' + p.replace(/\\/g, '/');
  const cache = new Map();
  const getCheck = async (id) => {
    if (!cache.has(id)) {
      const mod = await import(toFileUrl(path.join(outDir, `zcl_skylint_check_${id}.clas.mjs`)));
      const inst = new mod[`zcl_skylint_check_${id}`]();
      await inst.constructor_();
      cache.set(id, inst);
    }
    return cache.get(id);
  };
  let ids = fs.readdirSync(fixturesDir).filter((f) => f.startsWith('check_')).map((f) => f.slice(6)).sort();
  if (filter.length > 0) ids = ids.filter((id) => filter.includes(id));
  let patched = 0;
  for (const id of ids) {
    const { lines, expected } = loadFixture(fixturesDir, id);
    const full = joinSource(lines);
    let changed = false;
    for (const row of expected) {
      if (!row.code) continue;
      const { snippet, isDef, offset, object } = extractSnippet(lines, row.method);
      if (snippet.length === 0) {
        console.log(`WARN ${id}/${row.method}: empty slice`);
        continue;
      }
      const statements = buildStatements(new Lexer(joinSource(snippet)).run());
      await feedRtti(full, object, abap);
      await enrichStatements(statements, full, object, offset);
      const ioCheck = await getCheck(id);
      const res = await ioCheck.lint({ is_code_block: buildCodeBlockValue(abap, sliceCodeBlock(statements, isDef, object)) });
      const rows = (res.array ? res.array() : res.get()).map((r) => {
        const g = r.get();
        return { code: g.code.get().trim(), line: g.position.get().line.get(), column: g.position.get().column.get() };
      });
      const hit = rows.find((f) => f.code === row.code);
      if (!hit) {
        console.log(`WARN ${id}/${row.method}: no finding with code ${row.code}`);
        continue;
      }
      if (row.line !== hit.line || row.column !== hit.column) {
        row.line = hit.line;
        row.column = hit.column;
        changed = true;
        patched += 1;
      }
    }
    if (changed) {
      fs.writeFileSync(path.join(fixturesDir, `check_${id}`, 'expected.json'), JSON.stringify(expected, null, 2) + '\n', 'utf8');
      console.log(`patched check_${id}`);
    }
  }
  console.log(`patched ${patched} rows`);
  process.exit(0);
}

const { pass, fail, warnings, failures } = await runAll({
  rootDir,
  outDir,
  filter: filter.length > 0 ? filter : null,
});
console.log(`\n${pass} passed, ${fail} failed, ${warnings} warnings`);
if (fail > 0) {
  console.log('failures:');
  for (const f of failures) console.log(` - ${f}`);
  process.exit(1);
}
