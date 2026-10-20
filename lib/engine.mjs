import * as runtimeModule from '@abaplint/runtime';
import { CHECK_MODULES } from './checks-registry.mjs';
import { Lexer, buildStatements, enrichStatements, extractAllProcedures } from './ast.mjs';
import { buildProcedureValue, buildProceduresTable, buildObjectValue, createFakes } from './harness.mjs';

let runtimeReadyPromise = null;

/**
 * Initializes the lightweight ABAP runtime and loads ATC interface stubs + AST util
 */
export async function ensureRuntime() {
  if (runtimeReadyPromise) return runtimeReadyPromise;
  runtimeReadyPromise = (async () => {
    if (!globalThis.abap) {
      const runtime = runtimeModule.default?.ABAP ? runtimeModule.default : runtimeModule;
      const AbapRuntime = runtime.ABAP || runtimeModule.ABAP || runtimeModule.default?.ABAP || runtimeModule.default;
      globalThis.abap = new AbapRuntime();
    }
    await import('../output/stubs/if_ci_atc_check.intf.mjs');
    await import('../output/stubs/if_ci_atc_check_meta_data.intf.mjs');
    await import('../output/stubs/if_ci_atc_source_code_provider.intf.mjs');
    await import('../output/stubs/cl_ci_atc_quickfixes.clas.mjs');
    await import('../output/project/zcl_skylint_ast_util.clas.mjs');
    await import('../output/project/zcl_skylint_rtti_util.clas.mjs');
    await import('../output/project/zcl_skylint_check_meta_data.clas.mjs');
  })();
  return runtimeReadyPromise;
}

const checkInstancesCache = new Map();

/**
 * Loads and instantiates a compiled ABAP check class
 */
export async function getCheckInstance(className) {
  const upper = className.toUpperCase();
  if (checkInstancesCache.has(upper)) {
    return checkInstancesCache.get(upper);
  }
  const loader = CHECK_MODULES[upper];
  if (!loader) {
    throw new Error(`Check class ${upper} not found in compiled checks registry`);
  }
  const mod = await loader();
  const lower = className.toLowerCase();
  const CheckClass = mod[lower] || mod[upper];
  if (!CheckClass) {
    throw new Error(`Class ${lower} not exported from check module`);
  }
  const inst = new CheckClass();
  await inst.constructor_();
  checkInstancesCache.set(upper, inst);
  return inst;
}

/**
 * Checks for syntax and tokenization errors in ABAP source code
 */
export function checkSyntaxErrors(code) {
  const errors = [];
  if (!code || !code.trim()) return errors;

  const lines = code.split('\n');

  // Line-level unclosed string / template inspection
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

  // Bracket balance
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

/**
 * Universal Native Skylint Rule Runner
 * Executes the real compiled ABAP check classes directly.
 *
 * @param {string} code - ABAP source code from editor
 * @param {object|Set|Array} arg2 - Options object or selectedCheckNames
 * @param {object} [arg3] - ruleParams (if using positional args)
 * @param {Array} [arg4] - rules (if using positional args)
 * @returns {Promise<Array>} List of findings from ABAP check classes
 */
export async function scanAbap(code, arg2 = {}, arg3 = {}, arg4 = []) {
  if (!code || !code.trim()) return [];

  let selectedCheckNames = null;
  let ruleParams = {};
  let rules = [];

  if (arg2 && (arg2 instanceof Set || Array.isArray(arg2))) {
    selectedCheckNames = arg2;
    ruleParams = arg3 || {};
    rules = arg4 || [];
  } else if (typeof arg2 === 'object') {
    rules = arg2.rules || [];
    selectedCheckNames = arg2.selectedCheckNames || null;
    ruleParams = arg2.ruleParams || {};
  }

  const rawLines = code.split('\n');

  // Step 1: Detect syntax and parsing errors
  const syntaxErrors = checkSyntaxErrors(code);
  if (syntaxErrors.length > 0) {
    return syntaxErrors.map((err, idx) => ({
      id: `syntax_err_${err.line}_${err.column}_${idx}`,
      rule: {
        ruleId: 'syntax-error',
        checkName: 'SYNTAX_ERROR',
        description: 'ABAP Syntax Error',
      },
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

  // Step 2: Initialize ABAP runtime and stubs
  await ensureRuntime();

  // Step 3: Extract procedures (class definition, interface, method, form, or fallback single procedure)
  const lines = code.split('\n');
  let extracted = extractAllProcedures(lines);

  let procsData = [];
  try {
    if (extracted.length > 0) {
      for (const p of extracted) {
        const snippetSource = p.snippet.join('\n');
        const tokens = new Lexer(snippetSource).run();
        const stmts = buildStatements(tokens);
        await enrichStatements(stmts, code, p.mainName || 'ZPLAYGROUND', p.methodName || '', p.offset);
        procsData.push({
          kind: p.kind,
          name: p.name,
          mainKind: p.mainKind || 'CLAS',
          mainName: p.mainName || 'ZPLAYGROUND',
          statements: stmts,
          offset: p.offset,
        });
      }
    } else {
      // If no explicit block headers, treat entire code as a single procedure (kind: METH)
      const tokens = new Lexer(code).run();
      const stmts = buildStatements(tokens);
      await enrichStatements(stmts, code, 'ZPLAYGROUND', 'PLAYGROUND', 0);
      procsData.push({
        kind: 'METH',
        name: 'PLAYGROUND',
        mainKind: 'CLAS',
        mainName: 'ZPLAYGROUND',
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

  // Step 4: Build procedure AST values and test fakes
  const procValues = procsData.map((p) => buildProcedureValue(globalThis.abap, p));
  const mainObjName = procsData[0]?.mainName || 'ZPLAYGROUND';
  const proceduresTable = buildProceduresTable(globalThis.abap, procValues);
  const fakes = createFakes(globalThis.abap, proceduresTable, mainObjName);
  const objValue = buildObjectValue(globalThis.abap, mainObjName);

  const findings = [];
  const reportedDedupe = new Set();

  // Filter selected rules
  const activeRules = rules.filter((r) => {
    if (r.remoteEnabled === false || r.remote_enablement === false) return false;
    if (!selectedCheckNames) return true;
    if (selectedCheckNames instanceof Set) return selectedCheckNames.has(r.checkName || r.className);
    if (Array.isArray(selectedCheckNames)) return selectedCheckNames.includes(r.checkName || r.className);
    return true;
  });

  // Step 5: Execute each real ABAP check class
  for (const rule of activeRules) {
    const className = (rule.className || rule.checkName || '').toUpperCase();
    if (!className) continue;

    try {
      const inst = await getCheckInstance(className);

      // Dynamically query check ATC metadata: skip non-remote checks (Zero hardcoding, zero maintenance)
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

      // Bind configured parameters if defined
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
      // Rule failed or not supported in client environment
      console.warn(`[Skylint] Rule ${className} execution failed:`, err);
    }
  }

  return findings;
}

/**
 * Applies a single QuickFix finding to the source code
 */
export function applySingleFix(code, finding) {
  if (!code || !finding || !finding.fixSearch || !finding.fixReplacement) return code;
  return code.replace(finding.fixSearch, finding.fixReplacement);
}

/**
 * Applies all available QuickFixes to the source code in reverse line order
 */
export function applyAllFixes(code, findings) {
  if (!code || !findings || findings.length === 0) return code;
  const fixable = findings.filter((f) => f.hasFix && f.fixSearch && f.fixReplacement);
  if (fixable.length === 0) return code;

  let updatedCode = code;
  const sorted = [...fixable].sort((a, b) => b.lineNum - a.lineNum);
  for (const f of sorted) {
    if (f.fixSearch && f.fixReplacement && updatedCode.includes(f.fixSearch)) {
      updatedCode = updatedCode.replace(f.fixSearch, f.fixReplacement);
    }
  }
  return updatedCode;
}
