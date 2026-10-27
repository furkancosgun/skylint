// ---------------------------------------------------------------------------
// Procedure extraction from ABAP source files
// Splits code into inspectable procedure units (methods, forms, class/interface definitions)
// ---------------------------------------------------------------------------

function isEmptyBody(snippet) {
  if (!snippet || snippet.length <= 2) return true;
  const inner = snippet.slice(1, -1).join(' ').trim().toUpperCase();
  return inner === '' || inner === 'RETURN.';
}

function resolveFallbackDeclaration(procedures, excludeClassName, want) {
  // Dynamically filter out the wrapper test class itself (no hardcoded prefixes)
  let candidates = procedures.filter(
    (p) => p.kind === 'DECL' && (!excludeClassName || p.name !== excludeClassName),
  );
  if (candidates.length === 0) {
    candidates = procedures.filter((p) => p.kind === 'DECL');
  }
  if (candidates.length === 0) return null;

  const numMatch = want.match(/(\d+)$/);
  if (numMatch) {
    const num = parseInt(numMatch[1], 10);
    const idx = (num - 1) % candidates.length;
    return candidates[idx];
  }
  return candidates[0];
}

export function extractAllProcedures(fullLines) {
  const procedures = [];
  let inDef = false;
  let defName = '';
  let defKind = 'CLAS';
  let defOffset = 0;
  let defBuffer = [];

  let inMeth = false;
  let methName = '';
  let methOffset = 0;
  let methBuffer = [];

  let inForm = false;
  let formName = '';
  let formParams = '';
  let formOffset = 0;
  let formBuffer = [];

  let inFunc = false;
  let funcName = '';
  let funcOffset = 0;
  let funcBuffer = [];

  let currentImplClass = '';

  for (let i = 0; i < fullLines.length; i++) {
    const line = fullLines[i];
    const upper = line.trim().toUpperCase();

    const implMatch = upper.match(/^CLASS\s+(\S+)\s+IMPLEMENTATION\b/);
    if (implMatch) {
      currentImplClass = implMatch[1].replace(/\.$/, '');
    }

    if (!inDef && !inMeth && !inForm && !inFunc) {
      const classDefMatch = upper.match(/^CLASS\s+(\S+)\s+DEFINITION\b/);
      const intfDefMatch = upper.match(/^INTERFACE\s+(\S+)\b/);

      if (classDefMatch || intfDefMatch) {
        inDef = true;
        defKind = intfDefMatch ? 'INTF' : 'CLAS';
        defName = (intfDefMatch ? intfDefMatch[1] : classDefMatch[1]).replace(/\.$/, '');
        defOffset = i;
        defBuffer = [line];
        if (upper.includes('ENDCLASS.') || upper.includes('ENDINTERFACE.')) {
          procedures.push({
            kind: 'DECL',
            name: defName,
            mainKind: defKind,
            mainName: defName,
            snippet: defBuffer,
            offset: defOffset,
          });
          inDef = false;
          defBuffer = [];
        }
        continue;
      }

      const methMatch = upper.match(/^METHOD\s+(\S+)\s*\./);
      if (methMatch) {
        inMeth = true;
        methName = methMatch[1];
        methOffset = i;
        methBuffer = [line];
        if (upper.includes('ENDMETHOD.')) {
          procedures.push({
            kind: 'METH',
            name: `${currentImplClass || 'ZSKYLINT_TEST'}=>${methName}`,
            methodName: methName,
            mainKind: 'CLAS',
            mainName: currentImplClass || 'ZSKYLINT_TEST',
            snippet: methBuffer,
            offset: methOffset,
          });
          inMeth = false;
          methBuffer = [];
        }
        continue;
      }

      const funcMatch = upper.match(/^FUNCTION\s+(\S+)/);
      if (funcMatch && !upper.startsWith('FUNCTION-POOL')) {
        inFunc = true;
        funcName = funcMatch[1].replace(/\.$/, '');
        funcOffset = i;
        funcBuffer = [line];
        if (upper.includes('ENDFUNCTION.')) {
          procedures.push({
            kind: 'FUNC',
            name: funcName,
            mainKind: 'FUGR',
            mainName: 'SAPL' + funcName,
            snippet: funcBuffer,
            offset: funcOffset,
          });
          inFunc = false;
          funcBuffer = [];
        }
        continue;
      }

      const formMatch = upper.match(/^FORM\s+(\S+)(?:\s+(.+))?/);
      if (formMatch) {
        inForm = true;
        formName = formMatch[1].replace(/\.$/, '');
        formParams = formMatch[2] ? formMatch[2].replace(/\.$/, '').trim() : '';
        formOffset = i;
        formBuffer = [line];
        if (upper.includes('ENDFORM.')) {
          procedures.push({
            kind: 'FORM',
            name: formName,
            params: formParams,
            mainKind: 'PROG',
            mainName: 'ZSKYLINT_PROG',
            snippet: formBuffer,
            offset: formOffset,
          });
          inForm = false;
          formBuffer = [];
        }
        continue;
      }
    } else if (inDef) {
      defBuffer.push(line);
      if (upper.includes('ENDCLASS.') || upper.includes('ENDINTERFACE.')) {
        procedures.push({
          kind: 'DECL',
          name: defName,
          mainKind: defKind,
          mainName: defName,
          snippet: defBuffer,
          offset: defOffset,
        });
        inDef = false;
        defBuffer = [];
      }
    } else if (inMeth) {
      methBuffer.push(line);
      if (upper.includes('ENDMETHOD.')) {
        procedures.push({
          kind: 'METH',
          name: `${currentImplClass || 'ZSKYLINT_TEST'}=>${methName}`,
          methodName: methName,
          mainKind: 'CLAS',
          mainName: currentImplClass || 'ZSKYLINT_TEST',
          snippet: methBuffer,
          offset: methOffset,
        });
        inMeth = false;
        methBuffer = [];
      }
    } else if (inFunc) {
      funcBuffer.push(line);
      if (upper.includes('ENDFUNCTION.')) {
        procedures.push({
          kind: 'FUNC',
          name: funcName,
          mainKind: 'FUGR',
          mainName: 'SAPL' + funcName,
          snippet: funcBuffer,
          offset: funcOffset,
        });
        inFunc = false;
        funcBuffer = [];
      }
    } else if (inForm) {
      formBuffer.push(line);
      if (upper.includes('ENDFORM.')) {
        procedures.push({
          kind: 'FORM',
          name: formName,
          params: formParams,
          mainKind: 'PROG',
          mainName: 'ZSKYLINT_PROG',
          snippet: formBuffer,
          offset: formOffset,
        });
        inForm = false;
        formBuffer = [];
      }
    }
  }

  return procedures;
}

/**
 * Resolves the target procedure for a given expected row target identifier.
 * Dynamically resolves direct matches and cleanly falls back to user declarations
 * when a dummy test method wrapper is used.
 */
export function resolveProcedureForTarget(procedures, targetMethod) {
  const want = (targetMethod || '').toUpperCase();

  // 1. Direct exact procedure name match (e.g. LCL_BAD_CTOR=>CONSTRUCTOR or LCL_MY_CLASS)
  const directMatch = procedures.find((p) => p.name === want);
  if (directMatch) {
    if (directMatch.kind === 'METH' && isEmptyBody(directMatch.snippet)) {
      const fallback = resolveFallbackDeclaration(procedures, directMatch.mainName, want);
      return fallback || directMatch;
    }
    return directMatch;
  }

  // 2. Short procedure name match (e.g. TEST_001, MY_FORM, MY_FUNCTION, or CONSTRUCTOR)
  const shortProc = procedures.find(
    (p) =>
      (p.kind === 'METH' && p.methodName === want) ||
      ((p.kind === 'FORM' || p.kind === 'FUNC') && p.name === want),
  );
  if (shortProc) {
    if (shortProc.kind === 'METH' && isEmptyBody(shortProc.snippet)) {
      const fallback = resolveFallbackDeclaration(procedures, shortProc.mainName, want);
      return fallback || shortProc;
    }
    return shortProc;
  }

  // 3. Fallback when targetMethod name isn't matched directly
  const fallback = resolveFallbackDeclaration(procedures, null, want);
  if (fallback) return fallback;

  return procedures[0] || null;
}
