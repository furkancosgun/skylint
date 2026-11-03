// ---------------------------------------------------------------------------
// Playground rule engine (browser demo)
// Mirrors the logic of the corresponding Skylint ABAP check classes 1:1, but
// executes directly in JS against the same Skylint parser output
// (lib/core/lexer.mjs + lib/core/parser.mjs — zero external dependencies).
// Mirrored rules: no-check-stmt, no-yoda-cond, no-select-star,
//                 no-magic-numbers, max-line-len
// ---------------------------------------------------------------------------

import { Lexer } from '../../lib/core/lexer.mjs';
import { buildStatements } from '../../lib/core/parser.mjs';

const COMPARE_OPS = new Set([
  '=', '<>', '<', '>', '<=', '>=',
  'EQ', 'NE', 'LT', 'GT', 'LE', 'GE',
  'CS', 'CP', 'NS', 'NP', 'CO', 'CN', 'CA', 'NA',
]);

const MIRROR_OPS = {
  '=': '=', '<>': '<>', 'EQ': 'EQ', 'NE': 'NE',
  '<': '>', '>': '<', '<=': '>=', '>=': '<=',
  'LT': 'GT', 'GT': 'LT', 'LE': 'GE', 'GE': 'LE',
};

const DECL_KEYWORDS = new Set(['DATA', 'CONSTANTS', 'TYPES', 'STATICS']);

// Rule ids mirrored by this browser engine — used by Variant Builder chips,
// rule-page embeds (RulePlayground.vue) and /playground#rule=<id> deep links
export const PLAYGROUND_RULE_IDS = [
  'no-check-stmt',
  'no-yoda-cond',
  'no-select-star',
  'no-magic-numbers',
  'max-line-len',
];

export const RULE_DEFS = [
  {
    id: 'no-check-stmt',
    title: 'no-check-stmt',
    category: 'Anti-Patterns',
    enabled: true,
  },
  {
    id: 'no-yoda-cond',
    title: 'no-yoda-cond',
    category: 'Clean ABAP',
    enabled: true,
  },
  {
    id: 'no-select-star',
    title: 'no-select-star',
    category: 'Performance',
    enabled: true,
  },
  {
    id: 'no-magic-numbers',
    title: 'no-magic-numbers',
    category: 'Clean ABAP',
    enabled: true,
  },
  {
    id: 'max-line-len',
    title: 'max-line-len',
    category: 'Metrics',
    enabled: true,
    maxLen: 120,
  },
];

function isLiteral(lexeme) {
  if (!lexeme) return false;
  const first = lexeme[0];
  const last = lexeme[lexeme.length - 1];
  if ((first === "'" && last === "'") || (first === '`' && last === '`') || (first === '|' && last === '|')) {
    return true;
  }
  return /^[0-9]+$/.test(lexeme);
}

function isNumericToken(lexeme) {
  return /^[0-9]+$/.test(lexeme) && lexeme !== '0' && lexeme !== '1';
}

function stmtColumn(stmt) {
  const first = stmt.tokens[0];
  return first ? Math.max(0, first.position.column) : 0;
}

// Statement source span: first token → last token, extended over the trailing
// period (the parser strips it from the token stream, so we consume it here)
// and keeps any trailing comment outside the span (in `tail` during applyFix).
function stmtSpan(stmt, lines) {
  const toks = stmt.tokens;
  const first = toks[0];
  const last = toks[toks.length - 1];
  if (!first || !last) return null;
  let endCol = last.position.column + last.lexeme.length;
  const lineText = lines[last.position.line - 1] || '';
  if (lineText[endCol] === '.') endCol += 1;
  return {
    startLine: first.position.line,
    startCol: first.position.column,
    endLine: last.position.line,
    endCol,
  };
}

// Lexer uppercases lexemes; recover the author's original casing from the
// source text (only when it still matches the lexeme, to stay safe).
function origOf(tok, lines) {
  const lineText = lines[tok.position.line - 1] || '';
  const orig = lineText.slice(tok.position.column, tok.position.column + tok.lexeme.length);
  const okUp = orig.toUpperCase() === tok.lexeme || okRaw(tok);
  return okUp ? orig : tok.lexeme;
}

function okRaw(tok) {
  // string/template tokens keep their case in the lexeme already
  const f = tok.lexeme[0];
  return f === "'" || f === '`' || f === '|';
}

// Mirrors zcl_skylint_ast_util=>flatten_statement (column gaps preserved).
// baseCol anchors the first emitted token to the statement start column so the
// result can be spliced into the source at exactly that offset.
function flattenStatement(stmt, lines, overrides = {}, deletions = new Set(), suffix = '.') {
  let out = '';
  let prevEnd = stmtColumn(stmt);
  stmt.tokens.forEach((tok, idx) => {
    const gap = Math.max(0, tok.position.column - prevEnd);
    prevEnd = tok.position.column + tok.lexeme.length;
    if (deletions.has(idx)) return;
    const lexeme = Object.prototype.hasOwnProperty.call(overrides, idx)
      ? overrides[idx]
      : origOf(tok, lines);
    if (out === '') {
      out += ' '.repeat(gap);
    } else if (gap > 0) {
      out += ' '.repeat(gap);
    } else {
      out += ' ';
    }
    out += lexeme;
  });
  return out + suffix;
}

function suppressed(stmt, names) {
  return stmt.pseudo_comments.some((c) => names.includes(c));
}

// no-check-stmt: CHECK → IF NOT (...) CONTINUE/RETURN  (zcl_skylint_no_check_stmt)
function checkStmtRule(statements, lines, enabledBoth, add) {
  let loopDepth = 0;
  for (const stmt of statements) {
    switch (stmt.keyword) {
      case 'LOOP':
      case 'DO':
      case 'WHILE':
        loopDepth += 1;
        break;
      case 'ENDLOOP':
      case 'ENDDO':
      case 'ENDWHILE':
        if (loopDepth > 0) loopDepth -= 1;
        break;
      case 'CHECK': {
        const inLoop = loopDepth > 0;
        const names = inLoop ? ['NO_CHECK_IN_LOOP'] : ['NO_CHECK_OUTSIDE_LOOP'];
        if (!enabledBoth[inLoop ? 'loop' : 'outside'] || suppressed(stmt, names)) break;
        let fix = null;
        const span = stmtSpan(stmt, lines);
        if (stmt.tokens.length >= 2 && span) {
          const cond = stmt.tokens.slice(1)
            .map((t) => origOf(t, lines))
            .join(' ');
          const indent = ' '.repeat(stmtColumn(stmt));
          fix = {
            span,
            replacement: [`IF NOT ( ${cond} ).`, `${indent}${inLoop ? 'CONTINUE' : 'RETURN'}.`, `${indent}ENDIF.`],
            label: 'IF guard + ' + (inLoop ? 'CONTINUE' : 'RETURN'),
          };
        }
        add('no-check-stmt', inLoop ? 'NO_CHK_LP' : 'NO_CHK_OUT', inLoop
          ? 'Avoid CHECK inside loop; use IF ... CONTINUE instead'
          : 'Avoid CHECK outside loop; use IF ... RETURN instead', stmt, fix);
        break;
      }
      default:
        break;
    }
  }
}

// no-yoda-cond: literal op variable → variable mirror-op literal (zcl_skylint_no_yoda_cond)
function yodaRule(statements, lines, add) {
  for (const stmt of statements) {
    if (suppressed(stmt, ['NO_YODA_COND'])) continue;
    const toks = stmt.tokens;
    if (toks.length < 3) continue;
    for (let i = 0; i <= toks.length - 3; i++) {
      const t1 = toks[i];
      const t2 = toks[i + 1];
      const t3 = toks[i + 2];
      if (isLiteral(t1.lexeme) && COMPARE_OPS.has(t2.lexeme) && !isLiteral(t3.lexeme)) {
        const span = stmtSpan(stmt, lines);
        let fix = null;
        const mirror = MIRROR_OPS[t2.lexeme];
        const badFirst = '()[]{}\'"';
        if (mirror && span && t3.lexeme && !badFirst.includes(t3.lexeme[0])) {
          const t4 = toks[i + 3];
          const t4Ok = !t4 || t4.lexeme === '.' || t4.lexeme === ')' || t4.lexeme === 'AND' || t4.lexeme === 'OR';
          if (t4Ok) {
            fix = {
              span,
              replacement: [flattenStatement(
                stmt,
                lines,
                { [i]: origOf(t3, lines), [i + 1]: mirror, [i + 2]: origOf(t1, lines) },
              )],
              label: 'Swap to variable-first comparison',
            };
          }
        }
        add('no-yoda-cond', 'NO_YODA_CN',
          'Yoda condition; place the variable before the literal in comparison', stmt, fix);
        break;
      }
    }
  }
}

// no-select-star: SELECT * / table~* (zcl_skylint_no_select_star)
function selectStarRule(statements, add) {
  for (const stmt of statements) {
    if (stmt.keyword !== 'SELECT' || suppressed(stmt, ['NO_SELECT_STAR'])) continue;
    let inFields = false;
    let prev = '';
    for (const tok of stmt.tokens) {
      if (tok.lexeme === 'SELECT' || tok.lexeme === 'FIELDS') {
        inFields = true;
      } else if (['FROM', 'WHERE', 'GROUP', 'HAVING', 'ORDER', 'INTO', 'UP', 'UNION'].includes(tok.lexeme)) {
        inFields = false;
      }
      if (inFields) {
        if (tok.lexeme.length >= 2 && tok.lexeme.endsWith('~*')) {
          add('no-select-star', 'NO_SEL_STR', 'Avoid SELECT *; specify required columns explicitly', stmt, null);
          break;
        }
        if (tok.lexeme === '*') {
          // In ATC the '*' token is only treated as a field list when it carries
          // no compiler references; browser tokens never do.
          const lastChar = prev.length >= 1 ? prev[prev.length - 1] : '';
          if (prev === 'SELECT' || prev === 'SINGLE' || prev === 'FIELDS' || prev === 'DISTINCT' || lastChar === ',') {
            add('no-select-star', 'NO_SEL_STR', 'Avoid SELECT *; specify required columns explicitly', stmt, null);
            break;
          }
        }
      }
      prev = tok.lexeme;
    }
  }
}

// no-magic-numbers: numeric literals outside declarations (zcl_skylint_no_magic_numbers)
function magicNumbersRule(statements, add) {
  for (const stmt of statements) {
    if (DECL_KEYWORDS.has(stmt.keyword) || suppressed(stmt, ['NO_MAGIC_NUMBERS'])) continue;
    for (const tok of stmt.tokens) {
      if (tok.lexeme === 'EXCEPTIONS') break;
      if (isNumericToken(tok.lexeme)) {
        add('no-magic-numbers', 'NO_MAGIC_N',
          'Avoid hardcoded magic numbers; declare a named constant', stmt, null);
        break;
      }
    }
  }
}

// max-line-len: token end column beyond limit (zcl_skylint_max_line_len)
function maxLineLenRule(statements, maxLen, add) {
  if (!maxLen || maxLen <= 0) return;
  for (const stmt of statements) {
    if (suppressed(stmt, ['MAX_LINE_LEN'])) continue;
    const toks = stmt.tokens;
    for (let i = 0; i < toks.length; i++) {
      const tok = toks[i];
      let endCol = tok.position.column + tok.lexeme.length - 1;
      if (i === toks.length - 1) endCol += 1;
      if (endCol > maxLen) {
        add('max-line-len', 'MAX_LINLEN',
          `Line length exceeds the configured maximum limit (${maxLen} characters)`, stmt, null);
        break;
      }
    }
  }
}

export function analyze(source, ruleState) {
  const findings = [];
  const started = performance.now();

  const lines = source.split('\n');

  let statements;
  try {
    statements = buildStatements(new Lexer(source).run());
  } catch (e) {
    return { findings: [], parseError: String(e), statementCount: 0, ms: 0 };
  }

  const add = (rule, code, message, stmt, fix) => {
    findings.push({
      rule,
      code,
      message,
      line: stmt.position.line,
      column: stmt.position.column,
      fix: fix || null,
    });
  };

  if (ruleState['no-check-stmt'].enabled) {
    checkStmtRule(statements, lines, { loop: true, outside: true }, add);
  }
  if (ruleState['no-yoda-cond'].enabled) yodaRule(statements, lines, add);
  if (ruleState['no-select-star'].enabled) selectStarRule(statements, add);
  if (ruleState['no-magic-numbers'].enabled) magicNumbersRule(statements, add);
  if (ruleState['max-line-len'].enabled) maxLineLenRule(statements, ruleState['max-line-len'].maxLen, add);

  findings.sort((a, b) => a.line - b.line || a.column - b.column);

  return {
    findings,
    parseError: null,
    statementCount: statements.length,
    ms: Math.round((performance.now() - started) * 1000) / 1000,
  };
}

export function applyFix(source, finding) {
  if (!finding || !finding.fix) return source;
  const { span, replacement } = finding.fix;
  const lines = source.split('\n');
  const startIdx = span.startLine - 1;
  const endIdx = span.endLine - 1;
  if (startIdx < 0 || endIdx >= lines.length) return source;

  const head = lines[startIdx].slice(0, span.startCol);
  const tail = lines[endIdx].slice(span.endCol);

  const out = replacement.map((l, i) => {
    if (i === 0) return head + l;
    if (i === replacement.length - 1) return l + tail;
    return l;
  });

  lines.splice(startIdx, endIdx - startIdx + 1, ...out);
  return lines.join('\n');
}

export const SAMPLE_SOURCE = `CLASS zcl_demo IMPLEMENTATION.
  METHOD process_orders.

    DATA lv_count  TYPE i.
    DATA lv_status TYPE string.

    lv_count = 42.
    IF 100 > lv_count.
      lv_status = 'LOW'.
    ENDIF.

    CHECK lv_count IS NOT INITIAL.

    LOOP AT orders ASSIGNING <ls_order>.
      CHECK <ls_order>-pending = abap_true.
    ENDLOOP.

    SELECT * FROM orders INTO lv_status WHERE region = 'WEST'.

    " Magic number suppressed via pseudo-comment:
    lv_status = lv_count && '7'. " #EC NO_MAGIC_NUMBERS

    " Line-length violation:
    lv_status = 'THIS_LITERAL_PADDING_MAKES_THE_STATEMENT_LONGER_THAN_THE_CONFIGURED_120_COLUMN_LIMIT_DEMO_AND_MORE_VERBOSE'.
  ENDMETHOD.
ENDCLASS.
`;
