#!/usr/bin/env node
/**
 * scripts/fill-positions.mjs
 *
 * Fills `line = N column = M` into every `it_expected` row that has a `code`
 * in all `*.clas.testclasses.abap` files using Skylint checks.
 *
 * Positions are computed by running the REAL transpiled check logic
 * (same lexer/parser/checks as the unit tests), so they always match
 * what the runners assert. Must run from the repo root AFTER `npm run build`
 * (the transpiled `read_test_source` reads fixtures via process.cwd()).
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
const coreDir = path.join(rootDir, 'src', 'core');
const outDir = path.join(rootDir, 'output');

if (!fs.existsSync(path.join(outDir, 'zcl_skylint_open_test_run.clas.mjs'))) {
  console.error('Transpiled output not found. Run `npm run build` first.');
  process.exit(1);
}

// The transpiled output must be newer than the test sources, otherwise
// positions are computed from stale code. Rebuild if in doubt.
const outMtime = fs.statSync(path.join(outDir, 'zcl_skylint_open_test_run.clas.mjs')).mtimeMs;
const srcFiles = [
  ...fs.readdirSync(checksDir).filter((f) => f.endsWith('.abap')).map((f) => path.join(checksDir, f)),
  ...fs.readdirSync(path.join(rootDir, 'src', 'tests')).filter((f) => f.endsWith('.abap')).map((f) => path.join(rootDir, 'src', 'tests', f)),
];
const newestSrc = Math.max(...srcFiles.map((f) => fs.statSync(f).mtimeMs));
if (newestSrc > outMtime) {
  console.error('Transpiled output is older than sources. Run `npm run build` first, then re-run positions.');
  process.exit(1);
}

const toFileUrl = (p) => 'file:///' + p.replace(/\\/g, '/');
await import(toFileUrl(path.join(outDir, 'init.mjs')));
const { zcl_skylint_open_test_run } = await import(toFileUrl(path.join(outDir, 'zcl_skylint_open_test_run.clas.mjs')));
const abap = globalThis.abap;
const S = (v) => new abap.types.String().set(v);
const FALSE = abap.builtin.abap_false;
const TRUE = abap.builtin.abap_true;

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

/**
 * Run a check on a fixture method exactly like
 * zcl_skylint_open_test_run=>run_in_memory does.
 */
async function runFindings(checkNum, fixtureClass, method) {
  const ioCheck = await getCheckInstance(checkNum);
  const read = (m, def) => zcl_skylint_open_test_run.read_test_source({
    iv_class: S(fixtureClass),
    ...(m ? { iv_method: S(m) } : {}),
    iv_class_def: def ? TRUE : FALSE,
  });
  let src = await read(method, false);
  if (!src || src.get().length === 0) {
    return [];
  }
  const isClassDef = (t) => /^CLASS .* DEFINITION/s.test(t) || t.startsWith('INTERFACE ');
  let findings = await zcl_skylint_open_test_run.run_check({
    io_check: ioCheck,
    iv_source: src,
    iv_class_definition: isClassDef(src.get()) ? TRUE : FALSE,
    iv_object_name: S(fixtureClass),
  });
  let rows = findings.array ? findings.array() : findings.get();
  if (rows.length === 0) {
    src = await read(undefined, true);
    if (src && src.get().length > 0) {
      findings = await zcl_skylint_open_test_run.run_check({
        io_check: ioCheck,
        iv_source: src,
        iv_class_definition: TRUE,
        iv_object_name: S(fixtureClass),
      });
      rows = findings.array ? findings.array() : findings.get();
    }
  }
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
targets.push(path.join(coreDir, 'zcl_skylint_test_runner.clas.testclasses.abap'));

const rowRegex = /\(\s*method\s*=\s*'([^']+)'\s*code\s*=\s*([^\s)]+)[^)]*\)/g;
const jobs = [];

for (const file of targets) {
  const content = fs.readFileSync(file, 'utf8');
  const fixture = (content.match(/iv_class\s*=\s*'([^']+)'/) || [])[1];
  if (!fixture) {
    continue;
  }
  const fixtureNum = (fixture.match(/(\d+)\s*$/) || [])[1];
  if (!fixtureNum) {
    console.warn(`skip ${path.basename(file)}: cannot parse fixture number`);
    continue;
  }
  for (const m of content.matchAll(rowRegex)) {
    const checkNum = (m[2].match(/zcl_skylint_check_(\d+)/i) || [])[1] || fixtureNum;
    jobs.push({
      file,
      row: m[0],
      method: m[1],
      codeExpr: m[2],
      checkNum,
      fixture,
      fixtureNum,
    });
  }
}

/* ---------- Phase 2: compute positions (async, cached) ---------- */

const codesByCheck = {};
const posCache = {};

for (const job of jobs) {
  const cacheKey = `${job.checkNum}|${job.fixture}|${job.method}`;
  if (!(cacheKey in posCache)) {
    posCache[cacheKey] = await runFindings(job.checkNum, job.fixture, job.method);
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
    job.warning = `no finding with code ${codeValue} in ${job.fixture} ${job.method}`;
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
