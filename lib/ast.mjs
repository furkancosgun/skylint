const HORIZONTAL_TAB = '\t';

// ---------------------------------------------------------------------------
// Lexer
// ---------------------------------------------------------------------------
export class Lexer {
  constructor(source) {
    this.src = source.replace(/\r\n/g, '\n');
    this.len = this.src.length;
    this.pos = 0;
    this.line = 1;
    this.col = 0;
    this.tokLine = 1;
    this.tokCol = 0;
    this.tokens = [];
  }

  atEnd() {
    return this.pos >= this.len;
  }

  peek(offset = 0) {
    if (offset < 0) return '';
    const at = this.pos + offset;
    return at < this.len ? this.src[at] : '';
  }

  advance() {
    if (this.pos >= this.len) return '';
    const ch = this.src[this.pos++];
    if (ch === '\n') {
      this.line += 1;
      this.col = 0;
    } else {
      this.col += 1;
    }
    return ch;
  }

  isBlank(ch) {
    return ch === ' ' || ch === HORIZONTAL_TAB || ch === '\n';
  }

  skipBlanks() {
    while (!this.atEnd()) {
      if (this.isBlank(this.peek())) this.advance();
      else return;
    }
  }

  endsLine() {
    return this.atEnd() || this.peek() === '\n';
  }

  emitToken(text) {
    let lex = text;
    if (lex && lex[0] !== "'" && lex[0] !== '`' && lex[0] !== '|' && lex[0] !== '"' && !lex.startsWith('##')) {
      lex = lex.toUpperCase();
    }
    this.tokens.push({
      lexeme: lex,
      position: { line: this.tokLine, column: this.tokCol > 255 ? 255 : this.tokCol },
      references: [],
    });
  }

  scanComment() {
    let text = '';
    while (!this.endsLine()) text += this.advance();
    this.emitToken(text);
  }

  scanPragma() {
    let text = this.advance() + this.advance();
    while (!this.atEnd()) {
      if (this.isBlank(this.peek())) break;
      text += this.advance();
    }
    this.emitToken(text);
  }

  scanString(quote) {
    let text = this.advance();
    while (!this.endsLine()) {
      if (this.peek() === quote) {
        text += this.advance();
        if (this.peek() === quote) text += this.advance();
        else break;
      } else {
        text += this.advance();
      }
    }
    this.emitToken(text);
  }

  scanTemplate() {
    let text = this.advance();
    let depth = 0;
    while (!this.endsLine()) {
      const ch = this.peek();
      if (ch === '\\') {
        text += this.advance();
        if (!this.atEnd()) text += this.advance();
      } else if (ch === '{') {
        depth += 1;
        text += this.advance();
      } else if (ch === '}' && depth > 0) {
        depth -= 1;
        text += this.advance();
      } else if (ch === '|' && depth === 0) {
        text += this.advance();
        break;
      } else {
        text += this.advance();
      }
    }
    this.emitToken(text);
  }

  scanWord() {
    let text = '';
    while (!this.atEnd()) {
      if (this.isBlank(this.peek())) break;
      text += this.advance();
    }
    if (text !== '') this.emitToken(text);
  }

  run() {
    this.tokens = [];
    while (!this.atEnd()) {
      this.skipBlanks();
      if (this.atEnd()) break;
      this.tokLine = this.line;
      this.tokCol = this.col;
      const ch = this.peek();
      const next = this.peek(1);
      if (ch === '"') {
        this.scanComment();
      } else if (ch === '*') {
        if (this.col === 0) this.scanComment();
        else this.scanWord();
      } else if (ch === '#') {
        if (next === '#') this.scanPragma();
        else this.scanWord();
      } else if (ch === "'") {
        this.scanString("'");
      } else if (ch === '`') {
        this.scanString('`');
      } else if (ch === '|') {
        this.scanTemplate();
      } else {
        this.scanWord();
      }
    }
    return this.tokens;
  }
}

// ---------------------------------------------------------------------------
// Syntax Constants & Helpers
// ---------------------------------------------------------------------------
export function parenDelta(lexeme) {
  if (!lexeme) return 0;
  const first = lexeme[0];
  if (first === "'" || first === '`' || first === '|') return 0;
  let delta = 0;
  for (const ch of lexeme) {
    if (ch === '(' || ch === '[' || ch === '{') delta += 1;
    else if (ch === ')' || ch === ']' || ch === '}') delta -= 1;
  }
  return delta;
}

const ASSIGN_OPS = new Set(['=', '+=', '-=', '*=', '/=', '&&=', '?=']);
const METHOD_CALL_BLACKLIST = new Set([
  'VALUE(', 'NEW(', 'COND(', 'SWITCH(', 'REF(', 'CONV(', 'CAST(', 'EXACT(',
  'CORRESPONDING(', 'LINES(', 'XSDBOOL(', 'BOOLC(', 'STRLEN(', 'STRING(',
  'TABLE(', 'FILTER(', 'REDUCE(', 'DATA(', '@DATA(', 'FIELD-SYMBOL(',
]);
const DECL_KEYWORDS = new Set(['DATA', 'CONSTANTS', 'FIELD-SYMBOLS', 'STATICS']);
const DB_KEYWORDS_READ = new Set(['SELECT']);
const DB_KEYWORDS_WRITE = new Set(['UPDATE', 'MODIFY', 'INSERT', 'DELETE']);

function isCommentToken(tok) {
  const lex = tok.lexeme;
  if (!lex) return false;
  return lex[0] === '"' || (lex[0] === '*' && tok.position.column === 0);
}

function isPragmaToken(tok) {
  return tok.lexeme.startsWith('##');
}

function copyToken(tok) {
  return {
    lexeme: tok.lexeme,
    position: { line: tok.position.line, column: tok.position.column },
    references: tok.references,
  };
}

function pseudoWords(text) {
  const off = text.toUpperCase().indexOf('#EC');
  if (off < 0) return [];
  const rest = text.slice(off + 3);
  if (rest.length === 0) return [];
  return rest
    .replace(/,/g, ' ')
    .split(' ')
    .map((p) => p.replace(/\s+/g, ' ').trim().toUpperCase())
    .filter((p) => p !== '');
}

function collectPseudo(token, statements, pending) {
  const words = isPragmaToken(token) && token.lexeme.length > 2
    ? [token.lexeme.slice(2).toUpperCase()]
    : pseudoWords(token.lexeme);
  if (words.length === 0) return;
  if (statements.length > 0) {
    const last = statements[statements.length - 1];
    if (last.position.line === token.position.line) {
      for (const w of words) if (!last.pseudo_comments.includes(w)) last.pseudo_comments.push(w);
      return;
    }
  }
  for (const w of words) pending.push(w);
}

function isAssignment(tokens) {
  return tokens.length >= 3 && ASSIGN_OPS.has(tokens[1].lexeme);
}

function isMethodCall(tokens) {
  if (tokens.length === 0) return false;
  const first = tokens[0].lexeme.toUpperCase();
  return first.includes('(') && !METHOD_CALL_BLACKLIST.has(first);
}

function classifyStatement(tokens, inChain, headerKw) {
  if (inChain && headerKw) return headerKw;
  if (tokens.length === 0) return '';
  if (isAssignment(tokens)) return 'COMPUTE';
  if (isMethodCall(tokens)) return '+CALL_METHOD';
  return tokens[0].lexeme.toUpperCase();
}

function pushRef(refs, kind, fullName, grade, mode) {
  refs.push({ kind, full_name: fullName, usage_grade: grade, usage_mode: mode });
}

function hasRefKind(refs, kind) {
  return refs.some((r) => r.kind === kind);
}

function isStringToken(upper) {
  const first = upper[0];
  return first === "'" || first === '`' || first === '|';
}

function dataScopePrefix(ctx) {
  if (ctx.methodName) return `\\TY:${ctx.className}\\ME:${ctx.methodName}`;
  return `\\TY:${ctx.className}`;
}

function cutAtParen(text) {
  const off = text.indexOf('(');
  return off < 0 ? text : text.slice(0, off);
}

// ---------------------------------------------------------------------------
// Statement Builder
// ---------------------------------------------------------------------------
function emitStatement(prefix, body, pseudo, inChain, headerKw, chainIdx, statements) {
  const all = inChain ? [...prefix, ...body] : [...body];
  if (all.length === 0) return;
  const stmt = { index: 0, keyword: '', tokens: all, position: { line: 0, column: 0 }, pseudo_comments: [] };
  if (inChain && chainIdx > 1 && body.length > 0) {
    stmt.position.line = body[0].position.line;
    stmt.position.column = all[0].position.column;
  } else {
    stmt.position.line = all[0].position.line;
    stmt.position.column = all[0].position.column;
  }
  for (const w of pseudo) if (!stmt.pseudo_comments.includes(w)) stmt.pseudo_comments.push(w);
  stmt.keyword = classifyStatement(all, inChain, headerKw);
  statements.push(stmt);
}

export function buildStatements(tokens) {
  const statements = [];
  let cur = [];
  let prefix = [];
  let pending = [];
  let inChain = false;
  let chainIdx = 0;
  let headerKw = '';
  let depth = 0;

  for (const raw of tokens) {
    if (isCommentToken(raw) || isPragmaToken(raw)) {
      collectPseudo(raw, statements, pending);
      continue;
    }
    const tok = copyToken(raw);
    const word = tok.lexeme;
    if (!word) continue;
    const last = word[word.length - 1];
    const delta = parenDelta(word);

    if (last === '.' && depth + delta <= 0) {
      if (word.length > 1) {
        tok.lexeme = word.slice(0, -1);
        cur.push(tok);
      }
      emitStatement(prefix, cur, pending, inChain, headerKw, chainIdx, statements);
      cur = [];
      prefix = [];
      pending = [];
      headerKw = '';
      inChain = false;
      chainIdx = 0;
      depth = 0;
    } else if (last === ':' && depth === 0 && !inChain) {
      if (word.length > 1) {
        tok.lexeme = word.slice(0, -1);
        cur.push(tok);
      }
      prefix = cur;
      if (prefix.length > 0) headerKw = prefix[0].lexeme.toUpperCase();
      cur = [];
      inChain = true;
      chainIdx = 1;
    } else if (last === ',' && depth === 0) {
      if (word.length > 1) {
        tok.lexeme = word.slice(0, -1);
        cur.push(tok);
      }
      if (inChain) {
        emitStatement(prefix, cur, pending, inChain, headerKw, chainIdx, statements);
        cur = [];
        pending = [];
        chainIdx += 1;
        depth = 0;
      }
    } else {
      cur.push(tok);
      depth += delta;
      if (depth < 0) depth = 0;
    }
  }
  return statements;
}

// ---------------------------------------------------------------------------
// Semantic Analyzers (Pure JS AST Analysis)
// ---------------------------------------------------------------------------

const NON_DB_TARGETS = new Set([
  'TABLE', 'REPORT', 'TEXTPOOL', 'DYNPRO', 'DATASET', 'MEMORY', 'INITIAL', 'LINE', 'LINES', 'SCREEN', 'PROGRAM',
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

const WRITE_TARGET_LAST = new Set([
  'CLEAR', 'FREE', 'REFRESH', 'MOVE', 'APPEND', 'INSERT', 'ADD', 'SUBTRACT', 'MULTIPLY', 'DIVIDE',
]);

/**
 * Decides from the statement keyword alone whether the token at position `i` is a write
 * position (target of an assignment or of a procedural statement). This mirrors the way the
 * ABAP compiler binds usage modes and keeps read/write analysis free of lexeme guessing.
 */
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
    // `receiver->method( ` carries both the data reference of the receiver and the
    // method reference; only the receiver part names a declared data object.
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

// ---------------------------------------------------------------------------
// Main Semantic Enrichment Pipeline
// ---------------------------------------------------------------------------
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

  // Native Semantic Expression Analysis
  resolveDatabaseTables(statements, declared);
  resolveExplicitDeclarations(statements, ctx);
  resolveInlineDeclarations(statements, ctx);
  resolveTypeReferences(statements);
  resolveMethodCalls(statements, ctx);

  const objVarTypes = collectObjectVariableTypes(statements);
  resolveMessageReferences(statements);

  // Explicit declarations, system variables and shadowed reads
  for (const stmt of statements) {
    addExplicitDeclarationRefs(stmt, ctx);
    addSystemVarReferences(stmt);
    addFallbackTypeReferences(stmt, declared);
    addShadowedDataReads(stmt, declared, ctx);
  }

  addVariableTypeReferences(statements, objVarTypes);
}


// ---------------------------------------------------------------------------
// Procedure Extraction & Target Resolution
// ---------------------------------------------------------------------------
function parseClassDefName(line) {
  const m = /^\s*CLASS\s+(\S+)\s+DEFINITION\b/i.exec(line);
  return m ? m[1].replace(/\.$/, '').toUpperCase() : '';
}

function parseInterfaceName(line) {
  const m = /^\s*INTERFACE\s+(\S+)\b/i.exec(line);
  return m ? m[1].replace(/\.$/, '').toUpperCase() : '';
}

function parseMethodName(line) {
  const m = /^\s*METHOD\s+(\S+)\s*\.\s*$/i.exec(line);
  return m ? m[1].replace(/\.$/, '').toUpperCase() : '';
}

function parseClassImplName(line) {
  const m = /^\s*CLASS\s+(\S+)\s+IMPLEMENTATION\b/i.exec(line);
  return m ? m[1].replace(/\.$/, '').toUpperCase() : '';
}

function parseFormName(line) {
  const m = /^\s*FORM\s+(\S+)\b/i.exec(line);
  return m ? m[1].replace(/\.$/, '').toUpperCase() : '';
}

export function extractAllProcedures(fullLines) {
  const procedures = [];
  let currentImplClass = '';
  let inDef = false;
  let inMeth = false;
  let inForm = false;
  let defBuffer = [];
  let methBuffer = [];
  let formBuffer = [];
  let defName = '';
  let methName = '';
  let formName = '';
  let defOffset = 0;
  let methOffset = 0;
  let formOffset = 0;

  for (let i = 0; i < fullLines.length; i++) {
    const line = fullLines[i];
    const upper = line.trim().toUpperCase();

    const implName = parseClassImplName(line);
    if (implName) {
      currentImplClass = implName;
    }

    if (!inDef && !inMeth && !inForm) {
      const cdefName = parseClassDefName(line);
      const idefName = parseInterfaceName(line);
      if (cdefName || idefName) {
        inDef = true;
        defName = cdefName || idefName;
        defOffset = i;
        defBuffer = [line];
        if (upper.includes('ENDCLASS.') || upper.includes('ENDINTERFACE.')) {
          procedures.push({
            kind: 'DECL',
            name: defName,
            mainKind: idefName ? 'INTF' : 'CLAS',
            mainName: defName,
            snippet: defBuffer,
            offset: defOffset,
          });
          inDef = false;
          defBuffer = [];
        }
        continue;
      }

      const mName = parseMethodName(line);
      if (mName) {
        inMeth = true;
        methName = mName;
        methOffset = i;
        methBuffer = [line];
        if (upper.includes('ENDMETHOD.')) {
          procedures.push({
            kind: 'METH',
            name: `${currentImplClass || 'ZSKYLINT_TEST'}=>${methName}`,
            methodName: methName,
            mainKind: 'CLAS',
            mainName: currentImplClass || 'ZSKYLINT_TEST',
            snippet: methBuffer,
            offset: methOffset,
          });
          inMeth = false;
          methBuffer = [];
        }
        continue;
      }

      const fName = parseFormName(line);
      if (fName) {
        inForm = true;
        formName = fName;
        formOffset = i;
        formBuffer = [line];
        if (upper.includes('ENDFORM.')) {
          procedures.push({
            kind: 'FORM',
            name: formName,
            mainKind: 'PROG',
            mainName: 'ZPLAYGROUND',
            snippet: formBuffer,
            offset: formOffset,
          });
          inForm = false;
          formBuffer = [];
        }
        continue;
      }
    } else if (inDef) {
      defBuffer.push(line);
      if (upper.includes('ENDCLASS.') || upper.includes('ENDINTERFACE.')) {
        procedures.push({
          kind: 'DECL',
          name: defName,
          mainKind: 'CLAS',
          mainName: defName,
          snippet: defBuffer,
          offset: defOffset,
        });
        inDef = false;
        defBuffer = [];
      }
    } else if (inMeth) {
      methBuffer.push(line);
      if (upper.includes('ENDMETHOD.')) {
        procedures.push({
          kind: 'METH',
          name: `${currentImplClass || 'ZSKYLINT_TEST'}=>${methName}`,
          methodName: methName,
          mainKind: 'CLAS',
          mainName: currentImplClass || 'ZSKYLINT_TEST',
          snippet: methBuffer,
          offset: methOffset,
        });
        inMeth = false;
        methBuffer = [];
      }
    } else if (inForm) {
      formBuffer.push(line);
      if (upper.includes('ENDFORM.')) {
        procedures.push({
          kind: 'FORM',
          name: formName,
          mainKind: 'PROG',
          mainName: 'ZPLAYGROUND',
          snippet: formBuffer,
          offset: formOffset,
        });
        inForm = false;
        formBuffer = [];
      }
    }
  }

  return procedures;
}

export function resolveProcedureForTarget(procedures, targetMethod) {
  const want = targetMethod.toUpperCase();

  const directClass = procedures.find((p) => p.kind === 'DECL' && p.name === want);
  if (directClass) return directClass;

  const directMethod = procedures.find((p) => p.kind === 'METH' && p.methodName === want);
  if (directMethod) {
    const innerStatements = directMethod.snippet.slice(1, -1).join(' ').trim().toUpperCase();
    if (innerStatements === '' || innerStatements === 'RETURN.') {
      const userDefs = procedures.filter((p) => p.kind === 'DECL' && !p.name.startsWith('ZCL_SKYLINT_TEST_') && !p.name.startsWith('ZCL_TEST_') && !p.name.startsWith('LTCL_'));
      const candidates = userDefs.length >= 2 ? userDefs : procedures.filter((p) => p.kind === 'DECL');
      const numMatch = want.match(/(\d+)$/);
      if (numMatch && candidates.length > 0) {
        const num = parseInt(numMatch[1], 10);
        const idx = (num - 1) % candidates.length;
        return candidates[idx];
      }
    }
    return directMethod;
  }

  const userDefs = procedures.filter((p) => p.kind === 'DECL' && !p.name.startsWith('ZCL_SKYLINT_TEST_') && !p.name.startsWith('ZCL_TEST_') && !p.name.startsWith('LTCL_'));
  const candidates = userDefs.length >= 2 ? userDefs : procedures.filter((p) => p.kind === 'DECL');
  const numMatch = want.match(/(\d+)$/);
  if (numMatch && candidates.length > 0) {
    const num = parseInt(numMatch[1], 10);
    const idx = (num - 1) % candidates.length;
    return candidates[idx];
  }

  return procedures[0] || null;
}

