// ---------------------------------------------------------------------------
// Skylint compiler reference resolver (abaplint backed)
//
// The statement stream (keywords, chain unrolling, token positions) is produced
// by Skylint's own parser (lib/core/lexer.mjs + lib/core/parser.mjs).
// This module only answers the question "what symbol does this token refer to?"
// by delegating to abaplint's v5 syntax logic (scope resolution) and translating
// the result into the ATC compiler reference shape used by the ABAP checks:
//   kind        -> if_ci_atc_source_code_provider=>compiler_reference_kinds-*
//   full_name   -> \DA:NAME / \TY:NAME / \DB:NAME / \TY:CLASS\ME:METHOD
//   usage_grade -> 0 = definition, 1 = usage
//   usage_mode  -> if_ci_atc_source_code_provider=>usage_modes-*
// ---------------------------------------------------------------------------

import { Registry, MemoryFile, SyntaxLogic } from '@abaplint/core';

const REF = {
  OBJECT: 'Object',
  OBJECT_UNKNOWN: 'Object (Unknown)',
  METHOD: 'Method',
  CONSTRUCTOR: 'Constructor Reference',
  METHOD_IMPL: 'Method Implementation',
  TYPE: 'Type',
  BUILTIN_TYPE: 'Builtin Type',
  VOID_TYPE: 'Type (Void)',
  TABLE: 'Table',
  DATA_READ: 'Read From',
  DATA_WRITE: 'Write To',
  FORM: 'Form',
};

const ATC = {
  DATA: 'DA',
  TYPE: 'TY',
  METHOD: 'ME',
  FORM: 'FO',
};

const cache = new Map();
const CACHE_LIMIT = 64;

function detectObjectKind(source) {
  const head = source.slice(0, 4000);
  if (/^\s*INTERFACE\s+\S+\s+(?!\.)/im.test(head)) return 'INTF';
  if (/^\s*CLASS\s+\S+\s+DEFINITION/im.test(head)) return 'CLAS';
  if (/^\s*REPORT\s+/im.test(head)) return 'PROG';
  return 'PROG';
}

function fileNameFor(objectName, objectKind) {
  const base = (objectName || 'zskylint_test').toLowerCase().replace(/[^a-z0-9_]/g, '_');
  if (objectKind === 'CLAS') return `${base}.clas.abap`;
  if (objectKind === 'INTF') return `${base}.intf.abap`;
  return `${base}.prog.abap`;
}

function collectFromSpaghetti(spaghetti) {
  const refs = [];
  const visit = (node) => {
    const data = node.getData();
    for (const ref of data.references || []) {
      refs.push(ref);
    }
    for (const child of node.getChildren()) {
      visit(child);
    }
  };
  visit(spaghetti.getTop());
  return refs;
}

function toAtcReference(ref) {
  const resolved = ref.resolved ? ref.resolved.getName() : '';
  const name = (resolved || ref.position.getName() || '').toUpperCase();
  const ooName = ref.extra && ref.extra.ooName ? String(ref.extra.ooName).toUpperCase() : '';
  const common = { baseName: name, name, ooName, resolved: Boolean(resolved), refType: ref.referenceType };

  switch (ref.referenceType) {
    case REF.OBJECT:
    case REF.CONSTRUCTOR:
      return { ...common, kind: ATC.TYPE };
    case REF.METHOD:
      return { ...common, kind: ATC.METHOD, ooName: resolved ? ooName : '' };
    case REF.TYPE:
      return { ...common, kind: ATC.TYPE };
    case REF.DATA_READ:
    case REF.DATA_WRITE:
      return { ...common, kind: ATC.DATA };
    case REF.TABLE:
      return { ...common, kind: ATC.DATA, isTable: true };
    case REF.FORM:
      return { ...common, kind: ATC.FORM };
    default:
      return null;
  }
}

/**
 * Parses the given source with abaplint and returns the resolved references
 * indexed by "row:column" (1-based row, 1-based column as reported by abaplint).
 */
export async function collectAbaplintReferences(source, objectName, objectKind) {
  const kind = objectKind || detectObjectKind(source);
  const fileName = fileNameFor(objectName, kind);
  const cacheKey = `${fileName}|${source}`;
  const cached = cache.get(cacheKey);
  if (cached) return cached;

  const index = new Map();
  const result = { index, kind, fileName, available: false };

  try {
    const reg = new Registry();
    reg.addFile(new MemoryFile(fileName, source));
    await reg.parse();
    const obj = reg.getFirstObject();
    if (!obj) {
      cache.set(cacheKey, result);
      return result;
    }
    const syntax = new SyntaxLogic(reg, obj).run();
    for (const ref of collectFromSpaghetti(syntax.spaghetti)) {
      const atc = toAtcReference(ref);
      if (!atc) continue;
      const start = ref.position.getStart();
      const row = start.getRow();
      const col = start.getCol();
      if (!row || !col) continue;
      const key = `${row}:${col}`;
      if (!index.has(key)) index.set(key, []);
      index.get(key).push(atc);
    }
    result.available = true;
  } catch {
    result.available = false;
  }

  if (cache.size >= CACHE_LIMIT) {
    cache.delete(cache.keys().next().value);
  }
  cache.set(cacheKey, result);
  return result;
}

export function clearReferenceCache() {
  cache.clear();
}

export { detectObjectKind, fileNameFor, REF, ATC };
