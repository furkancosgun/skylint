import { Registry, MemoryFile, SyntaxLogic, Expressions, Statements } from '@abaplint/core';

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
// Semantic Analyzers (Powered by @abaplint/core AST & SyntaxLogic)
// ---------------------------------------------------------------------------

/**
 * Resolves database tables via abaplint Expressions.DatabaseTable
 * Replaces manual string searching (findDbTableIndex, DB_STOPLIST).
 */
function resolveDatabaseTables(abapFile, statements, offset, declared) {
  for (const stmt of abapFile.getStatements()) {
    const dbExpr = stmt.findFirstExpression(Expressions.DatabaseTable);
    if (!dbExpr) continue;

    const firstTok = dbExpr.getFirstToken();
    const relLine = firstTok.getRow() - offset;
    const dbName = dbExpr.concatTokens().toUpperCase().replace(/^@/, '');
    if (declared && declared.has(dbName)) continue;

    for (const s of statements) {
      if (s.position.line !== relLine) continue;
      const isRead = DB_KEYWORDS_READ.has(s.keyword);
      const isWrite = DB_KEYWORDS_WRITE.has(s.keyword);
      if (!isRead && !isWrite) continue;

      const mode = isRead ? 'E' : 'F';
      for (const tok of s.tokens) {
        if (tok.lexeme.toUpperCase().replace(/^@/, '') === dbName && !hasRefKind(tok.references, 'DA')) {
          pushRef(tok.references, 'DA', `\\DB:${dbName}`, '1', mode);
          break;
        }
      }
    }
  }
}

/**
 * Resolves inline data & field-symbol declarations via abaplint AST
 */
function resolveInlineDeclarations(abapFile, statements, offset, ctx) {
  for (const stmt of abapFile.getStatements()) {
    const inlineDataList = stmt.findAllExpressions(Expressions.InlineData);
    for (const inData of inlineDataList) {
      const tgt = inData.findFirstExpression(Expressions.TargetField) || inData;
      const tokName = tgt.concatTokens().toUpperCase().replace(/^DATA\(/i, '').replace(/\)$/, '').trim();
      const firstTok = inData.getFirstToken();
      const relLine = firstTok.getRow() - offset;

      for (const s of statements) {
        if (s.position.line !== relLine) continue;
        for (const tok of s.tokens) {
          const up = tok.lexeme.toUpperCase().replace(/^@/, '');
          if (up.startsWith('DATA(') && up.endsWith(')')) {
            const inner = up.slice(5, -1);
            if (inner === tokName && !hasRefKind(tok.references, 'DA')) {
              pushRef(tok.references, 'DA', `${dataScopePrefix(ctx)}\\DA:${tokName}`, '0', '3');
            }
          }
        }
      }
    }

    const inlineFsList = stmt.findAllExpressions(Expressions.InlineFS);
    for (const inFs of inlineFsList) {
      const fsTok = inFs.findFirstExpression(Expressions.FieldSymbol) || inFs;
      const fsName = fsTok.concatTokens().toUpperCase().replace(/^FIELD-SYMBOL\(/i, '').replace(/\)$/, '').trim();
      const firstTok = inFs.getFirstToken();
      const relLine = firstTok.getRow() - offset;

      for (const s of statements) {
        if (s.position.line !== relLine) continue;
        for (const tok of s.tokens) {
          const up = tok.lexeme.toUpperCase().replace(/^@/, '');
          if (up.startsWith('FIELD-SYMBOL(') && up.endsWith(')')) {
            const inner = up.slice(13, -1);
            if (inner === fsName && !hasRefKind(tok.references, 'DA')) {
              pushRef(tok.references, 'DA', `${dataScopePrefix(ctx)}\\DA:${fsName}`, '0', '4');
            }
          }
        }
      }
    }
  }
}

/**
 * Resolves type references (TYPE, LIKE, TYPE REF TO, CX_SY_*) via abaplint AST
 */
function resolveTypeReferences(abapFile, statements, offset) {
  for (const stmt of abapFile.getStatements()) {
    const typeNames = [
      ...stmt.findAllExpressions(Expressions.TypeName),
      ...stmt.findAllExpressions(Expressions.ClassName),
    ];
    for (const tn of typeNames) {
      const name = tn.concatTokens().toUpperCase();
      const firstTok = tn.getFirstToken();
      const relLine = firstTok.getRow() - offset;

      for (const s of statements) {
        if (s.position.line !== relLine) continue;
        for (const tok of s.tokens) {
          if (tok.lexeme.toUpperCase() === name && !hasRefKind(tok.references, 'TY')) {
            pushRef(tok.references, 'TY', `\\TY:${name}`, '1', '1');
          }
        }
      }
    }
  }
}

/**
 * Resolves method calls and static class invocations via abaplint AST
 */
function resolveMethodCalls(abapFile, statements, offset, ctx) {
  for (const stmt of abapFile.getStatements()) {
    const chains = stmt.findAllExpressions(Expressions.MethodCallChain);
    for (const chain of chains) {
      const text = chain.concatTokens().toUpperCase();
      const firstTok = chain.getFirstToken();
      const relLine = firstTok.getRow() - offset;

      for (const s of statements) {
        if (s.position.line !== relLine) continue;
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
          } else if (up.includes('->') && up.includes('(')) {
            const at = up.indexOf('->');
            const meth = cutAtParen(up.slice(at + 2));
            if (meth && /^[A-Z0-9_]+$/.test(meth)) {
              pushRef(tok.references, 'ME', `\\TY:${ctx.className}\\ME:${meth}`, '1', '5');
            }
        }
      }
    }
  }
}
}

/**
 * Resolves explicit data declarations via abaplint Expressions.DefinitionName
 */
function resolveExplicitDeclarations(abapFile, statements, offset, ctx) {
  for (const stmt of abapFile.getStatements()) {
    const def = stmt.findFirstExpression(Expressions.DefinitionName);
    if (!def) continue;
    const name = def.concatTokens().toUpperCase();
    const firstTok = def.getFirstToken();
    const relLine = firstTok.getRow() - offset;

    for (const s of statements) {
      if (s.position.line !== relLine) continue;
      for (const tok of s.tokens) {
        if (tok.lexeme.toUpperCase() === name && !hasRefKind(tok.references, 'DA')) {
          pushRef(tok.references, 'DA', `${dataScopePrefix(ctx)}\\DA:${name}`, '0', '2');
          break;
        }
      }
    }
  }
}

function addExplicitDeclarationRefs(stmt, ctx) {
  if (!DECL_KEYWORDS.has(stmt.keyword)) return;
  if (stmt.tokens.length >= 2) {
    let tokIdx = 1;
    if (stmt.tokens[1].lexeme === 'BEGIN' || stmt.tokens[1].lexeme === 'END') {
      if (stmt.tokens.length >= 4 && stmt.tokens[2].lexeme === 'OF') {
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
  return WRITE_TARGET_LAST.has(stmt.keyword) && i === count - 1;
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
export async function enrichStatementsWithAbaplint(
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
  const off = parseInt(absOffset || '0', 10) || 0;
  const tyPre = '\\TY:' + sn;
  const mePre = '\\ME:';
  const rows = [];

  const ctx = {
    className: sn,
    methodName: (methodName || '').toUpperCase(),
  };

  let abapFile = null;

  if (fullSource) {
    try {
      const reg = new Registry();
      reg.addFile(new MemoryFile(sn.toLowerCase() + '.clas.abap', fullSource));
      await reg.parseAsync();
      const obj = reg.getFirstObject();
      if (obj) {
        abapFile = obj.getABAPFiles()[0];
        walk(new SyntaxLogic(reg, obj).run().spaghetti.getTop());
      }
    } catch {}
  }

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
    } catch {}
  }

  function resolvedName(r) {
    try {
      const nm = r.resolved && r.resolved.getName ? '' + r.resolved.getName() : '';
      if (!nm || nm === 'undefined') return '';
      return nm.toUpperCase();
    } catch {
      return '';
    }
  }

  const declared = collectDeclaredNames(statements);

  function stmtKeywordAt(rel) {
    for (const stmt of statements) {
      if (stmt.position.line === rel) return stmt.keyword;
    }
    return '';
  }

  function emitKind(r, rel) {
    if (rel[0] < 1) return;
    const rt = (r.referenceType || '').toString();
    const nm = resolvedName(r);
    let kind = '';
    let grade = '1';
    let mode = '5';
    let fname = '';
    if (/method implementation/i.test(rt)) {
      if (!nm) return;
      kind = 'ME';
      grade = '0';
      mode = undefined;
      fname = tyPre + mePre + nm;
    } else if (/method/i.test(rt)) {
      if (!nm) return;
      kind = 'ME';
      fname = tyPre + mePre + nm;
    } else if (/type/i.test(rt)) {
      if (!nm) return;
      kind = 'TY';
      mode = '1';
      fname = `\\TY:${nm}`;
    } else if (/table/i.test(rt)) {
      if (!nm) return;
      kind = 'DA';
      mode = stmtKeywordAt(rel[0]) === 'SELECT' ? 'E' : 'F';
      const daPre = declared.has(nm) ? dataScopePrefix(ctx) : '';
      fname = declared.has(nm) ? `${daPre}\\DA:${nm}` : `\\DB:${nm}`;
    } else if (/object/i.test(rt)) {
      if (!nm) return;
      kind = 'TY';
      mode = undefined;
      fname = `\\TY:${nm}`;
    } else if (/write/i.test(rt)) {
      if (!nm) return;
      kind = 'DA';
      mode = '6';
      const daPre = declared.has(nm) ? dataScopePrefix(ctx) : tyPre;
      fname = `${daPre}\\DA:${nm}`;
    } else if (/data|variable|read/i.test(rt)) {
      if (!nm) return;
      kind = 'DA';
      const daPre = declared.has(nm) ? dataScopePrefix(ctx) : tyPre;
      fname = `${daPre}\\DA:${nm}`;
    } else {
      return;
    }
    rows.push({
      rel: rel[0],
      col: rel[1],
      ident: flatString(fname),
      kind,
      fname: flatString(fname),
      grade,
      mode,
    });
  }

  const pending = [];
  for (const row of rows) {
    if (!attachRow(statements, row, true)) pending.push(row);
  }
  for (const row of pending) {
    attachRow(statements, row, false);
  }

  // Abaplint AST Expression Analysis
  if (abapFile) {
    resolveDatabaseTables(abapFile, statements, off, declared);
    resolveExplicitDeclarations(abapFile, statements, off, ctx);
    resolveInlineDeclarations(abapFile, statements, off, ctx);
    resolveTypeReferences(abapFile, statements, off);
    resolveMethodCalls(abapFile, statements, off, ctx);
  }

  // Explicit declarations, system variables and shadowed reads
  for (const stmt of statements) {
    addExplicitDeclarationRefs(stmt, ctx);
    addSystemVarReferences(stmt);
    addFallbackTypeReferences(stmt, declared);
    addShadowedDataReads(stmt, declared, ctx);
  }
}

// ---------------------------------------------------------------------------
// RTTI Feeder (@abaplint/transpiler)
// ---------------------------------------------------------------------------
const fedByHash = new Map();

function hashSource(s) {
  let x = 5381;
  for (let i = 0; i < s.length; i++) x = ((x << 5) + x + s.charCodeAt(i)) >>> 0;
  return 'k' + x;
}

function splitSourceFiles(fullSource) {
  const defs = {};
  const order = [];
  let cur = null;
  for (const ln of fullSource.split(/\r?\n/)) {
    let m = /^\s*CLASS\s+(\S+)\s+DEFINITION\b/i.exec(ln);
    if (m) {
      const nm = m[1].replace(/\.$/, '').toUpperCase();
      if (!defs[nm]) {
        defs[nm] = { def: [], impl: [] };
        order.push(nm);
      }
      cur = { name: nm, part: 'def' };
      defs[nm].def.push(ln);
      continue;
    }
    m = /^\s*CLASS\s+(\S+)\s+IMPLEMENTATION\b/i.exec(ln);
    if (m) {
      const nm = m[1].replace(/\.$/, '').toUpperCase();
      if (!defs[nm]) {
        defs[nm] = { def: [], impl: [] };
        order.push(nm);
      }
      cur = { name: nm, part: 'impl' };
      defs[nm].impl.push(ln);
      continue;
    }
    if (/^\s*ENDCLASS\.\s*$/i.test(ln)) {
      if (cur) {
        defs[cur.name][cur.part].push(ln);
        cur = null;
      }
      continue;
    }
    if (cur) defs[cur.name][cur.part].push(ln);
  }
  const files = [];
  for (const nm of order) {
    if (defs[nm].def.length === 0) continue;
    files.push({ filename: nm.toLowerCase() + '.clas.abap', contents: [...defs[nm].def, ...defs[nm].impl].join('\n') });
  }
  return { files, first: order.length > 0 ? order[0] : '' };
}

async function transpileAndEval(fullSource, abap) {
  const { files, first: det } = splitSourceFiles(fullSource);
  if (!det || files.length === 0) return [];
  try {
    const { Transpiler } = await import('@abaplint/transpiler');
    const known = new Set(files.map((f) => f.filename.replace(/\.clas\.abap$/, '').toUpperCase()));
    const extra = [];
    for (const f of files) {
      const re = /INHERITING\s+FROM\s+([A-Za-z0-9_]+)/gi;
      let m;
      while ((m = re.exec(f.contents)) !== null) {
        const sup = m[1].toUpperCase();
        if (!known.has(sup) && !(abap.Classes && abap.Classes[sup])) {
          known.add(sup);
          extra.push({
            filename: sup.toLowerCase() + '.clas.abap',
            contents: `CLASS ${sup} DEFINITION PUBLIC CREATE PUBLIC.\n  PUBLIC SECTION.\nENDCLASS.\nCLASS ${sup} IMPLEMENTATION.\nENDCLASS.`,
          });
        }
      }
    }
    const all = [...extra, ...files];
    let tout;
    try {
      tout = await new Transpiler({ ignoreSyntaxCheck: true, unknownTypes: 'runtimeError' }).runRaw(all);
    } catch {
      return [];
    }
    const parOf = (c) => {
      const pm = /DEFINITION\s+INHERITING\s+FROM\s+(\S+)/i.exec(c || '');
      return pm ? pm[1].replace(/\.$/, '').toLowerCase() + '.clas.abap' : '';
    };
    const byFn = {};
    all.forEach((f) => {
      byFn[f.filename] = f;
    });
    const done = new Set();
    const seq = [];
    let guard = all.length * all.length + 5;
    while (seq.length < all.length && guard-- > 0) {
      let moved = false;
      for (const f of all) {
        if (done.has(f.filename)) continue;
        const pf = parOf(f.contents);
        if (!pf || !byFn[pf] || done.has(pf)) {
          done.add(f.filename);
          seq.push(f);
          moved = true;
        }
      }
      if (!moved) {
        for (const f of all) {
          if (!done.has(f.filename)) {
            done.add(f.filename);
            seq.push(f);
          }
        }
      }
    }
    if (!tout) return [];
    const codeByFn = {};
    tout.objects.forEach((o) => {
      if (o.chunk) codeByFn[o.filename] = o.chunk.getCode();
    });
    let joint = seq.map((f) => codeByFn[f.filename.replace(/\.abap$/, '.mjs')] || codeByFn[f.filename] || '').join('\n;\n');
    for (const o of tout.objects.filter((o) => o.chunk)) {
      if (!joint.includes(o.chunk.getCode())) joint += '\n;\n' + o.chunk.getCode();
    }
    const AsyncFunction = Object.getPrototypeOf(async function () {}).constructor;
    const before = new Set(Object.keys(abap.Classes));
    await new AsyncFunction('abap', joint)(abap);
    return Object.keys(abap.Classes).filter((k) => !before.has(k));
  } catch {
    return [];
  }
}

export async function feedRtti(fullSource, objectName, abap) {
  if (!fullSource) return;
  const sn = ((objectName || '').trim() || 'ZSKYLINT_TEST').toUpperCase();
  const key = hashSource(fullSource);
  let fed = fedByHash.get(key);
  if (fed === undefined) {
    fed = await transpileAndEval(fullSource, abap);
    fedByHash.set(key, fed);
  }
  const keys = fed || [];
  const pick = (nm) => keys.find((k) => k === nm) || keys.find((k) => k.endsWith('-' + nm)) || '';
  const det = splitSourceFiles(fullSource).first;
  const forSn = pick(sn) || pick(det);
  const forDet = pick(det);
  if (forSn && abap.Classes[forSn]) abap.Classes[sn] = abap.Classes[forSn];
  if (det && forDet && abap.Classes[forDet]) abap.Classes[det] = abap.Classes[forDet];
  for (const k of keys) {
    const sh = k.split('-').pop();
    if (sh && !abap.Classes[sh] && abap.Classes[k]) abap.Classes[sh] = abap.Classes[k];
  }
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

export function extractAllProcedures(fullLines) {
  const procedures = [];
  let currentImplClass = '';
  let inDef = false;
  let inMeth = false;
  let defBuffer = [];
  let methBuffer = [];
  let defName = '';
  let methName = '';
  let defOffset = 0;
  let methOffset = 0;

  for (let i = 0; i < fullLines.length; i++) {
    const line = fullLines[i];
    const upper = line.trim().toUpperCase();

    const implName = parseClassImplName(line);
    if (implName) {
      currentImplClass = implName;
    }

    if (!inDef && !inMeth) {
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

/**
 * Connects directly to the live SAP Compiler API endpoint to fetch native AST & references
 */
export async function fetchSapCompilerStatements(source, endpointUrl = 'http://localhost:8000/api?sap-client=001') {
  const response = await fetch(endpointUrl, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ source }),
  });
  if (!response.ok) {
    throw new Error(`SAP Compiler API error: ${response.status} ${response.statusText}`);
  }
  return await response.json();
}

