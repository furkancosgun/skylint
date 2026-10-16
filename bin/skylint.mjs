#!/usr/bin/env node

import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { RULES, CATEGORIES, resolveRule } from '../scripts/rules-data.mjs';
import { runScanner } from './scanner.mjs';
import { defaultConfigText } from './config.mjs';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const rootDir = path.resolve(__dirname, '..');

const args = process.argv.slice(2);
const command = args[0] || 'help';

function printHelp() {
  console.log(`
\x1b[1m\x1b[36mSkylint\x1b[0m - Modern ABAP Cloud Clean Code Linter & ATC Check Suite

\x1b[1mUSAGE:\x1b[0m
  skylint <command> [arguments] [options]

\x1b[1mCOMMANDS:\x1b[0m
  \x1b[36mscan <folder>\x1b[0m         Scan ABAP files for Clean ABAP rule violations
  \x1b[36mexplain <rule-id>\x1b[0m     Display rule documentation, rationale, and code examples
  \x1b[36mlist\x1b[0m                  List all available Skylint rules categorized
  \x1b[36minit [path]\x1b[0m           Generate default skylint.yaml configuration file
  \x1b[36mhelp\x1b[0m                  Display this help message

\x1b[1mSCAN OPTIONS:\x1b[0m
  \x1b[33m--filter <text>\x1b[0m       Only run checks matching the filter
  \x1b[33m--fix\x1b[0m                 Automatically apply safe QuickFixes
  \x1b[33m--dry-run\x1b[0m             Preview QuickFixes without modifying files
  \x1b[33m--config <file>\x1b[0m       Specify custom skylint.yaml path
  \x1b[33m--json\x1b[0m                Output findings as JSON
  \x1b[33m--sarif\x1b[0m               Output findings as SARIF for GitHub Code Scanning

\x1b[1mEXAMPLES:\x1b[0m
  skylint scan ./src
  skylint scan ./src --fix
  skylint scan ./src --filter prefer-lines
  skylint explain prefer-lines
  skylint list
  skylint init
`);
}

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
    runScanner(scanArgs).catch((err) => {
      console.error(err);
      process.exit(1);
    });
    break;
  }

  case 'init': {
    const targetPath = args[1] ? path.resolve(args[1]) : path.join(process.cwd(), 'skylint.yaml');
    if (fs.existsSync(targetPath)) {
      console.error(`Error: Refusing to overwrite existing file: ${targetPath}`);
      process.exit(2);
    }
    fs.writeFileSync(targetPath, defaultConfigText(), 'utf8');
    console.log(`\x1b[32m✓ Wrote default configuration:\x1b[0m ${targetPath}`);
    break;
  }

  case '-v':
  case '--version':
  case 'version': {
    try {
      const pkg = JSON.parse(fs.readFileSync(path.join(rootDir, 'package.json'), 'utf8'));
      console.log(`Skylint v${pkg.version}`);
    } catch {
      console.log('Skylint v1.0.0');
    }
    break;
  }

  case 'help':
  case '--help':
  case '-h':
  default: {
    if (command !== 'help' && command !== '--help' && command !== '-h') {
      console.error(`Unknown command: ${command}\n`);
    }
    printHelp();
    if (command !== 'help' && command !== '--help' && command !== '-h') {
      process.exit(2);
    }
    break;
  }
}
