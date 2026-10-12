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

async function syntaxErrors(source) {
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
