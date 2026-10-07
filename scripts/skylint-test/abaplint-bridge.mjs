/**
 * scripts/skylint-test/abaplint-bridge.mjs
 *
 * Pure-JS replacement of lcl_abaplint_bridge=>build_payload/apply_payload/apply_ref_line
 * (src/platform/zcl_skylint_test_runner.clas.locals_imp.abap:1176-1319).
 * Previously embedded as WRITE '@KERNEL ...' strings inside ABAP; now a
 * normal lintable/debuggable module with direct @abaplint/core imports.
 *
 * enrichStatements(statements, fullSource, objectName, absOffset):
 *   runs abaplint SyntaxLogic spaghetti over the FULL source and overlays
 *   ME/TY/DA references onto the JS-built statements (same line/col +
 *   lexeme-contains matching as the ABAP original). Only ADDS references.
 */

import { Registry, MemoryFile, SyntaxLogic } from '@abaplint/core';

const flat = (s) => (s + '').replace(/[|]/g, ' ').replace(/[\r\n]+/g, ' ');

/** Collect spaghetti refs as payload rows (mirrors @KERNEL build_payload). */
export async function spaghettiRefs(fullSource, objectName = '', absOffset = 0) {
  const sn = (objectName || '').trim() || 'ZSKYLINT_TEST';
  const off = parseInt(absOffset || '0', 10) || 0;
  const tyPre = '\\\\TY:' + sn.toUpperCase();
  const mePre = '\\\\ME:';
  const out = [];
  try {
    const reg = new Registry();
    reg.addFile(new MemoryFile(sn.toLowerCase() + '.clas.abap', fullSource));
    await reg.parseAsync();
    const obj = reg.getFirstObject();
    if (obj) walk(new SyntaxLogic(reg, obj).run().spaghetti.getTop());
  } catch {
    // lenient: heuristic refs already present, abaplint overlay is best-effort
  }
  return out;

  function walk(node) {
    const data = node.getData ? node.getData() : null;
    for (const r of (data && data.references) || []) emitOne(r);
    for (const ch of node.getChildren ? node.getChildren() : []) walk(ch);
  }
  function emitOne(r) {
    try {
      const pos = r.position ? r.position.getStart() : null;
      if (!pos) return;
      emitKind(r, [pos.getRow() - off, pos.getCol()]);
    } catch {
      // ignore single-ref failures
    }
  }
  function emitKind(r, rel) {
    if (rel[0] < 1) return;
    const rt = (r.referenceType || '').toString();
    const id = (r.identifierName || '') + '';
    let kind = '';
    if (/method/i.test(rt)) kind = 'ME';
    else if (/type/i.test(rt)) kind = 'TY';
    else if (/data|variable/i.test(rt)) kind = 'DA';
    if (!kind) return;
    const res = r.resolved;
    let isStatic = '';
    try {
      if (typeof (res && res.isStatic) === 'function' && res.isStatic()) isStatic = 'X';
    } catch {
      // ignore
    }
    let fname = '';
    try {
      let nm = res && res.getName ? res.getName() + '' : '';
      nm = nm.toUpperCase();
      if (nm) fname = tyPre + mePre + nm;
    } catch {
      // ignore
    }
    if (!fname && kind === 'ME' && id) fname = tyPre + mePre + id.toUpperCase();
    fname = fname || id.toUpperCase();
    if (fname) out.push({ rel: rel[0], col: rel[1], ident: flat(id || fname), kind, fname: flat(fname), grade: '1', mode: '5', isStatic });
  }
}

/**
 * lcl_abaplint_bridge=>apply_payload/apply_ref_line.
 * NOTE: ABAP EXITs only the inner token loop, so one payload row can attach
 * to several statements sharing the same line — preserved here.
 */
export function applyRefs(statements, rows) {
  for (const row of rows) {
    if (row.kind !== 'ME' && row.kind !== 'DA' && row.kind !== 'TY') continue;
    const identUp = row.ident.toUpperCase();
    for (const stmt of statements) {
      for (const tok of stmt.tokens) {
        if (tok.position.line !== row.rel) continue;
        const tokUp = tok.lexeme.toUpperCase();
        const inRange = row.col >= tok.position.column && row.col < tok.position.column + tok.lexeme.length;
        if (!inRange && !tokUp.includes(identUp) && !identUp.includes(tokUp)) continue;
        tok.references.push({
          kind: row.kind,
          full_name: row.fname,
          usage_grade: row.grade,
          usage_mode: row.mode,
        });
        break; // EXIT inner loop only
      }
    }
  }
}

/** Full enrich step for one snippet's statements (mutates in place). */
export async function enrichStatements(statements, fullSource, objectName, absOffset) {
  if (!fullSource || statements.length === 0) return;
  const rows = await spaghettiRefs(fullSource, objectName, absOffset);
  applyRefs(statements, rows);
}
