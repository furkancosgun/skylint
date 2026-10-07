#!/usr/bin/env node
/**
 * scripts/lint-string.mjs
 *
 * Core'a DOKUNMADAN disaridan string source lint'le + finding eslestir.
 * Sadece transpile edilmis public API kullanir:
 *   output/zcl_skylint_test_runner.clas.locals.mjs (lcl_runner.build_code_block)
 *   output/zcl_skylint_check_NNN.clas.mjs (constructor_, lint)
 * Dilimleme/test-runner semantiyle birebir aynidir (extract_snippet mirror).
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

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const rootDir = path.resolve(__dirname, '..');
const outDir = path.join(rootDir, 'output');

const [checkNum, srcArg, expArg] = process.argv.slice(2);
if (!checkNum || !srcArg) {
  console.error('kullanim: node scripts/lint-string.mjs <checkNum> <source.abap|-> [expected.json]');
  process.exit(2);
}
if (!fs.existsSync(path.join(outDir, 'zcl_skylint_test_runner.clas.locals.mjs'))) {
  console.error('Transpiled output yok. Once `npm run build` calistir.');
  process.exit(2);
}

const toFileUrl = (p) => 'file:///' + p.replace(/\\/g, '/');
await import(toFileUrl(path.join(outDir, 'init.mjs')));
const { lcl_runner } = await import(toFileUrl(path.join(outDir, 'zcl_skylint_test_runner.clas.locals.mjs')));
const abap = globalThis.abap;
const S = (v) => new abap.types.String().set(v);
const TRUE = abap.builtin.abap_true;
const FALSE = abap.builtin.abap_false;

const checkMod = await import(toFileUrl(path.join(outDir, `zcl_skylint_check_${checkNum}.clas.mjs`)));
const ioCheck = new checkMod[`zcl_skylint_check_${checkNum}`]();
await ioCheck.constructor_();

const source = srcArg === '-'
  ? fs.readFileSync(0, 'utf8')
  : fs.readFileSync(srcArg, 'utf8');
const fullLines = source.split(/\r?\n/);
const expected = expArg ? JSON.parse(fs.readFileSync(expArg, 'utf8')) : undefined;

function condense(s) {
  return s.replace(/\s+/g, ' ').trim();
}

function classNameOfLine(line) {
  const up = condense(line).toUpperCase();
  const words = up.split(' ');
  if (words.length < 2) return '';
  if (words[0] === 'CLASS' && up.includes(' DEFINITION')) return words[1];
  if (words[0] === 'INTERFACE') return words[1].replace(/\./g, '');
  return '';
}

function extractClassDef(method) {
  const blocks = [];
  let cur = null;
  for (const line of fullLines) {
    const up = line.toUpperCase();
    if (cur === null) {
      if ((up.includes('CLASS ') && up.includes('DEFINITION')) || up.includes('INTERFACE ')) cur = [line];
    } else {
      cur.push(line);
      const t = condense(line).toUpperCase();
      if (t === 'ENDCLASS.' || t === 'ENDINTERFACE.') { blocks.push(cur); cur = null; }
    }
  }
  if (blocks.length === 0) return { snippet: [], isDef: true, offset: 0, object: '' };
  const numMatch = method.toUpperCase().match(/(\d+)$/);
  const num = numMatch ? parseInt(numMatch[1], 10) : 0;
  const idx = num > 0 && num % 2 === 0 && blocks.length > 1 ? 1 : 0;
  const chosen = blocks[idx] || [];
  return { snippet: chosen, isDef: true, offset: 0, object: chosen.length > 0 ? classNameOfLine(chosen[0]) : '' };
}

function extractClassDefBlock(name) {
  const want = name.toUpperCase();
  if (!want) return [];
  const snippet = [];
  let inside = false;
  for (const line of fullLines) {
    if (!inside) {
      if (classNameOfLine(line) === want) inside = true;
      else continue;
    }
    snippet.push(line);
    const t = condense(line).toUpperCase();
    if (t === 'ENDCLASS.' || t === 'ENDINTERFACE.') return snippet;
  }
  return [];
}

function extractSnippet(method) {
  const want = method.toUpperCase();
  let start = -1, end = -1;
  for (let i = 0; i < fullLines.length; i++) {
    if (start < 0) {
      if (condense(fullLines[i]).toUpperCase() === `METHOD ${want}.`) start = i;
    } else if (condense(fullLines[i]).toUpperCase() === 'ENDMETHOD.') { end = i; break; }
  }
  if (start >= 0 && end > start) {
    const snippet = fullLines.slice(start, end + 1);
    const inner = snippet.slice(1, -1).join('\n').trim().toUpperCase();
    let object = '';
    for (let i = start - 1; i >= 0; i--) {
      const nm = classNameOfLine(fullLines[i]);
      if (nm) { object = nm; break; }
    }
    if (inner === '' || inner === 'RETURN.') {
      const def = extractClassDef(method);
      return { ...def, object: object || def.object };
    }
    return { snippet, isDef: false, offset: start, object };
  }
  const blk = extractClassDefBlock(method);
  if (blk.length > 0) {
    return { snippet: blk, isDef: true, offset: 0, object: want };
  }
  return extractClassDef(method);
}

function methodNames() {
  const names = [];
  for (const line of fullLines) {
    const m = condense(line).match(/^METHOD\s+(\S+?)\s*\.\s*$/i);
    if (m) names.push(m[1]);
  }
  return names;
}

async function lintMethod(method) {
  const { snippet, isDef, offset, object } = extractSnippet(method);
  if (snippet.length === 0) return [];
  const block = await lcl_runner.build_code_block({
    iv_source: S(snippet.join('\n')),
    iv_full_source: S(fullLines.join('\n')),
    iv_class_definition: isDef ? TRUE : FALSE,
    iv_abs_offset: offset,
    iv_object_name: S(object || ''),
  });
  const findings = await ioCheck.lint({ is_code_block: block });
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
      else { console.log(`MISMATCH ${exp.method}: 0 bekleniyordu, ${found.length} bulundu`); failed += 1; }
      continue;
    }
    const hit = found.find((f) => f.code === exp.code
      && (exp.line === undefined || f.line === exp.line)
      && (exp.column === undefined || f.column === exp.column));
    if (hit) console.log(`MATCH ${exp.method}: ${hit.code} line=${hit.line} column=${hit.column}`);
    else {
      console.log(`MISMATCH ${exp.method}: ${exp.code}${exp.line !== undefined ? ` @${exp.line}:${exp.column}` : ''} bulunamadi (bulunanlar: ${found.map((f) => `${f.code}@${f.line}:${f.column}`).join(', ') || 'yok'})`);
      failed += 1;
    }
  }
}
process.exit(failed === 0 ? 0 : 1);