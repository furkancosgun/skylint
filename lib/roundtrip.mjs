import { Registry, MemoryFile } from '@abaplint/core';

const SYNTAX_KEYS = new Set(['parser_error', 'ambiguous_statement']);

function hashSource(s) {
  let x = 5381;
  for (let i = 0; i < s.length; i++) x = ((x << 5) + x + s.charCodeAt(i)) >>> 0;
  return 'k' + x;
}

export function flattenTokens(tokens) {
  let line = '';
  let prevEnd = 0;
  for (const t of tokens) {
    let gap = t.position.column - prevEnd;
    if (gap < 0) gap = 0;
    prevEnd = t.position.column + String(t.lexeme).length;
    line += ' '.repeat(gap) + t.lexeme;
  }
  return line + '.';
}

export function applyFix(fullLines, offset, snippetLineCount, statements, fix) {
  if (fix?.operations && fix.operations.length > 0) {
    const ops = [...fix.operations].map((op, idx) => {
      const sf = Number(op.context?.statements?.from) || 0;
      const st = Number(op.context?.statements?.to) || sf;
      const tf = Number(op.context?.tokens?.from) || 0;
      const tt = Number(op.context?.tokens?.to) || tf;
      const startAbs = sf > 0 && sf <= statements.length ? offset + statements[sf - 1].position.line - 1 : -1;
      const endAbs = st > 0 && st < statements.length ? offset + statements[st].position.line - 1 : offset + snippetLineCount;
      return { ...op, sf, st, tf, tt, startAbs, endAbs, originalIdx: idx };
    });

    if (ops.some((o) => o.startAbs < 0)) return { skipped: true };

    ops.sort((a, b) => {
      const posA = a.op === 'insert_after' ? a.endAbs + 0.5 : a.startAbs;
      const posB = b.op === 'insert_after' ? b.endAbs + 0.5 : b.startAbs;
      return posB - posA;
    });

    let currentLines = [...fullLines];
    for (const op of ops) {
      if (op.op === 'insert_before') {
        currentLines.splice(op.startAbs, 0, ...op.newCode);
      } else if (op.op === 'insert_after') {
        currentLines.splice(op.endAbs, 0, ...op.newCode);
      } else {
        let newLines;
        if (op.newCode !== null && op.newCode !== undefined && !(op.tf > 0 && op.newCode.length === 0)) {
          newLines = [...op.newCode];
        } else if (op.tf > 0 && op.sf === op.st) {
          const kept = statements[op.sf - 1].tokens.filter((_, i) => i + 1 < op.tf || i + 1 > op.tt);
          newLines = [flattenTokens(kept)];
        } else {
          newLines = [];
        }
        currentLines.splice(op.startAbs, op.endAbs - op.startAbs, ...newLines);
      }
    }
    return { patched: currentLines };
  }

  const ctx = fix?.context;
  if (!ctx) return { skipped: true };
  let sf = Number(ctx.statements?.from) || 0;
  let st = Number(ctx.statements?.to) || 0;
  if (sf < 1) return { skipped: true };
  if (st < sf) st = sf;
  if (sf > statements.length) return { skipped: true };
  if (st > statements.length) st = statements.length;

  const startAbs = offset + statements[sf - 1].position.line - 1;
  const endAbs =
    st < statements.length ? offset + statements[st].position.line - 1 : offset + snippetLineCount;

  const tf = Number(ctx.tokens?.from) || 0;
  let tt = Number(ctx.tokens?.to) || 0;
  if (tt < tf) tt = tf;

  let newLines;
  if (fix.newCode !== null && fix.newCode !== undefined && !(tf > 0 && fix.newCode.length === 0)) {
    newLines = [...fix.newCode];
  } else if (tf > 0 && sf === st) {
    const kept = statements[sf - 1].tokens.filter((_, i) => i + 1 < tf || i + 1 > tt);
    newLines = [flattenTokens(kept)];
  } else if (tf > 0) {
    return { skipped: true };
  } else {
    newLines = [];
  }

  return { patched: [...fullLines.slice(0, startAbs), ...newLines, ...fullLines.slice(endAbs)] };
}

export async function syntaxErrors(source) {
  try {
    const reg = new Registry();
    reg.addFile(new MemoryFile('zcl_qf_roundtrip.clas.abap', source));
    await reg.parseAsync();
    const out = [];
    for (const issue of reg.findIssues()) {
      const key = (issue.getKey() + '').toLowerCase();
      if (!SYNTAX_KEYS.has(key)) continue;
      out.push(`${key}: ${issue.getMessage()}`);
    }
    return out;
  } catch (e) {
    return ['harness: ' + (e?.message || e)];
  }
}

const baselineCache = new Map();

export async function validateFix(fullSource, fullLines, offset, snippetLineCount, statements, fix) {
  const applied = applyFix(fullLines, offset, snippetLineCount, statements, fix);
  if (applied.skipped) return [];
  const key = hashSource(fullSource);
  let baseline = baselineCache.get(key);
  if (baseline === undefined) {
    baseline = await syntaxErrors(fullSource);
    baselineCache.set(key, baseline);
  }
  const patched = await syntaxErrors(applied.patched.join('\n'));
  const known = new Set(baseline);
  return patched.filter((e) => !known.has(e));
}

export async function validateFixtureSyntax(source) {
  try {
    const reg = new Registry();
    reg.addFile(new MemoryFile('zcl_test.clas.abap', source));
    await reg.parseAsync();
    const out = [];
    for (const issue of reg.findIssues()) {
      if (issue.getKey().toLowerCase() === 'parser_error') {
        out.push(`L${issue.getStart().getRow()}: ${issue.getMessage()}`);
      }
    }
    return out;
  } catch (e) {
    return ['harness: ' + (e?.message || e)];
  }
}

