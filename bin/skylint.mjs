#!/usr/bin/env node

import { RULES, CATEGORIES, resolveRule } from '../scripts/rules-data.mjs';
import { spawn } from 'node:child_process';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const rootDir = path.resolve(__dirname, '..');

const args = process.argv.slice(2);
const command = args[0] || 'help';

switch (command) {
  case 'explain':
  case 'info':
  case 'rule': {
    const ruleInput = args[1];
    if (!ruleInput) {
      console.error('Error: Please provide a rule ID. Example: skylint explain prefer-lines');
      process.exit(1);
    }

    const rule = resolveRule(ruleInput);
    if (!rule) {
      console.error(`Error: Unknown rule "${ruleInput}". Run 'skylint list' to see all available rules.`);
      process.exit(1);
    }

    const cat = CATEGORIES[rule.category] || { title: rule.category };

    console.log(`\n\x1b[1m\x1b[36m=== Skylint Rule: ${rule.ruleId} ===\x1b[0m\n`);
    console.log(`  \x1b[1mCategory:\x1b[0m       ${cat.title}`);
    console.log(`  \x1b[1mATC Class:\x1b[0m      ${rule.className}`);
    console.log(`  \x1b[1mPseudo-Comment:\x1b[0m #EC ${rule.pseudoComment}  /  #EC CI_${rule.pseudoComment}`);
    console.log(`  \x1b[1mPragma:\x1b[0m         ##${rule.pseudoComment}  /  ##CI_${rule.pseudoComment}\n`);

    if (rule.example) {
      console.log(`\x1b[31m❌ Non-Compliant Code:\x1b[0m`);
      console.log(rule.example.bad.split('\n').map(l => `  ${l}`).join('\n'));
      console.log(`\n\x1b[32m✅ Compliant Code:\x1b[0m`);
      console.log(rule.example.good.split('\n').map(l => `  ${l}`).join('\n'));
      console.log('');
    }
    break;
  }

  case 'list': {
    console.log(`\n\x1b[1m\x1b[36m=== Skylint Rules Catalog (${RULES.length} Rules) ===\x1b[0m\n`);
    for (const [catKey, catInfo] of Object.entries(CATEGORIES)) {
      const catRules = RULES.filter(r => r.category === catKey);
      console.log(`\x1b[1m\x1b[33m${catInfo.title} (${catRules.length})\x1b[0m`);
      for (const r of catRules) {
        console.log(`  - \x1b[36m${r.ruleId.padEnd(28)}\x1b[0m ${r.className.padEnd(28)} (#EC ${r.pseudoComment})`);
      }
      console.log('');
    }
    break;
  }

  case 'scan':
  case 'lint': {
    const scanArgs = args.slice(1);
    const lintScript = path.join(rootDir, 'scripts', 'lint-folder.mjs');
    const child = spawn(process.execPath, [lintScript, ...scanArgs], {
      stdio: 'inherit',
      cwd: process.cwd(),
    });
    child.on('exit', (code) => process.exit(code || 0));
    break;
  }

  case 'help':
  case '--help':
  case '-h':
  default: {
    console.log(`
\x1b[1m\x1b[36mSkylint\x1b[0m - Enterprise Clean ABAP & Cloud ATC Linter Engine

\x1b[1mUsage:\x1b[0m
  skylint scan <directory> [options]    Scan ABAP source files
  skylint explain <ruleId>              Show rule details with Clean ABAP Bad/Good code
  skylint list                          List all 82 Clean ABAP rules
  skylint help                          Show this help message

\x1b[1mScan Options:\x1b[0m
  --fix                                 Automatically apply QuickFixes to source files
  --filter <ruleId>                     Run only the specified rule
  --min-severity <error|warning|note>   Filter findings by minimum severity
  --json                                Output results as JSON

\x1b[1mExamples:\x1b[0m
  skylint scan ./src
  skylint scan ./src --fix
  skylint explain prefer-new-operator
  skylint explain require-auth-check
  skylint list
`);
    break;
  }
}
