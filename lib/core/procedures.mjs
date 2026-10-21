function parseClassDefName(line) {
  const m = /^\s*CLASS\s+(\S+)\s+DEFINITION\b/i.exec(line);
  return m ? m[1].replace(/\.$/, '').toUpperCase() : '';
}

function parseInterfaceName(line) {
  const m = /^\s*INTERFACE\s+(\S+)\b/i.exec(line);
  return m ? m[1].replace(/\.$/, '').toUpperCase() : '';
}

function parseMethodName(line) {
  const m = /^\s*METHOD\s+(\S+)\s*\.\s*$/i.exec(line);
  return m ? m[1].replace(/\.$/, '').toUpperCase() : '';
}

function parseClassImplName(line) {
  const m = /^\s*CLASS\s+(\S+)\s+IMPLEMENTATION\b/i.exec(line);
  return m ? m[1].replace(/\.$/, '').toUpperCase() : '';
}

function parseFormName(line) {
  const m = /^\s*FORM\s+(\S+)\b/i.exec(line);
  return m ? m[1].replace(/\.$/, '').toUpperCase() : '';
}

export function extractAllProcedures(fullLines) {
  const procedures = [];
  let currentImplClass = '';
  let inDef = false;
  let inMeth = false;
  let inForm = false;
  let defBuffer = [];
  let methBuffer = [];
  let formBuffer = [];
  let defName = '';
  let methName = '';
  let formName = '';
  let defOffset = 0;
  let methOffset = 0;
  let formOffset = 0;

  for (let i = 0; i < fullLines.length; i++) {
    const line = fullLines[i];
    const upper = line.trim().toUpperCase();

    const implName = parseClassImplName(line);
    if (implName) {
      currentImplClass = implName;
    }

    if (!inDef && !inMeth && !inForm) {
      const cdefName = parseClassDefName(line);
      const idefName = parseInterfaceName(line);
      if (cdefName || idefName) {
        inDef = true;
        defName = cdefName || idefName;
        defOffset = i;
        defBuffer = [line];
        if (upper.includes('ENDCLASS.') || upper.includes('ENDINTERFACE.')) {
          procedures.push({
            kind: 'DECL',
            name: defName,
            mainKind: idefName ? 'INTF' : 'CLAS',
            mainName: defName,
            snippet: defBuffer,
            offset: defOffset,
          });
          inDef = false;
          defBuffer = [];
        }
        continue;
      }

      const mName = parseMethodName(line);
      if (mName) {
        inMeth = true;
        methName = mName;
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

      const fName = parseFormName(line);
      if (fName) {
        inForm = true;
        formName = fName;
        formOffset = i;
        formBuffer = [line];
        if (upper.includes('ENDFORM.')) {
          procedures.push({
            kind: 'FORM',
            name: formName,
            mainKind: 'PROG',
            mainName: 'ZPLAYGROUND',
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
          mainKind: 'CLAS',
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
    } else if (inForm) {
      formBuffer.push(line);
      if (upper.includes('ENDFORM.')) {
        procedures.push({
          kind: 'FORM',
          name: formName,
          mainKind: 'PROG',
          mainName: 'ZPLAYGROUND',
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

export function resolveProcedureForTarget(procedures, targetMethod) {
  const want = targetMethod.toUpperCase();

  const directClass = procedures.find((p) => p.kind === 'DECL' && p.name === want);
  if (directClass) return directClass;

  const directMethod = procedures.find((p) => p.kind === 'METH' && p.methodName === want);
  if (directMethod) {
    const innerStatements = directMethod.snippet.slice(1, -1).join(' ').trim().toUpperCase();
    if (innerStatements === '' || innerStatements === 'RETURN.') {
      const userDefs = procedures.filter((p) => p.kind === 'DECL' && !p.name.startsWith('ZCL_SKYLINT_TEST_') && !p.name.startsWith('ZCL_TEST_') && !p.name.startsWith('LTCL_'));
      const candidates = userDefs.length >= 2 ? userDefs : procedures.filter((p) => p.kind === 'DECL');
      const numMatch = want.match(/(\d+)$/);
      if (numMatch && candidates.length > 0) {
        const num = parseInt(numMatch[1], 10);
        const idx = (num - 1) % candidates.length;
        return candidates[idx];
      }
    }
    return directMethod;
  }

  const userDefs = procedures.filter((p) => p.kind === 'DECL' && !p.name.startsWith('ZCL_SKYLINT_TEST_') && !p.name.startsWith('ZCL_TEST_') && !p.name.startsWith('LTCL_'));
  const candidates = userDefs.length >= 2 ? userDefs : procedures.filter((p) => p.kind === 'DECL');
  const numMatch = want.match(/(\d+)$/);
  if (numMatch && candidates.length > 0) {
    const num = parseInt(numMatch[1], 10);
    const idx = (num - 1) % candidates.length;
    return candidates[idx];
  }

  return procedures[0] || null;
}
