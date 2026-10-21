import {
  DECL_KEYWORDS,
  pushRef,
  hasRefKind,
  isStringToken,
  dataScopePrefix,
  cutAtParen,
} from './parser.mjs';

const NON_DB_TARGETS = new Set([
  'TABLE', 'REPORT', 'TEXTPOOL', 'DYNPRO', 'DATASET', 'MEMORY', 'INITIAL', 'LINE', 'LINES', 'SCREEN', 'PROGRAM',
]);

const DB_KEYWORDS_READ = new Set(['SELECT']);
const DB_KEYWORDS_WRITE = new Set(['UPDATE', 'MODIFY', 'INSERT', 'DELETE']);

const WRITE_TARGET_LAST = new Set([
  'CLEAR', 'FREE', 'REFRESH', 'MOVE', 'APPEND', 'INSERT', 'ADD', 'SUBTRACT', 'MULTIPLY', 'DIVIDE',
]);

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

function resolveInlineDeclarations(statements, ctx) {
  for (const s of statements) {
    for (const tok of s.tokens) {
      const up = tok.lexeme.toUpperCase().replace(/^@/, '');
      if (up.startsWith('DATA(') && up.endsWith(')')) {
        const inner = up.slice(5, -1).trim();
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

function resolveTypeReferences(statements) {
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
          if (/^[A-Z0-9_/]+$/.test(name) && name !== 'LINE' && name !== 'TABLE') {
            pushRef(typeTok.references, 'TY', `\\TY:${name}`, '1', '1');
          }
        }
      }
    }
  }
}

function resolveMethodCalls(statements, ctx) {
  for (const s of statements) {
    for (const tok of s.tokens) {
      const up = tok.lexeme.toUpperCase();
      if (isStringToken(up) || hasRefKind(tok.references, 'ME')) continue;

      if (up.includes('=>')) {
        const at = up.indexOf('=>');
        const cls = up.slice(0, at).replace(/^@/, '');
        if (/^[A-Z0-9_/]+$/.test(cls)) {
          if (!hasRefKind(tok.references, 'TY')) pushRef(tok.references, 'TY', `\\TY:${cls}`, '1', undefined);
          const meth = cutAtParen(up.slice(at + 2));
          if (meth && /^[A-Z0-9_]+$/.test(meth)) {
            pushRef(tok.references, 'ME', `\\TY:${cls}\\ME:${meth}`, '1', '5');
          }
        }
      } else if (up.includes('->') && (up.includes('(') || s.keyword === '+CALL_METHOD' || s.keyword === 'CALL')) {
        const at = up.indexOf('->');
        const meth = cutAtParen(up.slice(at + 2));
        if (meth && /^[A-Z0-9_]+$/.test(meth)) {
          pushRef(tok.references, 'ME', `\\TY:${ctx.className}\\ME:${meth}`, '1', '5');
        }
      }
    }
  }
}

function resolveExplicitDeclarations(statements, ctx) {
  for (const s of statements) {
    addExplicitDeclarationRefs(s, ctx);
  }
}

function addExplicitDeclarationRefs(stmt, ctx) {
  if (!DECL_KEYWORDS.has(stmt.keyword)) return;
  if (stmt.tokens.length >= 2) {
    let tokIdx = 1;
    if (stmt.tokens[1].lexeme === 'BEGIN' || stmt.tokens[1].lexeme === 'END') {
      if (stmt.tokens.length >= 4 && stmt.tokens[2].lexeme === 'OF') {
        if (stmt.tokens.length >= 5 && stmt.tokens[3].lexeme === 'COMMON' && stmt.tokens[4].lexeme === 'PART') {
          return;
        }
        tokIdx = 3;
      }
    }
    const tok = stmt.tokens[tokIdx];
    if (!tok || hasRefKind(tok.references, 'DA')) return;
    const name = tok.lexeme.toUpperCase().split('(')[0];
    if (name && /^[A-Z0-9_]+$/.test(name)) {
      pushRef(tok.references, 'DA', `${dataScopePrefix(ctx)}\\DA:${name}`, '0', '2');
    }
  }
}

function addSystemVarReferences(stmt) {
  stmt.tokens.forEach((tok, i) => {
    const up = tok.lexeme.toUpperCase();
    if (!(up.startsWith('SY-') || up.startsWith('SYST-'))) return;
    const isSyst = up.startsWith('SYST-');
    const field = isSyst ? up.slice(5) : up.slice(3);
    const parent = isSyst ? '\\DA:SYST' : '\\DA:SY';
    const fullName = `${parent}\\DA:${field}`;
    const covered = tok.references.some((r) => r.kind === 'DA' && r.full_name === fullName);
    if (covered) return;
    const isTgt = (i === 0 && stmt.keyword === 'COMPUTE') || (stmt.keyword === 'CLEAR' && i >= 1);
    pushRef(tok.references, 'DA', fullName, '1', isTgt ? '6' : '5');
  });
}

function addFallbackTypeReferences(stmt, declared) {
  for (const tok of stmt.tokens) {
    const up = tok.lexeme.toUpperCase();
    if (up.startsWith('CX_SY_') && (!declared || !declared.has(up)) && !hasRefKind(tok.references, 'TY') && !hasRefKind(tok.references, 'DA')) {
      pushRef(tok.references, 'TY', `\\TY:${up}`, '1', '1');
    }
  }
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
      if (up.startsWith('DATA(') && up.endsWith(')')) {
        const nm = up.slice(5, -1);
        if (/^[A-Z0-9_]+$/.test(nm)) names.add(nm);
      } else if (up.startsWith('FIELD-SYMBOL(') && up.endsWith(')')) {
        const nm = up.slice(13, -1);
        if (/^[A-Z0-9_]+$/.test(nm)) names.add(nm);
      }
    }
  }
  return names;
}

function isWritePosition(stmt, i) {
  const count = stmt.tokens.length;
  if (stmt.keyword === 'COMPUTE') return i === 0;
  if (WRITE_TARGET_LAST.has(stmt.keyword) && i === count - 1) return true;
  if ((stmt.keyword === 'MODIFY' || stmt.keyword === 'DELETE' || stmt.keyword === 'SORT') && i === 1) return true;
  return false;
}

function collectObjectVariableTypes(statements) {
  const map = new Map();
  if (!statements) return map;
  for (const stmt of statements) {
    const text = stmt.tokens.map((t) => t.lexeme).join(' ');
    const m = /\b(?:DATA|FINAL)\s*\(\s*([A-Za-z0-9_]+)\s*\)\s*=\s*(?:NEW|CAST)\s+([A-Za-z0-9_/]+)/i.exec(text)
      || /\b(?:DATA|FINAL)\s+([A-Za-z0-9_]+)\s+TYPE\s+REF\s+TO\s+([A-Za-z0-9_/]+)/i.exec(text);
    if (m) {
      map.set(m[1].toUpperCase(), m[2].toUpperCase());
    }
  }
  return map;
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

function addVariableTypeReferences(statements, objVarTypes) {
  if (!objVarTypes || objVarTypes.size === 0) return;
  for (const stmt of statements) {
    for (const tok of stmt.tokens) {
      const up = tok.lexeme.toUpperCase().split('-')[0].split('->')[0].replace(/\[\]$/, '');
      if (objVarTypes.has(up) && !hasRefKind(tok.references, 'TY')) {
        pushRef(tok.references, 'TY', `\\TY:${objVarTypes.get(up)}`, '1', '1');
      }
    }
  }
}

function addShadowedDataReads(stmt, declared, ctx) {
  if (declared.size === 0) return;
  stmt.tokens.forEach((tok, i) => {
    let up = tok.lexeme.toUpperCase();
    if (up.endsWith('[]')) up = up.slice(0, -2);
    const arrow = up.indexOf('->');
    if (arrow >= 0) up = up.slice(0, arrow);
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
    const mode = isWritePosition(stmt, i) ? '6' : '5';
    if (hasHyphen) {
      const comp = up.slice(root.length + 1);
      pushRef(tok.references, 'DA', `${dataScopePrefix(ctx)}\\DA:${root}\\DA:${comp}`, '1', mode);
      pushRef(tok.references, 'DA', `${dataScopePrefix(ctx)}\\DA:${root}`, '1', mode === '6' ? 'D' : mode);
    } else {
      pushRef(tok.references, 'DA', `${dataScopePrefix(ctx)}\\DA:${root}`, '1', mode);
    }
  });
}

function flatString(s) {
  return (s + '').replace(/[|]/g, ' ').replace(/[\r\n]+/g, ' ');
}

function shortIdent(fname) {
  const tail = (fname + '').split('\\').pop().split('->').pop();
  const cut = tail.lastIndexOf(':');
  return (cut >= 0 ? tail.slice(cut + 1) : tail).toUpperCase();
}

function rowMatches(tok, row, rangeOnly) {
  const col = row.col;
  if (
    (col >= tok.position.column && col < tok.position.column + tok.lexeme.length) ||
    (col - 1 >= tok.position.column && col - 1 < tok.position.column + tok.lexeme.length)
  ) {
    return true;
  }
  if (rangeOnly) return false;
  const core = tok.lexeme.toUpperCase().replace(/^@/, '');
  const short = shortIdent(row.fname);
  if (!short) return false;
  if (core === short) return true;
  if (core.startsWith(short)) {
    const next = core[short.length];
    if (next !== undefined && !/[A-Z0-9_]/.test(next)) return true;
  }
  const arrow = '->' + short;
  if (core === arrow || core === arrow + '(') return true;
  if (core.endsWith(arrow) || core.endsWith(arrow + '(')) return true;
  return false;
}

function attachRow(statements, row, rangeOnly) {
  if (row.kind !== 'ME' && row.kind !== 'DA' && row.kind !== 'TY') return false;
  let attached = false;
  for (const stmt of statements) {
    for (const tok of stmt.tokens) {
      if (tok.position.line !== row.rel) continue;
      if (!rowMatches(tok, row, rangeOnly)) continue;
      tok.references.push({
        kind: row.kind,
        full_name: row.fname,
        usage_grade: row.grade,
        usage_mode: row.mode,
      });
      attached = true;
      break;
    }
  }
  return attached;
}

export async function enrichStatements(
  statements,
  fullSource,
  objectName = '',
  methodName = '',
  absOffset = 0,
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

  resolveDatabaseTables(statements, declared);
  resolveExplicitDeclarations(statements, ctx);
  resolveInlineDeclarations(statements, ctx);
  resolveTypeReferences(statements);
  resolveMethodCalls(statements, ctx);

  const objVarTypes = collectObjectVariableTypes(statements);
  resolveMessageReferences(statements);

  for (const stmt of statements) {
    addExplicitDeclarationRefs(stmt, ctx);
    addSystemVarReferences(stmt);
    addFallbackTypeReferences(stmt, declared);
    addShadowedDataReads(stmt, declared, ctx);
  }

  addVariableTypeReferences(statements, objVarTypes);
}
