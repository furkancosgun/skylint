import { parenDelta } from './lexer.mjs';

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

export {
  ASSIGN_OPS,
  METHOD_CALL_BLACKLIST,
  DECL_KEYWORDS,
  DB_KEYWORDS_READ,
  DB_KEYWORDS_WRITE,
  isCommentToken,
  isPragmaToken,
  copyToken,
  pseudoWords,
  collectPseudo,
  isAssignment,
  isMethodCall,
  classifyStatement,
  pushRef,
  hasRefKind,
  isStringToken,
  dataScopePrefix,
  cutAtParen,
  emitStatement,
};
