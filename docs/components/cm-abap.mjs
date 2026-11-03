import { StreamLanguage, HighlightStyle, syntaxHighlighting } from '@codemirror/language';
import { tags as t } from '@lezer/highlight';

const KEYWORDS = new Set([
  'ADD', 'ALL', 'AND', 'ANY', 'APPEND', 'AS', 'ASSIGN', 'ASSIGNED', 'ASSOCIATION', 'AT',
  'AUTHORITY-CHECK', 'BACK', 'BEGIN', 'BETWEEN', 'BINARY', 'BLOCK', 'BOUND', 'BY',
  'CALL', 'CASE', 'CATCH', 'CHECK', 'CLASS', 'CLASS-DATA', 'CLASS-METHODS', 'CLEAR',
  'CLIENT', 'CLOSE', 'COLLECT', 'COMMIT', 'COMMUNICATION', 'COMPUTE', 'CONCATENATE',
  'COND', 'CONDENSE', 'CONSTANTS', 'CONTINUE', 'CONV', 'CONVERT', 'CORRESPONDING',
  'COUNT', 'CREATE', 'CURSOR', 'DATA', 'DATABASE', 'DECIMALS', 'DEFAULT', 'DELETE',
  'DEMAND', 'DESCENDING', 'DESCRIBE', 'DISTINCT', 'DIVIDE', 'DO', 'ELSE', 'ELSEIF',
  'EMPTY', 'END', 'END-OF-DEFINITION', 'END-OF-FILE', 'END-OF-PAGE', 'END-OF-SELECTION',
  'ENDAT', 'ENDCASE', 'ENDCATCH', 'ENDCLASS', 'ENDDO', 'ENDFORM', 'ENDFUNCTION',
  'ENDIF', 'ENDINTERFACE', 'ENDLOOP', 'ENDMETHOD', 'ENDMODULE', 'ENDPROVIDE',
  'ENDSELECT', 'ENDTRY', 'ENDWHILE', 'ENTRY', 'EXACT', 'EXCEPTION', 'EXCEPTIONS',
  'EXECUTIVE', 'EXIT', 'EXPANDING', 'EXPORT', 'EXPORTING', 'EXTRACT', 'FETCH',
  'FIELDS', 'FIELD-SYMBOL', 'FIELD-SYMBOLS', 'FILTER', 'FINAL', 'FIRST', 'FOR', 'FORM',
  'FORMAT', 'FREE', 'FROM', 'FUNCTION', 'GENERATE', 'GET', 'GIVING', 'GROUP',
  'HAVING', 'HEADER', 'HELP-ID', 'HELP-REQUEST', 'HIDE', 'HIGH', 'HURT', 'IDENTIFIED',
  'IF', 'IMPORT', 'IMPORTING', 'IN', 'INCLUDE', 'INDEX', 'INITIAL', 'INITIALIZATION',
  'INNER', 'INPUT', 'INSERT', 'INSTANCE', 'INTERRUPT', 'INTERVALS', 'INTO', 'INVERSE',
  'IS', 'JOIN', 'KEY', 'LEFT', 'LEAVE', 'LIKE', 'LINE', 'LINES', 'LINE_EXISTS',
  'LOAD', 'LOCAL', 'LOOP', 'MARGIN', 'MATCH', 'MATCHES', 'MAX', 'MEMORY', 'MESSAGE',
  'METHOD', 'METHODS', 'MIN', 'MOD', 'MODIFY', 'MODULE', 'MOVE', 'MOVE-CORRESPONDING',
  'MULTIPLY', 'NEW', 'NEXT', 'NO', 'NOT', 'NULL', 'OBJECT', 'OBLIGATORY', 'OCCURS',
  'OF', 'OFF', 'ON', 'OPEN', 'OPTIONAL', 'OPTION', 'OPTIONS', 'ORDER', 'OTHERS',
  'OUTER', 'OUTPUT', 'OVERLAY', 'PACK', 'PACKAGE', 'PAD', 'PAGE', 'PAGES', 'PARAMETER',
  'PARAMETERS', 'PERFORM', 'PLACES', 'POSITION', 'PRAGMA', 'PREFERRED', 'PRIVATE',
  'PROCEDURE', 'PROCESS', 'PROGRAM', 'PROTECTED', 'PROVIDE', 'PUBLIC', 'PUT', 'RAISE',
  'RAISING', 'RANGE', 'RANGES', 'READ', 'RECEIVE', 'RECEIVING', 'REDEFINING',
  'REDEFINITION', 'REDUCE', 'REF', 'REFERENCE', 'REJECT', 'REPLACE', 'REPORT',
  'REQUESTED', 'RESERVE', 'RESET', 'RESUME', 'RETRY', 'RETURN', 'RETURNING', 'RIGHT',
  'ROLLBACK', 'ROWS', 'RUN', 'SCAN', 'SCREEN', 'SCROLL', 'SEARCH', 'SECTION', 'SELECT',
  'SELECTION-SCREEN', 'SET', 'SHIFT', 'SHORT', 'SIGN', 'SINGLE', 'SIZE', 'SKIP',
  'SORT', 'SPECIFIED', 'SPLIT', 'STANDARD', 'START-OF-SELECTION', 'STATICS', 'STEP',
  'STOP', 'STRING', 'STRUCTURE', 'SUBMIT', 'SUBTRACT', 'SUM', 'SUMMARY', 'SUPPRESS',
  'SWITCH', 'SYNTAX-CHECK', 'TABLE', 'TABLES', 'TIME', 'TITLE', 'TITLEBAR', 'TO',
  'TOP-OF-PAGE', 'TRANSACTION', 'TRANSFER', 'TRANSLATE', 'TRY', 'TYPE', 'TYPES',
  'ULINE', 'UNDER', 'UNIQUE', 'UNIT', 'UNPACK', 'UP', 'UPDATE', 'USER-COMMAND',
  'USING', 'VALUE', 'VALUES', 'VIA', 'VIEW', 'WAIT', 'WHEN', 'WHERE', 'WHILE',
  'WINDOW', 'WITH', 'WORK', 'WRITE', 'XSTRING', 'ZONE',
]);

const TYPES = new Set([
  'I', 'F', 'P', 'D', 'T', 'C', 'N', 'X', 'STRING', 'XSTRING', 'ABAP_BOOL', 'BOOLEAN',
]);

const ATOMS = new Set([
  'ABAP_TRUE', 'ABAP_FALSE', 'ABAP_UNDEFINED', 'SPACE',
]);

const OPERATORS = new Set([
  '=', '<>', '<', '>', '<=', '>=', 'EQ', 'NE', 'LT', 'GT', 'LE', 'GE',
  'CS', 'CP', 'NS', 'NP', 'CO', 'CN', 'CA', 'NA', 'AND', 'OR', 'NOT',
  '+', '-', '*', '/', '&&', '->', '=>', '?=',
]);

export const abapStreamParser = {
  name: 'abap',
  startState() {
    return {
      inString: null,
      stringChar: null,
    };
  },
  token(stream, state) {
    if (state.inString) {
      const ch = state.stringChar;
      while (!stream.eol()) {
        const c = stream.next();
        if (c === ch) {
          if (ch === "'" && stream.peek() === "'") {
            stream.next();
          } else if (ch === '`' && stream.peek() === '`') {
            stream.next();
          } else {
            state.inString = null;
            state.stringChar = null;
            break;
          }
        }
      }
      return 'string';
    }

    // Comment at start of line: *
    if (stream.sol() && stream.peek() === '*') {
      stream.skipToEnd();
      return 'lineComment';
    }

    // Trailing/inline comment: "
    if (stream.peek() === '"') {
      stream.skipToEnd();
      return 'lineComment';
    }

    // Whitespace
    if (stream.eatSpace()) return null;

    const ch = stream.peek();

    // Strings & String templates
    if (ch === "'" || ch === '`' || ch === '|') {
      stream.next();
      state.inString = true;
      state.stringChar = ch;
      while (!stream.eol()) {
        const c = stream.next();
        if (c === ch) {
          if (ch === "'" && stream.peek() === "'") {
            stream.next();
          } else if (ch === '`' && stream.peek() === '`') {
            stream.next();
          } else {
            state.inString = null;
            state.stringChar = null;
            break;
          }
        }
      }
      return 'string';
    }

    // Pragmas (##...) or Pseudo-comments (#EC...)
    if (ch === '#' && stream.match(/^(##[A-Za-z0-9_]+|#EC\s+[A-Za-z0-9_]+)/)) {
      return 'meta';
    }

    // Numbers
    if (stream.match(/^[0-9]+(\.[0-9]+)?\b/)) {
      return 'number';
    }

    // Operators
    if (stream.match(/^(=>|->|\?=|<=|>=|<>|&&|\+|-|\*|\/|=|<|>)/)) {
      return 'operator';
    }

    // Word / Identifier
    if (stream.match(/^[A-Za-z0-9_!/-]+/)) {
      const word = stream.current().toUpperCase();
      if (ATOMS.has(word)) return 'atom';
      if (OPERATORS.has(word)) return 'operator';
      if (TYPES.has(word)) return 'typeName';
      if (KEYWORDS.has(word)) return 'keyword';
      return 'variableName';
    }

    stream.next();
    return null;
  },
};

export const abapHighlightStyle = HighlightStyle.define([
  { tag: t.keyword, class: 'cm-abap-kw' },
  { tag: t.typeName, class: 'cm-abap-typ' },
  { tag: t.atom, class: 'cm-abap-atm' },
  { tag: t.operator, class: 'cm-abap-op' },
  { tag: t.string, class: 'cm-abap-str' },
  { tag: t.number, class: 'cm-abap-num' },
  { tag: t.lineComment, class: 'cm-abap-com' },
  { tag: t.meta, class: 'cm-abap-meta' },
]);

export const abapLanguage = StreamLanguage.define(abapStreamParser);
export const abapSupport = [abapLanguage, syntaxHighlighting(abapHighlightStyle)];
