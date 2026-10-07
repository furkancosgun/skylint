/**
 * scripts/skylint-test/parser.mjs
 *
 * 1:1 JS port of lcl_parser + lcl_compiler (classify/paren_delta/pseudo)
 * + heuristic enrich_references
 * (src/platform/zcl_skylint_test_runner.clas.locals_imp.abap:428-811).
 *
 * Statement shape mirrors zif_skylint_types=>ty_statement:
 *   { index, keyword, tokens, position: {line, column}, pseudo_comments: [] }
 *
 * NOTE on ABAP pattern ops used here (must stay equivalent):
 * - `CP 'DATA(*)'` = starts with DATA( AND ends with ) (case: input upper)
 * - `CP '*('` = ends with '(' ; `CS '=>'` = contains ; `NP '*('` = NOT contains '('
 * - `SPLIT x AT '=>' INTO a b` splits at FIRST occurrence
 */

export const REF_KINDS = { data: 'DA', method: 'ME', type: 'TY' };
export const USAGE_MODES = {
  definition: '2',
  definitionWithWrite: '3',
  definitionWithAssign: '4',
  read: '5',
  write: '6',
  readAndWrite: '7',
  readDatabase: 'E',
  writeDatabase: 'F',
  redefinition: 'R',
};
export const USAGE_GRADES = { definition: '0', direct: '1', component: '2', indirect: '3' };

const ASSIGN_OPS = new Set(['=', '+=', '-=', '*=', '/=', '&&=', '?=']);
const METHOD_CALL_BLACKLIST = new Set([
  'VALUE(', 'NEW(', 'COND(', 'SWITCH(', 'REF(', 'CONV(', 'CAST(', 'EXACT(',
  'CORRESPONDING(', 'LINES(', 'XSDBOOL(', 'BOOLC(', 'STRLEN(', 'STRING(',
  'TABLE(', 'FILTER(', 'REDUCE(', 'DATA(', '@DATA(', 'FIELD-SYMBOL(',
]);
const DECL_KEYWORDS = new Set(['DATA', 'CONSTANTS', 'FIELD-SYMBOLS', 'STATICS']);
const DB_KEYWORDS_READ = new Set(['SELECT']);
const DB_KEYWORDS_WRITE = new Set(['UPDATE', 'MODIFY', 'INSERT', 'DELETE']);
const DB_STOPLIST = new Set([
  'FROM', 'INTO', 'TABLE', 'WHERE', 'SET', 'SINGLE', 'UP', 'TO', 'ROWS', 'BY',
  'APPENDING', 'CORRESPONDING', 'FIELDS', 'ALL', 'DISTINCT', 'FOR', 'REPORT',
  'SCREEN', 'USING', 'CLIENT', 'CONNECTION', 'AND', 'OR', 'ORDER', 'GROUP',
  'HAVING', 'JOIN', 'INNER', 'LEFT', 'RIGHT', 'OUTER', 'ON', 'AS',
]);
const TYPE_FILLERS = new Set(['REF', 'TO', 'TABLE', 'OF', 'LINE']);

/** lcl_parser=>paren_delta */
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

/** lcl_compiler=>is_assignment */
export function isAssignment(tokens) {
  if (tokens.length < 3) return false;
  return ASSIGN_OPS.has(tokens[1].lexeme);
}

/** lcl_compiler=>is_method_call */
export function isMethodCall(tokens) {
  if (tokens.length === 0) return false;
  const first = tokens[0].lexeme.toUpperCase();
  if (!first.includes('(')) return false; // NP '*('
  if (METHOD_CALL_BLACKLIST.has(first)) return false;
  return true;
}

/** lcl_compiler=>classify_statement */
export function classifyStatement(tokens, inChain, headerKw) {
  if (inChain && headerKw) return headerKw;
  if (tokens.length === 0) return '';
  if (isAssignment(tokens)) return 'COMPUTE';
  if (isMethodCall(tokens)) return '+CALL_METHOD';
  return tokens[0].lexeme.toUpperCase();
}

/** lcl_parser=>pseudo_words */
export function pseudoWords(text) {
  const off = text.toUpperCase().indexOf('#EC');
  if (off < 0) return [];
  const rest = text.slice(off + 3);
  if (rest.length === 0) return [];
  return rest
    .replace(/,/g, ' ')
    .split(' ')
    .map((p) => p.replace(/\s+/g, ' ').trim())
    .filter((p) => p !== '');
}

/** Trivia derivation: the lexer never emits a code token starting with `"` or
 *  `##`, or `*` at column 0 — so (lexeme, column) recovers the class exactly.
 *  No type field is needed (matches the ATC ty_token contract). */
export function isCommentToken(tok) {
  const lex = tok.lexeme;
  if (!lex) return false;
  if (lex[0] === '"') return true;
  return lex[0] === '*' && tok.position.column === 0;
}

export function isPragmaToken(tok) {
  return tok.lexeme.startsWith('##');
}

/** shallow token copy (ABAP APPEND copies the struct) */
function copyToken(tok) {
  return {
    lexeme: tok.lexeme,
    position: { line: tok.position.line, column: tok.position.column },
    references: tok.references,
  };
}

/** lcl_parser=>collect_pseudo */
function collectPseudo(token, statements, pending) {
  let words;
  if (isPragmaToken(token) && token.lexeme.length > 2) {
    words = [token.lexeme.slice(2)];
  } else {
    words = pseudoWords(token.lexeme);
  }
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

/** lcl_parser=>emit_statement (incl. enrich_references call) */
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
  enrichReferences(stmt);
  statements.push(stmt);
}

/** lcl_parser=>build_statements */
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

/* ---------------- heuristic enrich_references ---------------- */

function pushRef(refs, kind, fullName, grade, mode) {
  refs.push({ kind, full_name: fullName, usage_grade: grade, usage_mode: mode });
}

function addMethodReferences(upper, refs) {
  if (upper.includes('=>')) {
    const at = upper.indexOf('=>');
    const cls = upper.slice(0, at);
    let meth = upper.slice(at + 2);
    pushRef(refs, REF_KINDS.type, `\\TY:${cls}`, USAGE_GRADES.direct, undefined);
    if (meth.includes('(')) {
      if (meth.endsWith('(')) meth = meth.slice(0, -1);
      pushRef(refs, REF_KINDS.method, `\\TY:${cls}\\ME:${meth}`, USAGE_GRADES.direct, USAGE_MODES.read);
    }
  } else if (upper.includes('->') && upper.includes('(')) {
    const at = upper.indexOf('->');
    const cls = upper.slice(0, at);
    let meth = upper.slice(at + 2);
    if (meth.endsWith('(')) meth = meth.slice(0, -1);
    const full = cls === 'ME' ? `\\TY:ZSKYLINT_TEST\\ME:${meth}` : `${cls}->${meth}`;
    pushRef(refs, REF_KINDS.method, full, USAGE_GRADES.direct, USAGE_MODES.read);
  }
}

function parenName(upper) {
  const off = upper.indexOf('(');
  if (off < 0) return '';
  const start = off + 1;
  const len = upper.length - start - 1;
  if (len <= 0) return '';
  return upper.slice(start, start + len);
}

function addInlineDeclarationRefs(upper, refs) {
  let name = '';
  if ((upper.startsWith('DATA(') || upper.startsWith('@DATA(') || upper.startsWith('FINAL(')) && upper.endsWith(')')) {
    name = parenName(upper);
  } else if ((upper.startsWith('FIELD-SYMBOL(') || upper.startsWith('FIELD-SYMBOLS(')) && upper.endsWith(')')) {
    name = parenName(upper);
  }
  if (name) {
    pushRef(refs, REF_KINDS.data, `\\TY:ZSKYLINT_TEST\\ME:TEST\\DA:${name}`, USAGE_GRADES.definition, USAGE_MODES.definitionWithWrite);
  }
}

function addExplicitDeclarationRefs(stmt) {
  if (!DECL_KEYWORDS.has(stmt.keyword)) return;
  if (stmt.tokens.length >= 2) {
    const tok = stmt.tokens[1];
    pushRef(
      tok.references,
      REF_KINDS.data,
      `\\TY:ZSKYLINT_TEST\\ME:TEST\\DA:${tok.lexeme.toUpperCase()}`,
      USAGE_GRADES.definition,
      USAGE_MODES.definition,
    );
  }
}

export function isDbTableName(lexeme) {
  if (!lexeme) return false;
  const upper = lexeme.toUpperCase();
  if ([...`'@(*0123456789`].some((c) => upper[0] === c)) return false;
  if (DB_STOPLIST.has(upper)) return false;
  return true;
}

/** lcl_compiler=>find_db_table_index (0-based, -1 = none) */
function findDbTableIndex(stmt) {
  const toks = stmt.tokens;
  if (toks.length < 2) return -1;
  let anchor = null;
  if (['SELECT', 'DELETE', 'MODIFY'].includes(stmt.keyword)) anchor = 'FROM';
  else if (stmt.keyword === 'INSERT') anchor = 'INTO';
  else if (stmt.keyword === 'UPDATE') anchor = '';
  else return -1;

  if (anchor) {
    for (let i = 0; i < toks.length; i++) {
      if (toks[i].lexeme.toUpperCase() !== anchor) continue;
      let idx = i + 1;
      if (idx < toks.length && toks[idx].lexeme.toUpperCase() === 'TABLE') idx += 1;
      if (idx < toks.length && isDbTableName(toks[idx].lexeme)) return idx;
    }
  }
  if (['INSERT', 'UPDATE', 'DELETE', 'MODIFY'].includes(stmt.keyword)) {
    if (isDbTableName(toks[1].lexeme)) return 1;
  }
  return -1;
}

function addDatabaseReferences(stmt) {
  let mode;
  if (DB_KEYWORDS_READ.has(stmt.keyword)) mode = USAGE_MODES.readDatabase;
  else if (DB_KEYWORDS_WRITE.has(stmt.keyword)) mode = USAGE_MODES.writeDatabase;
  else return;
  const idx = findDbTableIndex(stmt);
  if (idx < 0) return;
  const tok = stmt.tokens[idx];
  pushRef(tok.references, REF_KINDS.data, `\\DB:${tok.lexeme.toUpperCase()}`, USAGE_GRADES.direct, mode);
}

function addSystemVarReferences(stmt) {
  stmt.tokens.forEach((tok, i) => {
    const up = tok.lexeme.toUpperCase();
    if (!(up.startsWith('SY-') || up.startsWith('SYST-'))) return;
    const isTgt = i === 0 && stmt.keyword === 'COMPUTE';
    pushRef(
      tok.references,
      REF_KINDS.data,
      `\\PR:ZSKYLINT\\DA:${up}`,
      USAGE_GRADES.direct,
      isTgt ? USAGE_MODES.write : USAGE_MODES.read,
    );
  });
}

function addTypeReferences(stmt) {
  let expect = false;
  for (const tok of stmt.tokens) {
    const up = tok.lexeme.toUpperCase();
    if (up.startsWith('CX_SY_')) {
      pushRef(tok.references, REF_KINDS.type, `\\TY:${up}`, USAGE_GRADES.direct, USAGE_MODES.read);
      expect = false;
      continue;
    }
    if (up === 'TYPE' || up === 'LIKE') {
      expect = true;
      continue;
    }
    if (!expect) continue;
    if (TYPE_FILLERS.has(up)) continue;
    pushRef(tok.references, REF_KINDS.type, `\\TY:${up}`, USAGE_GRADES.direct, USAGE_MODES.read);
    expect = false;
  }
}

/** lcl_compiler=>enrich_references */
export function enrichReferences(stmt) {
  for (const tok of stmt.tokens) {
    const up = tok.lexeme.toUpperCase();
    addMethodReferences(up, tok.references);
    addInlineDeclarationRefs(up, tok.references);
  }
  addExplicitDeclarationRefs(stmt);
  addDatabaseReferences(stmt);
  addSystemVarReferences(stmt);
  addTypeReferences(stmt);
}
