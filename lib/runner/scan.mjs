import {
  Lexer,
  buildStatements,
  enrichStatements,
  extractAllProcedures,
} from '../core/ast.mjs';
import { initRuntime } from '../bridge/abap-runtime.mjs';
import {
  buildProcedureValue,
  buildProceduresTable,
  buildObjectValue,
  createFakes,
} from '../bridge/abap-fakes.mjs';
import { getCheckInstance } from '../bridge/abap-loader.mjs';
import { checkSyntaxErrors } from './fix.mjs';

let runtimeReadyPromise = null;

export async function ensureRuntimeReady() {
  if (runtimeReadyPromise) return runtimeReadyPromise;
  runtimeReadyPromise = (async () => {
    await initRuntime();
  })();
  return runtimeReadyPromise;
}

export async function scanProcedures(code, abap, options = {}) {
  const {
    rules = [],
    selectedCheckNames = null,
    ruleParams = {},
    objectName = 'ZPLAYGROUND',
  } = options;

  const rawLines = code.split('\n');

  const syntaxErrors = checkSyntaxErrors(code);
  if (syntaxErrors.length > 0) {
    return syntaxErrors.map((err, idx) => ({
      id: `syntax_err_${err.line}_${err.column}_${idx}`,
      rule: { ruleId: 'syntax-error', checkName: 'SYNTAX_ERROR', description: 'ABAP Syntax Error' },
      ruleId: 'syntax-error',
      checkName: 'SYNTAX_ERROR',
      severity: 'error',
      lineNum: err.line,
      colNum: err.column,
      rawLine: rawLines[err.line - 1] || '',
      code: 'SYNTAX_ERR',
      message: err.message,
      hasFix: false,
    }));
  }

  await ensureRuntimeReady();

  const lines = code.split('\n');
  let extracted = extractAllProcedures(lines);

  let procsData = [];
  try {
    if (extracted.length > 0) {
      for (const p of extracted) {
        const snippetSource = p.snippet.join('\n');
        const tokens = new Lexer(snippetSource).run();
        const stmts = buildStatements(tokens);
        await enrichStatements(stmts, code, p.mainName || objectName, p.methodName || '', p.offset, {
          objectKind: p.mainKind,
        });
        procsData.push({
          kind: p.kind,
          name: p.name,
          mainKind: p.mainKind || 'CLAS',
          mainName: p.mainName || objectName,
          statements: stmts,
          offset: p.offset,
        });
      }
    } else {
      const tokens = new Lexer(code).run();
      const stmts = buildStatements(tokens);
      await enrichStatements(stmts, code, objectName, 'PLAYGROUND', 0, {
        objectKind: 'CLAS',
      });
      procsData.push({
        kind: 'METH',
        name: 'PLAYGROUND',
        mainKind: 'CLAS',
        mainName: objectName,
        statements: stmts,
        offset: 0,
      });
    }
  } catch (err) {
    return [
      {
        id: 'parser_error',
        rule: { ruleId: 'parser-error', checkName: 'PARSER_ERROR', description: 'Parser Failure' },
        ruleId: 'parser-error',
        checkName: 'PARSER_ERROR',
        severity: 'error',
        lineNum: err.line || 1,
        colNum: err.column || 1,
        rawLine: rawLines[(err.line || 1) - 1] || '',
        code: 'PARSER_ERR',
        message: `Parser Error: ${err.message}`,
        hasFix: false,
      },
    ];
  }

  const procValues = procsData.map((p) => buildProcedureValue(abap, p));
  const mainObjName = procsData[0]?.mainName || objectName;
  const proceduresTable = buildProceduresTable(abap, procValues);
  const fakes = createFakes(abap, proceduresTable, mainObjName);
  const objValue = buildObjectValue(abap, mainObjName);

  const findings = [];
  const reportedDedupe = new Set();

  const activeRules = rules.filter((r) => {
    if (r.remoteEnabled === false || r.remote_enablement === false) return false;
    if (!selectedCheckNames) return true;
    if (selectedCheckNames instanceof Set) return selectedCheckNames.has(r.checkName || r.className);
    if (Array.isArray(selectedCheckNames)) return selectedCheckNames.includes(r.checkName || r.className);
    return true;
  });

  for (const rule of activeRules) {
    const className = (rule.className || rule.checkName || '').toUpperCase();
    if (!className) continue;

    try {
      const inst = await getCheckInstance(abap, className);

      if (typeof inst['if_ci_atc_check$get_meta_data'] === 'function') {
        const meta = await inst['if_ci_atc_check$get_meta_data']();
        const metaObj = meta && meta.get ? meta.get() : meta;
        if (metaObj && typeof metaObj['if_ci_atc_check_meta_data$is_remote_enabled'] === 'function') {
          const isRemote = await metaObj['if_ci_atc_check_meta_data$is_remote_enabled']();
          const remoteVal = isRemote && typeof isRemote.get === 'function' ? isRemote.get() : isRemote;
          if (remoteVal !== 'X') {
            continue;
          }
        }
      }

      const params = ruleParams[rule.checkName || className];
      if (params) {
        for (const [pName, pVal] of Object.entries(params)) {
          const memberName = `mv_${pName.toLowerCase()}`;
          if (inst[memberName] && typeof inst[memberName].set === 'function') {
            inst[memberName].set(pVal);
          }
        }
      }

      await inst['if_ci_atc_check$set_assistant_factory']({ factory: fakes.factory });
      const res = await inst['if_ci_atc_check$run']({
        object: objValue,
        data_provider: fakes.provider,
      });

      const rows = res.array ? res.array() : res.get();
      for (const r of rows) {
        const g = r.get();
        const pos = g.location.get().position.get();
        const lineNum = pos.line.get();
        const colNum = pos.column.get();

        const dedupeKey = `${rule.ruleId}:${lineNum}:${colNum}`;
        if (reportedDedupe.has(dedupeKey)) continue;
        reportedDedupe.add(dedupeKey);

        const det = g.details ? (typeof g.details.get === 'function' ? g.details.get() : g.details) : null;
        const fixObj = det && det.fixes && det.fixes[0];

        let fixSearch = null;
        let fixReplacement = null;

        if (fixObj && fixObj.newCode) {
          const fromIdx = lineNum - 1;
          const toIdx = lineNum - 1;
          if (fromIdx >= 0 && fromIdx < rawLines.length) {
            fixSearch = rawLines.slice(fromIdx, toIdx + 1).join('\n');
            fixReplacement = fixObj.newCode.join('\n');
          }
        }

        findings.push({
          id: `${rule.ruleId}_${lineNum}_${colNum}`,
          rule,
          ruleId: rule.ruleId,
          checkName: rule.checkName || className,
          lineNum,
          colNum,
          rawLine: rawLines[lineNum - 1] || '',
          code: g.code.get().trim(),
          message: rule.findingTexts?.[0] || rule.title || rule.description,
          hasFix: Boolean(fixSearch && fixReplacement),
          fixSearch,
          fixReplacement,
        });
      }
    } catch (err) {
      console.warn(`[Skylint] Rule ${className} execution failed:`, err);
    }
  }

  return findings;
}

export async function scanAbap(code, options = {}) {
  const abap = globalThis.abap;
  if (!abap) {
    await ensureRuntimeReady();
  }
  return scanProcedures(code, globalThis.abap, options);
}
