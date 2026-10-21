#!/usr/bin/env node
import fs from 'node:fs';
import { fileURLToPath, pathToFileURL } from 'node:url';
import { scanAbap, checkSyntaxErrors, discoverChecks } from '../../lib/runner/index.mjs';
import { RULES } from '../../scripts/rules-data.mjs';

const availableChecks = discoverChecks(RULES);

async function runPlayground(source, selectedRules = null) {
  const syntaxErrors = checkSyntaxErrors(source);
  if (syntaxErrors.length > 0) {
    return {
      errors: syntaxErrors,
      findings: [],
    };
  }

  const findings = await scanAbap(source, {
    rules: RULES,
    selectedCheckNames: selectedRules ? new Set(selectedRules) : null,
    ruleParams: {},
    objectName: 'ZPLAYGROUND',
  });

  return { errors: [], findings };
}

async function main() {
  const args = process.argv.slice(2);
  const inputFile = args.find((a) => !a.startsWith('--'));
  const filter = args.find((a) => a.startsWith('--filter='))?.split('=')[1];

  let source = '';
  if (inputFile) {
    source = fs.readFileSync(inputFile, 'utf8');
  } else {
    source = `CLASS zcl_playground DEFINITION PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    METHODS execute IMPORTING iv_input TYPE string.
  PRIVATE SECTION.
    DATA mv_data TYPE string.
ENDCLASS.
CLASS zcl_playground IMPLEMENTATION.
  METHOD execute.
    MOVE iv_input TO mv_data.
    IF iv_input IS INITIAL.
      RETURN.
    ENDIF.
    WRITE: / mv_data.
  ENDMETHOD.
ENDCLASS.`;
  }

  const selected = filter ? [filter] : null;
  const result = await runPlayground(source, selected);

  if (result.errors.length > 0) {
    console.log('Syntax Errors:');
    for (const e of result.errors) {
      console.log(`  Line ${e.line}, Col ${e.column}: ${e.message}`);
    }
    return;
  }

  console.log(`Findings (${result.findings.length}):`);
  for (const f of result.findings) {
    console.log(`  [${f.ruleId}] Line ${f.lineNum}:${f.colNum} - ${f.code} - ${f.message}`);
  }
}

if (process.argv[1] && import.meta.url === pathToFileURL(process.argv[1]).href) {
  main().catch((err) => {
    console.error(err);
    process.exit(1);
  });
}
