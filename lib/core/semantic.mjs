import {
  DECL_KEYWORDS,
  DB_KEYWORDS_READ,
  DB_KEYWORDS_WRITE,
  pushRef,
  hasRefKind,
  isStringToken,
  dataScopePrefix,
  cutAtParen,
} from './parser.mjs';
import { collectAbaplintReferences } from './references-abaplint.mjs';

const BUILTIN_CONSTANTS = new Set(['ABAP_TRUE', 'ABAP_FALSE', 'ABAP_UNDEFINED']);
const BUILTIN_LITERALS = new Set(['SPACE', 'SYMBOL']);

const NON_DB_TARGETS = new Set([
  'TABLE', 'REPORT', 'TEXTPOOL', 'DYNPRO', 'DATASET', 'MEMORY', 'INITIAL', 'LINE', 'LINES', 'SCREEN', 'PROGRAM',
  'ENTITY', 'ENTITIES',
]);

const WRITE_TARGET_LAST = new Set([
  'CLEAR', 'FREE', 'REFRESH', 'MOVE', 'APPEND', 'INSERT', 'ADD', 'SUBTRACT', 'MULTIPLY', 'DIVIDE',
]);

// Statements that consume the current value of their write target and store the
// result back into it. Their target is a read AND a write, never a pure write.
const READ_MODIFY_WRITE_STATEMENTS = new Set([
  'ADD', 'SUBTRACT', 'MULTIPLY', 'DIVIDE', 'TRANSLATE', 'SHIFT', 'REPLACE', 'CONDENSE', 'OVERLAY', 'PACK', 'UNPACK',
]);

// Compound assignment operators (lv += 1) also read the left-hand side.
const READ_MODIFY_WRITE_OPERATORS = new Set(['+=', '-=', '*=', '/=', '&&=']);

function isReadModifyWrite(stmt, i) {
  if (READ_MODIFY_WRITE_STATEMENTS.has(stmt.keyword)) return true;
  if (stmt.keyword === 'COMPUTE') {
    return stmt.tokens.some((t, idx) => idx > 0 && READ_MODIFY_WRITE_OPERATORS.has((t.lexeme || '').toUpperCase()));
  }
  return false;
}

function isWritePosition(stmt, i) {
  const count = stmt.tokens.length;
  if (stmt.keyword === 'COMPUTE') return i === 0;
  if (WRITE_TARGET_LAST.has(stmt.keyword) && count >= 1 && i === count - 1) return true;
  if ((stmt.keyword === 'MODIFY' || stmt.keyword === 'DELETE' || stmt.keyword === 'SORT') && count >= 2 && i === 1) return true;
  return false;
}

function collectDeclaredNames(statements) {
  const names = new Set();
  for (const stmt of statements) {
    if (DECL_KEYWORDS.has(stmt.keyword) && stmt.tokens.length >= 2) {
      let tokIdx = 1;
      if (
        (stmt.tokens[1].lexeme === 'BEGIN' || stmt.tokens[1].lexeme === 'END') &&
        stmt.tokens.length >= 4 &&
        stmt.tokens[2].lexeme === 'OF'
      ) {
        if (stmt.tokens.length >= 5 && stmt.tokens[3].lexeme === 'COMMON' && stmt.tokens[4].lexeme === 'PART') {
          continue;
        }
        tokIdx = 3;
      }
      const nm = stmt.tokens[tokIdx].lexeme.toUpperCase().split('(')[0];
      if (/^[A-Z0-9_]+$/.test(nm)) names.add(nm);
    }
    for (const tok of stmt.tokens) {
      const up = tok.lexeme.toUpperCase().replace(/^@/, '');
      if ((up.startsWith('DATA(') || up.startsWith('FINAL(')) && up.endsWith(')')) {
        const off = up.startsWith('DATA(') ? 5 : 6;
        const nm = up.slice(off, -1).trim();
        if (/^[A-Z0-9_]+$/.test(nm)) names.add(nm);
      } else if ((up.startsWith('FIELD-SYMBOL(') || up.startsWith('FIELD-SYMBOLS(')) && up.endsWith(')')) {
        const off = up.startsWith('FIELD-SYMBOL(') ? 13 : 14;
        const nm = up.slice(off, -1).trim();
        if (/^[A-Z0-9_]+$/.test(nm)) names.add(nm);
      }
    }
  }
  return names;
}

function resolveDeclarations(statements, ctx) {
  for (const stmt of statements) {
    if (DECL_KEYWORDS.has(stmt.keyword) && stmt.tokens.length >= 2) {
      let tokIdx = 1;
      if (stmt.tokens[1].lexeme === 'BEGIN' || stmt.tokens[1].lexeme === 'END') {
        if (stmt.tokens.length >= 4 && stmt.tokens[2].lexeme === 'OF') {
          if (stmt.tokens.length >= 5 && stmt.tokens[3].lexeme === 'COMMON' && stmt.tokens[4].lexeme === 'PART') {
            continue;
          }
          tokIdx = 3;
        }
      }
      const tok = stmt.tokens[tokIdx];
      if (tok && !hasRefKind(tok.references, 'DA')) {
        const name = tok.lexeme.toUpperCase().split('(')[0];
        if (name && /^[A-Z0-9_]+$/.test(name)) {
          pushRef(tok.references, 'DA', `${dataScopePrefix(ctx)}\\DA:${name}`, '0', '2');
        }
      }
    }

    for (const tok of stmt.tokens) {
      const up = tok.lexeme.toUpperCase().replace(/^@/, '');
      if ((up.startsWith('DATA(') || up.startsWith('FINAL(')) && up.endsWith(')')) {
        const off = up.startsWith('DATA(') ? 5 : 6;
        const inner = up.slice(off, -1).trim();
        if (inner && !hasRefKind(tok.references, 'DA')) {
          pushRef(tok.references, 'DA', `${dataScopePrefix(ctx)}\\DA:${inner}`, '0', '3');
        }
      } else if (up.startsWith('FIELD-SYMBOL(') && up.endsWith(')')) {
        const inner = up.slice(13, -1).trim();
        if (inner && !hasRefKind(tok.references, 'DA')) {
          pushRef(tok.references, 'DA', `${dataScopePrefix(ctx)}\\DA:${inner}`, '0', '4');
        }
      }
    }
  }
}

function resolveDatabaseTables(statements, declared) {
  for (const s of statements) {
    const isRead = DB_KEYWORDS_READ.has(s.keyword);
    const isWrite = DB_KEYWORDS_WRITE.has(s.keyword);
    if (!isRead && !isWrite) continue;
    const mode = isRead ? 'E' : 'F';

    let dbName = '';
    let dbTok = null;
    if (s.keyword === 'SELECT') {
      const fromIdx = s.tokens.findIndex((t) => t.lexeme.toUpperCase() === 'FROM');
      if (fromIdx !== -1 && fromIdx + 1 < s.tokens.length) {
        dbTok = s.tokens[fromIdx + 1];
        dbName = dbTok.lexeme.toUpperCase().replace(/^@/, '');
      }
    } else if (s.keyword === 'INSERT' || s.keyword === 'DELETE') {
      const kwIdx = s.tokens.findIndex((t) => t.lexeme.toUpperCase() === 'INTO' || t.lexeme.toUpperCase() === 'FROM');
      if (kwIdx !== -1 && kwIdx + 1 < s.tokens.length) {
        dbTok = s.tokens[kwIdx + 1];
        dbName = dbTok.lexeme.toUpperCase().replace(/^@/, '');
      } else if (s.tokens.length >= 2) {
        const cand = s.tokens[1].lexeme.toUpperCase().replace(/^@/, '');
        if (!NON_DB_TARGETS.has(cand)) {
          dbTok = s.tokens[1];
          dbName = cand;
        }
      }
    } else if (s.keyword === 'UPDATE' || s.keyword === 'MODIFY') {
      if (s.tokens.length >= 2) {
        const cand = s.tokens[1].lexeme.toUpperCase().replace(/^@/, '');
        if (!NON_DB_TARGETS.has(cand)) {
          dbTok = s.tokens[1];
          dbName = cand;
        }
      }
    }

    if (dbTok && dbName && !NON_DB_TARGETS.has(dbName) && (!declared || !declared.has(dbName)) && !hasRefKind(dbTok.references, 'DA')) {
      pushRef(dbTok.references, 'DA', `\\DB:${dbName}`, '1', mode);
    }
  }
}

function resolveSystemVariables(statements) {
  for (const stmt of statements) {
    stmt.tokens.forEach((tok, i) => {
      const up = tok.lexeme.toUpperCase();
      if (!(up.startsWith('SY-') || up.startsWith('SYST-'))) return;
      const isSyst = up.startsWith('SYST-');
      const field = isSyst ? up.slice(5) : up.slice(3);
      const parent = isSyst ? '\\DA:SYST' : '\\DA:SY';
      const fullName = `${parent}\\DA:${field}`;
      if (tok.references.some((r) => r.kind === 'DA' && r.full_name === fullName)) return;
      const isTgt = (i === 0 && stmt.keyword === 'COMPUTE') || (stmt.keyword === 'CLEAR' && i >= 1);
      pushRef(tok.references, 'DA', fullName, '1', isTgt ? '6' : '5');
    });
  }
}

function resolveMessageReferences(statements) {
  for (const s of statements) {
    if (s.keyword !== 'MESSAGE') continue;
    for (const tok of s.tokens) {
      const m = /^[A-Z0-9_]+\(([A-Z0-9_/]+)\)$/i.exec(tok.lexeme);
      if (m) {
        const msgClass = m[1].toUpperCase();
        if (!hasRefKind(tok.references, 'MI')) {
          pushRef(tok.references, 'MI', `\\MI:${msgClass}`, '1', '5');
        }
        if (!hasRefKind(tok.references, 'MG')) {
          pushRef(tok.references, 'MG', `\\MG:${msgClass}`, '1', '5');
        }
      }
    }
  }
}

function resolveTypeReferences(statements, declared) {
  for (const s of statements) {
    if (s.keyword === 'CATCH') {
      for (let i = 1; i < s.tokens.length; i++) {
        const t = s.tokens[i];
        const upT = t.lexeme.toUpperCase();
        if (upT === 'INTO' || upT === '.') break;
        if (/^[A-Z0-9_/]+$/.test(upT) && !hasRefKind(t.references, 'TY')) {
          pushRef(t.references, 'TY', `\\TY:${upT}`, '1', '1');
        }
      }
      continue;
    }

    for (let i = 0; i < s.tokens.length; i++) {
      const tok = s.tokens[i];
      const up = tok.lexeme.toUpperCase();
      if ((up === 'TYPE' || up === 'LIKE') && i + 1 < s.tokens.length) {
        let typeTok = s.tokens[i + 1];
        if (typeTok.lexeme.toUpperCase() === 'REF' && i + 3 < s.tokens.length && s.tokens[i + 2].lexeme.toUpperCase() === 'TO') {
          typeTok = s.tokens[i + 3];
        }
        if (typeTok && !hasRefKind(typeTok.references, 'TY')) {
          const name = typeTok.lexeme.toUpperCase().replace(/^@/, '');
          if (/^[A-Z0-9_/]+$/.test(name) && name !== 'LINE' && name !== 'TABLE' && name !== 'OF') {
            pushRef(typeTok.references, 'TY', `\\TY:${name}`, '1', '1');
          }
        }
      }
      if (up.startsWith('CX_SY_') && (!declared || !declared.has(up)) && !hasRefKind(tok.references, 'TY') && !hasRefKind(tok.references, 'DA')) {
        pushRef(tok.references, 'TY', `\\TY:${up}`, '1', '1');
      }
    }
  }
}

function resolveVariableAccesses(statements, declared, ctx) {
  if (declared.size === 0) return;
  for (const stmt of statements) {
    stmt.tokens.forEach((tok, i) => {
      let up = tok.lexeme.toUpperCase();
      if (up.endsWith('[]')) up = up.slice(0, -2);
      const arrow = up.indexOf('->');
      if (arrow >= 0) up = up.slice(0, arrow);
      // Offset and length accesses (lv+4, lv(2), ls-comp) address the same object
      up = cutAtParen(up).split('+')[0];
      const hasHyphen = up.includes('-');
      const root = hasHyphen ? up.split('-')[0] : up;
      if (!declared.has(root) || !/^[A-Z0-9_]+$/.test(root)) return;
      if (isStringToken(up)) return;
      if (hasRefKind(tok.references, 'DA') || hasRefKind(tok.references, 'TY')) return;
      if (DECL_KEYWORDS.has(stmt.keyword) && i === 1) return;
      if (i > 0) {
        const prev = stmt.tokens[i - 1].lexeme.toUpperCase();
        if (prev === 'TYPE' || prev === 'LIKE') return;
      }
      // An attribute write (lo->attr = 1) only reads the reference itself
      const mode = arrow >= 0 || !isWritePosition(stmt, i) ? '5' : '6';
      if (hasHyphen) {
        const comp = up.slice(root.length + 1);
        pushRef(tok.references, 'DA', `${dataScopePrefix(ctx)}\\DA:${root}\\DA:${comp}`, '1', mode);
        pushRef(tok.references, 'DA', `${dataScopePrefix(ctx)}\\DA:${root}`, '1', mode === '6' ? 'D' : mode);
      } else {
        pushRef(tok.references, 'DA', `${dataScopePrefix(ctx)}\\DA:${root}`, '1', mode);
      }
    });
  }
}

function resolveObjectVariableTypes(statements) {
  const map = new Map();
  for (const stmt of statements) {
    const text = stmt.tokens.map((t) => t.lexeme).join(' ');
    const m = /\b(?:DATA|FINAL)\s*\(\s*([A-Za-z0-9_]+)\s*\)\s*=\s*(?:NEW|CAST)\s+([A-Za-z0-9_/]+)/i.exec(text)
      || /\b(?:DATA|FINAL)\s+([A-Za-z0-9_]+)\s+TYPE\s+REF\s+TO\s+([A-Za-z0-9_/]+)/i.exec(text);
    if (m) {
      map.set(m[1].toUpperCase(), m[2].toUpperCase());
    }
  }
  if (map.size === 0) return;
  for (const stmt of statements) {
    for (const tok of stmt.tokens) {
      const raw = (tok.lexeme || '').toUpperCase().replace(/^@/, '');
      const up = cutAtParen(raw).split('-')[0].split('->')[0].replace(/\[\]$/, '');
      if (map.has(up) && !hasRefKind(tok.references, 'TY')) {
        pushRef(tok.references, 'TY', `\\TY:${map.get(up)}`, '1', '1');
      }
    }
  }
}

function systemVarFullName(lexeme) {
  const up = (lexeme || '').toUpperCase();
  if (up.startsWith('SY-')) return `\\DA:SY\\DA:${up.slice(3)}`;
  if (up.startsWith('SYST-')) return `\\DA:SYST\\DA:${up.slice(5)}`;
  return '';
}

function methodOwnerName(tok, ctx) {
  const up = (tok.lexeme || '').toUpperCase();
  const staticAt = up.indexOf('=>');
  if (staticAt >= 0) {
    const cls = up.slice(0, staticAt).replace(/^@/, '').trim();
    if (/^[A-Z0-9_/]+$/.test(cls)) return cls;
  }
  return ctx.className;
}

function componentPath(tok, atc) {
  const up = (tok.lexeme || '').toUpperCase();
  const dash = up.indexOf('-');
  if (dash <= 0) return '';
  const root = up.slice(0, dash);
  if (root !== atc.name) return '';
  const comp = up.slice(dash + 1);
  if (!comp || !/^[A-Z0-9_]+$/.test(comp)) return '';
  return `\\DA:${comp}`;
}

function buildFullName(atc, tok, ctx) {
  if (atc.kind === 'DA') {
    if (atc.isTable) return `\\DB:${atc.name}`;
    if (BUILTIN_CONSTANTS.has(atc.name)) return `\\DA:${atc.name}`;
    const sysName = systemVarFullName(tok.lexeme);
    if (sysName) return sysName;
    const comp = componentPath(tok, atc);
    const base = `${dataScopePrefix(ctx)}\\DA:${atc.name}`;
    return comp ? `${base}${comp}` : base;
  }
  if (atc.kind === 'TY') return `\\TY:${atc.name}`;
  if (atc.kind === 'ME') {
    const owner = atc.resolved && atc.ooName ? atc.ooName : methodOwnerName(tok, ctx);
    return owner ? `\\TY:${owner}\\ME:${atc.name}` : `\\ME:${atc.name}`;
  }
  if (atc.kind === 'FO') return `\\FO:${atc.name}`;
  return '';
}

function refSymbol(ref) {
  const full = ref.full_name || '';
  let match;
  if (ref.kind === 'DA') {
    match = /\\DA:([^\\]+)/.exec(full);
    if (match) return match[1];
    match = /\\DB:([^\\]+)/.exec(full);
    return match ? match[1] : '';
  }
  if (ref.kind === 'TY') {
    match = /\\TY:([^\\]+)/.exec(full);
    return match ? match[1] : '';
  }
  if (ref.kind === 'ME') {
    match = /\\ME:([^\\]+)/.exec(full);
    return match ? match[1] : '';
  }
  return '';
}

function classifyUsage(stmt, tokenIndex, atc, tok) {
  if (atc.kind === 'DA' && atc.isTable) {
    if (DB_KEYWORDS_READ.has(stmt.keyword)) return { grade: '1', mode: 'E' };
    if (DB_KEYWORDS_WRITE.has(stmt.keyword)) return { grade: '1', mode: 'F' };
    return { grade: '1', mode: '5' };
  }
  if (atc.kind === 'DA') {
    if (BUILTIN_CONSTANTS.has(atc.name)) return { grade: '1', mode: '5' };
    const up = (tok.lexeme || '').toUpperCase().replace(/^@/, '');
    if (up.startsWith('DATA(') || up.startsWith('FINAL(')) return { grade: '0', mode: '3' };
    if (up.startsWith('FIELD-SYMBOL(')) return { grade: '0', mode: '4' };
    if (DECL_KEYWORDS.has(stmt.keyword) && tokenIndex === 1) return { grade: '0', mode: '2' };
    // SAP reports a write to an object attribute as a read of the reference itself:
    // the component carries the write, the reference value is never replaced.
    if (up.includes('->')) return { grade: '1', mode: '5' };
    if (atc.refType === 'Write To' || isWritePosition(stmt, tokenIndex)) {
      return { grade: '1', mode: isReadModifyWrite(stmt, tokenIndex) ? '7' : '6' };
    }
    return { grade: '1', mode: '5' };
  }
  if (atc.kind === 'TY') return { grade: '1', mode: '1' };
  return { grade: '1', mode: '5' };
}

function hasReference(refs, kind, fullName) {
  return refs.some((r) => r.kind === kind && r.full_name === fullName);
}

/**
 * Attaches the references resolved by abaplint to statement tokens.
 */
export function attachAbaplintReferences(statements, index, rowOffset, ctx) {
  const resolved = new Set();
  if (!index || index.size === 0) return resolved;
  const offset = typeof rowOffset === 'number' && rowOffset > 0 ? rowOffset : 0;

  for (const stmt of statements) {
    stmt.tokens.forEach((tok, tokenIndex) => {
      const row = tok.position.line + offset;
      const startCol = tok.position.column + 1;
      const span = Math.max(tok.lexeme ? tok.lexeme.length : 1, 1);
      const hits = [];
      for (let col = startCol; col < startCol + span; col++) {
        const found = index.get(`${row}:${col}`);
        if (found) hits.push(...found);
      }
      if (hits.length === 0) return;

      const symbols = new Set();
      for (const atc of hits) {
        if (atc.kind === 'DA' && BUILTIN_LITERALS.has(atc.name)) continue;
        symbols.add(`${atc.kind}:${atc.name}`);
      }
      if (symbols.size === 0) return;

      tok.references = tok.references.filter((r) => {
        if (r.usage_grade !== '1') return true;
        return !symbols.has(`${r.kind}:${refSymbol(r)}`);
      });

      for (const atc of hits) {
        if (atc.kind === 'DA' && BUILTIN_LITERALS.has(atc.name)) continue;
        const fullName = buildFullName(atc, tok, ctx);
        if (!fullName) continue;
        if (hasReference(tok.references, atc.kind, fullName)) continue;
        const usage = classifyUsage(stmt, tokenIndex, atc, tok);
        pushRef(tok.references, atc.kind, fullName, usage.grade, usage.mode);
      }
      resolved.add(tok);
    });
  }
  return resolved;
}

/**
 * Single unified pipeline: enriches Skylint statements with compiler references.
 * Resolves symbol usages via abaplint SyntaxLogic and synthesizes definitions and external symbols.
 */
export async function enrichStatements(
  statements,
  fullSource,
  objectName = '',
  methodName = '',
  absOffset = 0,
  options = {},
) {
  if (statements.length === 0) return;
  if (typeof methodName !== 'string') methodName = '';
  if (/^\d+$/.test(methodName.trim())) {
    absOffset = methodName;
    methodName = '';
  }
  const sn = ((objectName || '').trim() || 'ZSKYLINT_TEST').toUpperCase();

  const ctx = {
    className: sn,
    methodName: (methodName || '').toUpperCase(),
  };

  const declared = collectDeclaredNames(statements);

  // 1. Synthesize definitions, external fallbacks, and root variable access
  resolveDeclarations(statements, ctx);
  resolveDatabaseTables(statements, declared);
  resolveSystemVariables(statements);
  resolveMessageReferences(statements);
  resolveTypeReferences(statements, declared);
  resolveVariableAccesses(statements, declared, ctx);
  resolveObjectVariableTypes(statements);

  // 2. Delegate deep symbol usage resolution to abaplint SyntaxLogic
  const collected = await collectAbaplintReferences(
    fullSource,
    options.objectName || objectName,
    options.objectKind,
  );
  if (collected && collected.index && collected.index.size > 0) {
    attachAbaplintReferences(statements, collected.index, absOffset, ctx);
  }
}
