#!/usr/bin/env node
/**
 * scripts/lint-string.mjs
 *
 * Core'a DOKUNMADAN disaridan string source lint'le + finding eslestir.
 * Yeni JS harness modullerini kullanir (scripts/skylint-test/):
 *   lexer -> parser -> abaplint bridge + rtti -> abap-values -> check lint
 * Dilimleme semantiği harness ile birebir aynidir (slicer.mjs).
 *
 * Kullanim:
 *   npm run build
 *   node scripts/lint-string.mjs <checkNum> <source.abap> [expected.json]
 *   node scripts/lint-string.mjs <checkNum> - [expected.json]   # stdin
 *
 * expected.json ornegi:
 *   [ {"method":"TEST_001","code":"STATICVIAI","line":3,"column":4},
 *     {"method":"TEST_002"} ]
 * code yoksa o methodda 0 finding beklenir. line/column verilmezse sadece code eslesir.
 * expected verilmezse tum methodlardaki findingler dokulur (cikis 0).
 */
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { Lexer } from './skylint-test/lexer.mjs';
import { buildStatements } from './skylint-test/parser.mjs';
import { extractSnippet, condense } from './skylint-test/slicer.mjs';
import { sliceCodeBlock, joinSource } from './skylint-test/codeblock.mjs';
import { enrichStatements } from './skylint-test/abaplint-bridge.mjs';
import { feedRtti } from './skylint-test/rtti.mjs';
import { buildCodeBlockValue } from './skylint-test/abap-values.mjs';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const rootDir = path.resolve(__dirname, '..');
const outDir = path.join(rootDir, 'output');

const [checkNum, srcArg, expArg] = process.argv.slice(2);
if (!checkNum || !srcArg) {
  console.error('kullanim: node scripts/lint-string.mjs <checkNum> <source.abap|-> [expected.json]');
  process.exit(2);
}

const toFileUrl = (p) => 'file:///' + p.replace(/\\/g, '/');
await import(toFileUrl(path.join(outDir, 'init.mjs')));
const abap = globalThis.abap;

const checkMod = await import(toFileUrl(path.join(outDir, `zcl_skylint_check_${checkNum}.clas.mjs`)));
const ioCheck = new checkMod[`zcl_skylint_check_${checkNum}`]();
await ioCheck.constructor_();

const source = srcArg === '-' ? fs.readFileSync(0, 'utf8') : fs.readFileSync(srcArg, 'utf8');
const fullLines = source.split(/\r?\n/);
const expected = expArg ? JSON.parse(fs.readFileSync(expArg, 'utf8')) : undefined;

function methodNames() {
  const names = [];
  for (const line of fullLines) {
    const m = condense(line).match(/^METHOD\s+(\S+?)\s*\.\s*$/i);
    if (m) names.push(m[1]);
  }
  return names;
}

async function lintMethod(method) {
  const { snippet, isDef, offset, object } = extractSnippet(fullLines, method);
  if (snippet.length === 0) return [];
  const statements = buildStatements(new Lexer(joinSource(snippet)).run());
  await feedRtti(joinSource(fullLines), object, abap);
  await enrichStatements(statements, joinSource(fullLines), object, offset);
  const findings = await ioCheck.lint({ is_code_block: buildCodeBlockValue(abap, sliceCodeBlock(statements, isDef, object)) });
  const rows = findings.array ? findings.array() : findings.get();
  return rows.map((f) => {
    const g = f.get();
    return { code: g.code.get().trim(), line: g.position.get().line.get(), column: g.position.get().column.get() };
  });
}

let failed = 0;
if (!expected) {
  for (const m of methodNames()) {
    const found = await lintMethod(m);
    if (found.length === 0) console.log(`${m}: (finding yok)`);
    for (const f of found) console.log(`${m}: ${f.code} line=${f.line} column=${f.column}`);
  }
} else {
  for (const exp of expected) {
    const found = await lintMethod(exp.method);
    if (!exp.code) {
      if (found.length === 0) console.log(`MATCH ${exp.method}: finding yok (beklendigi gibi)`);
      else {
        console.log(`MISMATCH ${exp.method}: 0 bekleniyordu, ${found.length} bulundu`);
        failed += 1;
      }
      continue;
    }
    const hit = found.find(
      (f) =>
        f.code === exp.code &&
        (exp.line === undefined || f.line === exp.line) &&
        (exp.column === undefined || f.column === exp.column),
    );
    if (hit) console.log(`MATCH ${exp.method}: ${hit.code} line=${hit.line} column=${hit.column}`);
    else {
      console.log(
        `MISMATCH ${exp.method}: ${exp.code}${exp.line !== undefined ? ` @${exp.line}:${exp.column}` : ''} bulunamadi (bulunanlar: ${found.map((f) => `${f.code}@${f.line}:${f.column}`).join(', ') || 'yok'})`,
      );
      failed += 1;
    }
  }
}
process.exit(failed === 0 ? 0 : 1);
