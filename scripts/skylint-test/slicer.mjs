/**
 * scripts/skylint-test/slicer.mjs
 *
 * 1:1 JS port of zcl_skylint_test_runner=>extract_snippet family
 * (src/platform/zcl_skylint_test_runner.clas.abap:128-420).
 * Consolidates the logic previously duplicated in scripts/fill-positions.mjs.
 *
 * extractSnippet(fullLines, method) -> { snippet, isDef, offset, object }
 * - snippet: sliced source lines
 * - isDef: true = class/interface definition block, false = METHOD body
 * - offset: 0-based absolute line offset of the slice in fullLines
 *   (used for abaplint bridge rel-line mapping)
 * - object: enclosing class name (upper) for RTTI / block naming
 */

export function condense(s) {
  return s.replace(/\s+/g, ' ').trim();
}

/** zcl_skylint_test_runner=>class_name_of_line */
export function classNameOfLine(line) {
  const up = condense(line).toUpperCase();
  const words = up.split(' ');
  if (words.length < 2) return '';
  const first = words[0];
  const second = words[1];
  if (first === 'CLASS' && /CLASS .* DEFINITION/.test(up)) {
    return second.replace(/\./g, '');
  }
  if (first === 'INTERFACE') {
    return second.replace(/\./g, '');
  }
  return '';
}

function findEnclosingClass(fullLines, beforeLine) {
  // beforeLine is 1-based (ABAP sy-tabix); lines at index >= beforeLine-1 excluded
  if (beforeLine <= 1) return '';
  let object = '';
  for (let i = 0; i < beforeLine - 1 && i < fullLines.length; i++) {
    const nm = classNameOfLine(fullLines[i]);
    if (nm) object = nm;
  }
  return object;
}

/** zcl_skylint_test_runner=>extract_class_def_block */
function extractClassDefBlock(fullLines, name) {
  const want = condense(name).toUpperCase();
  if (!want) return { snippet: [], offset: 0 };
  const snippet = [];
  let inside = false;
  let offset = 0;
  for (let i = 0; i < fullLines.length; i++) {
    const line = fullLines[i];
    if (!inside) {
      if (classNameOfLine(line) === want) {
        inside = true;
        offset = i;
      } else {
        continue;
      }
    }
    snippet.push(line);
    const t = condense(line).toUpperCase();
    if (t.includes('ENDCLASS.') || t.includes('ENDINTERFACE.')) {
      return { snippet, offset };
    }
  }
  return { snippet: [], offset: 0 };
}

/** zcl_skylint_test_runner=>extract_method (inlined, ABAP has it as method) */
function extractMethod(fullLines, method) {
  const want = condense(method).toUpperCase();
  if (!want) return { snippet: [], found: false, offset: 0 };
  const snippet = [];
  let inside = false;
  let offset = 0;
  for (let i = 0; i < fullLines.length; i++) {
    const line = fullLines[i];
    const upper = condense(line).toUpperCase();
    if (!inside) {
      if (upper === `METHOD ${want}.`) {
        inside = true;
        offset = i;
        snippet.push(line);
        if (upper.includes('ENDMETHOD.')) return { snippet, found: true, offset };
      }
    } else {
      snippet.push(line);
      if (upper.includes('ENDMETHOD.')) return { snippet, found: true, offset };
    }
  }
  return { snippet: [], found: false, offset: 0 };
}

/** zcl_skylint_test_runner=>extract_class_def */
function extractClassDef(fullLines, method) {
  const blocks = [];
  let cur = null;
  for (let i = 0; i < fullLines.length; i++) {
    const line = fullLines[i];
    const upper = condense(line).toUpperCase();
    // NOTE: ABAP checks `lv_upper CS 'CLASS ' AND CS 'DEFINITION'` on the
    // condensed line; fill-positions used raw upper includes — keep includes
    // on raw line to stay bug-compatible with the verified mirror.
    const rawUp = line.toUpperCase();
    if (cur === null) {
      if ((rawUp.includes('CLASS ') && rawUp.includes('DEFINITION')) || rawUp.includes('INTERFACE ')) {
        cur = { snippet: [line], offset: i, object: classNameOfLine(line) };
        if (upper.includes('ENDCLASS.') || upper.includes('ENDINTERFACE.')) {
          blocks.push(cur);
          cur = null;
        }
      }
    } else {
      cur.snippet.push(line);
      if (upper.includes('ENDCLASS.') || upper.includes('ENDINTERFACE.')) {
        blocks.push(cur);
        cur = null;
      }
    }
  }

  const userBlocks = blocks.filter((b) => !b.object.startsWith('ZCL_SKYLINT_TEST_') && !b.object.startsWith('LTCL_'));
  const candidates = userBlocks.length >= 2 ? userBlocks : blocks;
  if (candidates.length === 0) return { snippet: [], isDef: true, offset: 0, object: '' };

  const numMatch = method.toUpperCase().match(/(\d+)$/);
  const num = numMatch ? parseInt(numMatch[1], 10) : 0;
  let idx = 0;
  if (num > 0) {
    if (num <= candidates.length) idx = num - 1;
    else if (num % 2 === 1) idx = 0;
    else idx = Math.min(1, candidates.length - 1);
  }
  const chosen = candidates[idx] || candidates[0];
  return { snippet: chosen.snippet, isDef: true, offset: chosen.offset, object: chosen.object };
}

/** zcl_skylint_test_runner=>extract_snippet */
export function extractSnippet(fullLines, method) {
  const want = method.toUpperCase();

  const blk = extractClassDefBlock(fullLines, want);
  if (blk.snippet.length > 0) {
    return { snippet: blk.snippet, isDef: true, offset: blk.offset, object: want };
  }

  const meth = extractMethod(fullLines, method);
  if (meth.found) {
    const inner = meth.snippet.slice(1, -1).join('\n').trim().toUpperCase();
    // 1-based line number of the METHOD line for find_enclosing_class
    let start1 = 0;
    for (let i = 0; i < fullLines.length; i++) {
      if (condense(fullLines[i]).toUpperCase() === `METHOD ${condense(method).toUpperCase()}.`) {
        start1 = i + 1;
        break;
      }
    }
    const object = findEnclosingClass(fullLines, start1);
    if (inner === '' || inner === 'RETURN.') {
      return extractClassDef(fullLines, method);
    }
    return { snippet: meth.snippet, isDef: false, offset: meth.offset, object };
  }

  return extractClassDef(fullLines, method);
}
