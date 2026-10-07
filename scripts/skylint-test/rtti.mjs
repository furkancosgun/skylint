/**
 * scripts/skylint-test/rtti.mjs
 *
 * Pure-JS replacement of lcl_abaplint_bridge=>feed_rtti/split_source_files
 * (src/platform/zcl_skylint_test_runner.clas.locals_imp.abap:1322-1433).
 * Transpiles the fixture's full source with @abaplint/transpiler and evaluates
 * it into the shared abap.Classes registry so zcl_skylint_rtti_util live
 * queries (describe_*, is_static_method, get_super_classes, ...) resolve.
 * Results are cached per source hash — same as globalThis.__skylintFed.
 */

const fedByHash = new Map();

export function hashSource(s) {
  let x = 5381;
  for (let i = 0; i < s.length; i++) x = ((x << 5) + x + s.charCodeAt(i)) >>> 0;
  return 'k' + x;
}

/** lcl_abaplint_bridge=>split_source_files */
export function splitSourceFiles(fullSource) {
  const defs = {};
  const order = [];
  let cur = null;
  for (const ln of fullSource.split(/\r?\n/)) {
    let m = /^\s*CLASS\s+(\S+)\s+DEFINITION\b/i.exec(ln);
    if (m) {
      const nm = m[1].replace(/\.$/, '').toUpperCase();
      if (!defs[nm]) {
        defs[nm] = { def: [], impl: [] };
        order.push(nm);
      }
      cur = { name: nm, part: 'def' };
      defs[nm].def.push(ln);
      continue;
    }
    m = /^\s*CLASS\s+(\S+)\s+IMPLEMENTATION\b/i.exec(ln);
    if (m) {
      const nm = m[1].replace(/\.$/, '').toUpperCase();
      if (!defs[nm]) {
        defs[nm] = { def: [], impl: [] };
        order.push(nm);
      }
      cur = { name: nm, part: 'impl' };
      defs[nm].impl.push(ln);
      continue;
    }
    if (/^\s*ENDCLASS\.\s*$/i.test(ln)) {
      if (cur) {
        defs[cur.name][cur.part].push(ln);
        cur = null;
      }
      continue;
    }
    if (cur) defs[cur.name][cur.part].push(ln);
  }
  const files = [];
  for (const nm of order) {
    if (defs[nm].def.length === 0) continue;
    files.push({ filename: nm.toLowerCase() + '.clas.abap', contents: [...defs[nm].def, ...defs[nm].impl].join('\n') });
  }
  return { files, first: order.length > 0 ? order[0] : '' };
}

/**
 * Feed RTTI for a fixture source. `abap` is globalThis.abap (from init.mjs).
 * Safe to call per snippet — transpilation happens once per unique source.
 */
export async function feedRtti(fullSource, objectName, abap) {
  if (!fullSource) return;
  const sn = ((objectName || '').trim() || 'ZSKYLINT_TEST').toUpperCase();
  const key = hashSource(fullSource);
  let fed = fedByHash.get(key);
  if (fed === undefined) {
    fed = await transpileAndEval(fullSource, abap);
    fedByHash.set(key, fed);
  }
  const keys = fed || [];
  const pick = (nm) => keys.find((k) => k === nm) || keys.find((k) => k.endsWith('-' + nm)) || '';
  const det = splitFirst(fullSource);
  const forSn = pick(sn) || pick(det);
  const forDet = pick(det);
  if (forSn && abap.Classes[forSn]) abap.Classes[sn] = abap.Classes[forSn];
  if (det && forDet && abap.Classes[forDet]) abap.Classes[det] = abap.Classes[forDet];
  for (const k of keys) {
    const sh = k.split('-').pop();
    if (sh && !abap.Classes[sh] && abap.Classes[k]) abap.Classes[sh] = abap.Classes[k];
  }
}

function splitFirst(fullSource) {
  return splitSourceFiles(fullSource).first;
}

async function transpileAndEval(fullSource, abap) {
  const { files, first: det } = splitSourceFiles(fullSource);
  if (!det || files.length === 0) return [];
  try {
    const { Transpiler } = await import('@abaplint/transpiler');
    const known = new Set(files.map((f) => f.filename.replace(/\.clas\.abap$/, '').toUpperCase()));
    const extra = [];
    for (const f of files) {
      const re = /INHERITING\s+FROM\s+([A-Za-z0-9_]+)/gi;
      let m;
      while ((m = re.exec(f.contents)) !== null) {
        const sup = m[1].toUpperCase();
        if (!known.has(sup) && !(abap.Classes && abap.Classes[sup])) {
          known.add(sup);
          extra.push({
            filename: sup.toLowerCase() + '.clas.abap',
            contents: `CLASS ${sup} DEFINITION PUBLIC CREATE PUBLIC.\n  PUBLIC SECTION.\nENDCLASS.\nCLASS ${sup} IMPLEMENTATION.\nENDCLASS.`,
          });
        }
      }
    }
    const all = [...extra, ...files];
    let tout;
    try {
      tout = await new Transpiler({ ignoreSyntaxCheck: true, unknownTypes: 'runtimeError' }).runRaw(all);
    } catch {
      return [];
    }
    // topo-sort: parents first
    const parOf = (c) => {
      const pm = /DEFINITION\s+INHERITING\s+FROM\s+(\S+)/i.exec(c || '');
      return pm ? pm[1].replace(/\.$/, '').toLowerCase() + '.clas.abap' : '';
    };
    const byFn = {};
    all.forEach((f) => {
      byFn[f.filename] = f;
    });
    const done = new Set();
    const seq = [];
    let guard = all.length * all.length + 5;
    while (seq.length < all.length && guard-- > 0) {
      let moved = false;
      for (const f of all) {
        if (done.has(f.filename)) continue;
        const pf = parOf(f.contents);
        if (!pf || !byFn[pf] || done.has(pf)) {
          done.add(f.filename);
          seq.push(f);
          moved = true;
        }
      }
      if (!moved) {
        for (const f of all) {
          if (!done.has(f.filename)) {
            done.add(f.filename);
            seq.push(f);
          }
        }
      }
    }
    if (!tout) return [];
    const codeByFn = {};
    tout.objects.forEach((o) => {
      if (o.chunk) codeByFn[o.filename] = o.chunk.getCode();
    });
    let joint = seq.map((f) => codeByFn[f.filename.replace(/\.abap$/, '.mjs')] || codeByFn[f.filename] || '').join('\n;\n');
    for (const o of tout.objects.filter((o) => o.chunk)) {
      if (!joint.includes(o.chunk.getCode())) joint += '\n;\n' + o.chunk.getCode();
    }
    const AsyncFunction = Object.getPrototypeOf(async function () {}).constructor;
    const before = new Set(Object.keys(abap.Classes));
    await new AsyncFunction('abap', joint)(abap);
    return Object.keys(abap.Classes).filter((k) => !before.has(k));
  } catch {
    return [];
  }
}

/** Test hook: clear the transpile cache. */
export function clearCache() {
  fedByHash.clear();
}
