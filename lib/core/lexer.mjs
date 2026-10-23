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

  templateHasExpression() {
    let at = this.pos + 1;
    while (at < this.len) {
      const ch = this.src[at];
      if (ch === '\n') return false;
      if (ch === '\\') {
        at += 2;
        continue;
      }
      if (ch === '{') return true;
      if (ch === '|') return false;
      at += 1;
    }
    return false;
  }

  emitCharToken(text) {
    const line = this.line;
    const col = this.col;
    this.advance();
    this.tokLine = line;
    this.tokCol = col;
    this.emitToken(text);
  }

  scanTemplateExpression() {
    let depth = 1;

    while (!this.atEnd() && !this.endsLine()) {
      this.skipBlanks();
      if (this.atEnd() || this.endsLine()) {
        return;
      }
      const ch = this.peek();
      if (ch === '}') {
        depth -= 1;
        this.emitCharToken('}');
        if (depth === 0) {
          return;
        }
      } else if (ch === '{') {
        depth += 1;
        this.emitCharToken('{');
      } else if (ch === "'") {
        const line = this.line;
        const col = this.col;
        this.tokLine = line;
        this.tokCol = col;
        this.scanString("'");
      } else if (ch === '`') {
        const line = this.line;
        const col = this.col;
        this.tokLine = line;
        this.tokCol = col;
        this.scanString('`');
      } else if (ch === '|') {
        this.scanTemplate();
      } else {
        const line = this.line;
        const col = this.col;
        let text = '';
        while (!this.atEnd() && !this.endsLine()) {
          const cur = this.peek();
          if (this.isBlank(cur) || cur === '}' || cur === '{' || cur === '|'
             || cur === "'" || cur === '`') {
            break;
          }
          text += this.advance();
        }
        if (text !== '') {
          this.tokLine = line;
          this.tokCol = col;
          this.emitToken(text);
        } else {
          this.emitCharToken(this.peek());
        }
      }
    }
  }

  scanTemplate() {
    if (!this.templateHasExpression()) {
      let text = this.advance();
      while (!this.endsLine()) {
        const ch = this.peek();
        if (ch === '\\') {
          text += this.advance();
          if (!this.atEnd()) text += this.advance();
        } else if (ch === '|') {
          text += this.advance();
          break;
        } else {
          text += this.advance();
        }
      }
      this.emitToken(text);
      return;
    }

    this.emitCharToken('|');
    let literal = '';
    let literalLine = 0;
    let literalCol = 0;

    while (!this.atEnd() && !this.endsLine()) {
      const ch = this.peek();
      if (ch === '\\') {
        if (literal === '') {
          literalLine = this.line;
          literalCol = this.col;
        }
        literal += this.advance();
        if (!this.atEnd() && !this.endsLine()) {
          literal += this.advance();
        }
      } else if (ch === '{') {
        if (literal !== '') {
          this.tokLine = literalLine;
          this.tokCol = literalCol;
          this.emitToken(`'${literal}'`);
          literal = '';
        }
        this.emitCharToken('{');
        this.scanTemplateExpression();
      } else if (ch === '|') {
        if (literal !== '') {
          this.tokLine = literalLine;
          this.tokCol = literalCol;
          this.emitToken(`'${literal}'`);
          literal = '';
        }
        this.emitCharToken('|');
        return;
      } else {
        if (literal === '') {
          literalLine = this.line;
          literalCol = this.col;
        }
        literal += this.advance();
      }
    }

    if (literal !== '') {
      this.tokLine = literalLine;
      this.tokCol = literalCol;
      this.emitToken(`'${literal}'`);
    }
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
