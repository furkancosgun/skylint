import { Lexer } from '../core/lexer.mjs';

export function checkSyntaxErrors(code) {
  const errors = [];
  if (!code || !code.trim()) return errors;

  const lines = code.split('\n');

  for (let i = 0; i < lines.length; i++) {
    const line = lines[i];
    const trimmed = line.trim();
    if (trimmed.startsWith('*') || trimmed.startsWith('"')) continue;

    let inSingleQuote = false;
    let inBacktick = false;
    let inPipe = false;

    for (let c = 0; c < line.length; c++) {
      const ch = line[c];
      const prev = c > 0 ? line[c - 1] : '';

      if (ch === '"' && !inSingleQuote && !inBacktick && !inPipe) break;
      if (ch === "'" && !inBacktick && !inPipe) {
        if (!inSingleQuote) inSingleQuote = true;
        else if (c + 1 < line.length && line[c + 1] === "'") c++;
        else inSingleQuote = false;
      } else if (ch === '`' && !inSingleQuote && !inPipe) {
        if (!inBacktick) inBacktick = true;
        else if (c + 1 < line.length && line[c + 1] === '`') c++;
        else inBacktick = false;
      } else if (ch === '|' && !inSingleQuote && !inBacktick && prev !== '\\') {
        inPipe = !inPipe;
      }
    }

    if (inSingleQuote) {
      errors.push({ line: i + 1, column: line.lastIndexOf("'") + 1, message: "Unclosed string literal (')" });
    } else if (inBacktick) {
      errors.push({ line: i + 1, column: line.lastIndexOf('`') + 1, message: 'Unclosed string literal (`)' });
    } else if (inPipe) {
      errors.push({ line: i + 1, column: line.lastIndexOf('|') + 1, message: 'Unclosed string template (|)' });
    }
  }

  let parenDepth = 0;
  let bracketDepth = 0;
  let braceDepth = 0;
  let lastParenPos = { line: 1, col: 1 };
  let lastBracketPos = { line: 1, col: 1 };
  let lastBracePos = { line: 1, col: 1 };

  try {
    const tokens = new Lexer(code).run();
    for (const tok of tokens) {
      const lex = tok.lexeme;
      if (lex.startsWith("'") || lex.startsWith('`') || lex.startsWith('|') || lex.startsWith('"')) continue;

      for (let i = 0; i < lex.length; i++) {
        const ch = lex[i];
        if (ch === '(') {
          parenDepth++;
          lastParenPos = { line: tok.position.line, col: tok.position.column + i };
        } else if (ch === ')') {
          parenDepth--;
          if (parenDepth < 0) {
            errors.push({ line: tok.position.line, column: tok.position.column + i, message: 'Unexpected closing parenthesis ")"' });
            parenDepth = 0;
          }
        } else if (ch === '[') {
          bracketDepth++;
          lastBracketPos = { line: tok.position.line, col: tok.position.column + i };
        } else if (ch === ']') {
          bracketDepth--;
          if (bracketDepth < 0) {
            errors.push({ line: tok.position.line, column: tok.position.column + i, message: 'Unexpected closing bracket "]"' });
            bracketDepth = 0;
          }
        } else if (ch === '{') {
          braceDepth++;
          lastBracePos = { line: tok.position.line, col: tok.position.column + i };
        } else if (ch === '}') {
          braceDepth--;
          if (braceDepth < 0) {
            errors.push({ line: tok.position.line, column: tok.position.column + i, message: 'Unexpected closing brace "}"' });
            braceDepth = 0;
          }
        }
      }
    }

    if (parenDepth > 0) errors.push({ line: lastParenPos.line, column: lastParenPos.col, message: 'Unclosed parenthesis "("' });
    if (bracketDepth > 0) errors.push({ line: lastBracketPos.line, column: lastBracketPos.col, message: 'Unclosed bracket "["' });
    if (braceDepth > 0) errors.push({ line: lastBracePos.line, column: lastBracePos.col, message: 'Unclosed brace "{"' });
  } catch (err) {
    errors.push({ line: err.line || 1, column: err.column || 1, message: err.message || 'Syntax / Lexer error' });
  }

  return errors;
}
