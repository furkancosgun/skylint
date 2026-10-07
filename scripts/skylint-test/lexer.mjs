/**
 * scripts/skylint-test/lexer.mjs
 *
 * 1:1 JS port of lcl_lexer
 * (src/platform/zcl_skylint_test_runner.clas.locals_imp.abap:204-425).
 *
 * Do NOT "improve" this tokenizer. It intentionally matches the SAP
 * compiler behavior the checks were written against:
 * - whitespace-split words (punctuation stays attached, parser splits it)
 * - 0-based columns, column cap at 255
 * - `"` / col-0 `*` comments, `##` pragmas, `'...'/`...` strings,
 *   `|...|` templates with `{}` depth and `\` escapes
 *
 * Token shape mirrors zif_skylint_types=>ty_token:
 *   { lexeme, type: 'I'|'S'|'C'|'P', position: { line, column }, references: [] }
 */

export const TOKEN_TYPES = {
  identifier: 'I',
  literal: 'S',
  comment: 'C',
  pragma: 'P',
};

const HORIZONTAL_TAB = '\t';

export class Lexer {
  constructor(source) {
    // ABAP: REPLACE ALL OCCURRENCES OF cr_lf WITH newline (only CRLF, not lone CR)
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
    if (at >= this.len) return '';
    return this.src[at];
  }

  advance() {
    if (this.pos >= this.len) return '';
    const ch = this.src[this.pos];
    this.pos += 1;
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

  emitToken(text, type) {
    this.tokens.push({
      lexeme: text,
      type,
      position: { line: this.tokLine, column: this.tokCol > 255 ? 255 : this.tokCol },
      references: [],
    });
  }

  run() {
    this.tokens = [];
    while (!this.atEnd()) {
      this.skipBlanks();
      if (this.atEnd()) break;
      // captured BEFORE consuming (0-based column, matches ABAP mv_col state)
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

  scanComment() {
    let text = '';
    while (!this.endsLine()) text += this.advance();
    this.emitToken(text, TOKEN_TYPES.comment);
  }

  scanPragma() {
    let text = this.advance() + this.advance();
    while (!this.atEnd()) {
      if (this.isBlank(this.peek())) break;
      text += this.advance();
    }
    this.emitToken(text, TOKEN_TYPES.pragma);
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
    this.emitToken(text, TOKEN_TYPES.literal);
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
    this.emitToken(text, TOKEN_TYPES.literal);
  }

  scanWord() {
    let text = '';
    while (!this.atEnd()) {
      if (this.isBlank(this.peek())) break;
      text += this.advance();
    }
    if (text !== '') this.emitToken(text, TOKEN_TYPES.identifier);
  }
}

/** Convenience: tokenize a source string in one call. */
export function tokenize(source) {
  return new Lexer(source).run();
}
