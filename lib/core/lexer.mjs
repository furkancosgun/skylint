const HORIZONTAL_TAB = '\t';

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
