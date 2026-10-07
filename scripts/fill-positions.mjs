#!/usr/bin/env node
/**
 * scripts/fill-positions.mjs
 *
 * Fills `line = N column = M` into every `it_expected` row that has a `code`
 * in all `*.clas.testclasses.abap` files using Skylint checks.
 *
 * Positions are computed by running the REAL transpiled check logic
 * (same lexer/parser/bridge/checks as the unit tests), so they always match
 * what the test runner asserts. Must run from the repo root AFTER
 * `npm run build`.
 *
 * Test sources are inline (`lt_source = VALUE #( ... )`), snippet slicing
 * mirrors zcl_skylint_test_runner=>extract_snippet.
 *
 * Usage:
 *   npm run build && npm run positions
 */

import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const rootDir = path.resolve(__dirname, '..');
const checksDir = path.join(rootDir, 'src', 'checks');
const outDir = path.join(rootDir, 'output');

if (!fs.existsSync(path.join(outDir, 'zcl_skylint_test_runner.clas.locals.mjs'))) {
  console.error('Transpiled output not found. Run `npm run build` first.');
  process.exit(1);
}

const toFileUrl = (p) => 'file:///' + p.replace(/\\/g, '/');
await import(toFileUrl(path.join(outDir, 'init.mjs')));
const locals = await import(toFileUrl(path.join(outDir, 'zcl_skylint_test_runner.clas.locals.mjs')));
const { lcl_runner } = locals;
const abap = globalThis.abap;
const S = (v) => new abap.types.String().set(v);
const TRUE = abap.builtin.abap_true;
const FALSE = abap.builtin.abap_false;

/** Parse `c_finding_codes` const -> VALUE pairs from a check source file. */
function parseFindingCodes(checkNum) {
  const content = fs.readFileSync(path.join(checksDir, `zcl_skylint_check_${checkNum}.clas.abap`), 'utf8');
  const map = {};
  const regex = /(\w+)\s+TYPE\s+zif_skylint_types=>ty_finding_code\s+VALUE\s+'([^']+)'/gi;
  let m;
  while ((m = regex.exec(content)) !== null) {
    map[m[1].toLowerCase()] = m[2];
  }
  return map;
}

/** ABAP semantics: assigning a longer literal to `c LENGTH n` truncates right. */
function abapCharLen() {
  const intf = fs.readFileSync(path.join(rootDir, 'src', 'core', 'zif_skylint_types.intf.abap'), 'utf8');
  const m = intf.match(/ty_finding_code\s+TYPE\s+c\s+LENGTH\s+(\d+)/i);
  return m ? parseInt(m[1], 10) : 10;
}
const FINDING_CODE_LEN = abapCharLen();

/** Resolve a `code = ...` expression from a test row to its literal value. */
function resolveCode(codeExpr, checkNum, codesByCheck) {
  const ref = codeExpr.match(/c_finding_codes-(\w+)/i);
  if (ref) {
    codesByCheck[checkNum] ??= parseFindingCodes(checkNum);
    const value = codesByCheck[checkNum][ref[1].toLowerCase()];
    if (!value) {
      throw new Error(`unknown finding code constant: ${codeExpr}`);
    }
    return value.slice(0, FINDING_CODE_LEN);
  }
  const lit = codeExpr.match(/^'([^']+)'$/);
  if (lit) {
    return lit[1].slice(0, FINDING_CODE_LEN);
  }
  throw new Error(`cannot resolve code expression: ${codeExpr}`);
}

const checkInstances = {};
async function getCheckInstance(checkNum) {
  if (!checkInstances[checkNum]) {
    const mod = await import(toFileUrl(path.join(outDir, `zcl_skylint_check_${checkNum}.clas.mjs`)));
    const inst = new mod[`zcl_skylint_check_${checkNum}`]();
    await inst.constructor_();
    checkInstances[checkNum] = inst;
  }
  return checkInstances[checkNum];
}

/** Extract inline `lt_source` rows (backtick literals, `` escapes `). */
function parseInlineSource(content) {
  const rows = [];
  const re = /\(\s*`((?:``|[^`])*)`\s*\)/g;
  let m;
  while ((m = re.exec(content)) !== null) {
    rows.push(m[1].replace(/``/g, '`'));
  }
  return rows;
}

function condense(s) {
  return s.replace(/\s+/g, ' ').trim();
}

/** Mirror of zcl_skylint_test_runner=>extract_snippet (pure logic). */
function extractSnippet(fullLines, method) {
  const want = method.toUpperCase();
  let start = -1;
  let end = -1;
  for (let i = 0; i < fullLines.length; i++) {
    if (start < 0) {
      if (condense(fullLines[i]).toUpperCase() === `METHOD ${want}.`) {
        start = i;
      }
    } else {
      if (condense(fullLines[i]).toUpperCase() === 'ENDMETHOD.') {
        end = i;
        break;
      }
    }
  }
  if (start >= 0 && end > start) {
    const snippet = fullLines.slice(start, end + 1);
    const inner = snippet.slice(1, -1).join('\n').trim().toUpperCase();
    if (inner === '' || inner === 'RETURN.') {
      return extractClassDef(fullLines, method);
    }
    return { snippet, isDef: false, offset: start };
  }
  return extractClassDef(fullLines, method);
}

function extractClassDef(fullLines, method) {
  const blocks = [];
  let cur = null;
  for (const line of fullLines) {
    const up = line.toUpperCase();
    if (cur === null) {
      if ((up.includes('CLASS ') && up.includes('DEFINITION')) || up.includes('INTERFACE ')) {
        cur = [line];
      }
    } else {
      cur.push(line);
      const t = condense(line).toUpperCase();
      if (t === 'ENDCLASS.' || t === 'ENDINTERFACE.') {
        blocks.push(cur);
        cur = null;
      }
    }
  }
  if (blocks.length === 0) {
    return { snippet: [], isDef: true, offset: 0 };
  }
  const numMatch = method.toUpperCase().match(/(\d+)$/);
  const num = numMatch ? parseInt(numMatch[1], 10) : 0;
  const idx = num > 0 && num % 2 === 0 && blocks.length > 1 ? 1 : 0;
  return { snippet: blocks[idx], isDef: true, offset: 0 };
}

/** Run a check on an inline snippet like the test runner does. */
async function runFindings(checkNum, fullLines, method) {
  const ioCheck = await getCheckInstance(checkNum);
  const { snippet, isDef, offset } = extractSnippet(fullLines, method);
  if (snippet.length === 0) {
    return [];
  }
  const block = await lcl_runner.build_code_block({
    iv_source: S(snippet.join('\n')),
    iv_full_source: S(fullLines.join('\n')),
    iv_class_definition: isDef ? TRUE : FALSE,
    iv_abs_offset: offset,
  });
  const findings = await ioCheck.lint({ is_code_block: block });
  const rows = findings.array ? findings.array() : findings.get();
  return rows.map((f) => {
    const g = f.get();
    return {
      code: g.code.get().trim(),
      line: g.position.get().line.get(),
      column: g.position.get().column.get(),
    };
  });
}

/* ---------- Phase 1: collect rows (sync) ---------- */

const targets = fs.readdirSync(checksDir)
  .filter((f) => f.endsWith('.clas.testclasses.abap'))
  .map((f) => path.join(checksDir, f));

const rowRegex = /\(\s*method\s*=\s*'([^']+)'\s*code\s*=\s*([^\s)]+)[^)]*\)/g;
const jobs = [];

for (const file of targets) {
  const content = fs.readFileSync(file, 'utf8');
  const fullLines = parseInlineSource(content);
  if (fullLines.length === 0) {
    continue;
  }
  const checkNum = (path.basename(file).match(/zcl_skylint_check_(\d+)/) || [])[1];
  if (!checkNum) {
    continue;
  }
  for (const m of content.matchAll(rowRegex)) {
    jobs.push({
      file,
      row: m[0],
      method: m[1],
      codeExpr: m[2],
      checkNum,
      fullLines,
    });
  }
}

/* ---------- Phase 2: compute positions (async, cached) ---------- */

const codesByCheck = {};
const posCache = {};

for (const job of jobs) {
  const cacheKey = `${job.checkNum}|${job.method}`;
  if (!(cacheKey in posCache)) {
    posCache[cacheKey] = await runFindings(job.checkNum, job.fullLines, job.method);
  }
  let codeValue;
  try {
    codeValue = resolveCode(job.codeExpr, job.checkNum, codesByCheck);
  } catch (e) {
    job.warning = e.message;
    continue;
  }
  const hit = posCache[cacheKey].find((r) => r.code === codeValue);
  if (!hit) {
    job.warning = `no finding with code ${codeValue} in ${job.method}`;
    continue;
  }
  job.line = hit.line;
  job.column = hit.column;
}

/* ---------- Phase 3: patch files (sync) ---------- */

const byFile = new Map();
for (const job of jobs) {
  if (!byFile.has(job.file)) {
    byFile.set(job.file, []);
  }
  byFile.get(job.file).push(job);
}

let patchedFiles = 0;
let patchedRows = 0;
let warnings = 0;

for (const [file, fileJobs] of byFile) {
  let content = fs.readFileSync(file, 'utf8');
  let changed = false;
  for (const job of fileJobs) {
    if (job.warning || job.line === undefined) {
      console.warn(`UNCHANGED ${path.basename(file)} method=${job.method} code=${job.codeExpr}: ${job.warning || 'no position'}`);
      warnings += 1;
      continue;
    }
    let clean = job.row
      .replace(/\s+line\s*=\s*\d+/gi, '')
      .replace(/\s+column\s*=\s*\d+/gi, '')
      .replace(/\s+/g, ' ')
      .replace(/\(\s+/, '( ')
      .replace(/\s+\)$/, ` line = ${job.line} column = ${job.column} )`);
    const pos = content.indexOf(job.row);
    const lineStart = content.lastIndexOf('\n', pos) + 1;
    const prefixOnLine = content.slice(lineStart, pos);
    if (prefixOnLine.length + clean.length > 120) {
      const matchParen = prefixOnLine.lastIndexOf('(');
      const alignSpaces = matchParen >= 0 ? matchParen + 2 : 15;
      clean = `( method = '${job.method}'\n${' '.repeat(alignSpaces)}code = ${job.codeExpr} line = ${job.line} column = ${job.column} )`;
    }
    if (clean !== job.row) {
      content = content.replace(job.row, clean);
      changed = true;
      patchedRows += 1;
    }
  }
  if (changed) {
    fs.writeFileSync(file, content, 'utf8');
    patchedFiles += 1;
  }
}

console.log(`patched ${patchedRows} rows in ${patchedFiles} files, ${warnings} warnings`);
