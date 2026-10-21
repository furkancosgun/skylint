import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { RULES, CATEGORIES } from './rules-data.mjs';
import { getCheckDescription, getFindingCode, getPseudoComment, detectQuickFixStatus, readCheckSource } from './check-metadata.mjs';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const rootDir = path.resolve(__dirname, '..');
const checksDir = path.join(rootDir, 'src', 'checks');
const readmePath = path.join(rootDir, 'README.md');

function extractCheckMetadata(rule) {
  const content = readCheckSource(rule);
  if (!content) return null;

  return {
    ruleId: rule.ruleId,
    className: rule.className,
    path: `src/checks/${rule.className.toLowerCase()}.clas.abap`,
    description: getCheckDescription(rule),
    findingCode: getFindingCode(rule),
    pseudoComment: getPseudoComment(rule),
    category: rule.category,
    status: '✅ Done',
    quickfix: detectQuickFixStatus(content),
  };
}

function updateReadmeStats(readme, count) {
  readme = readme.replace(
    /<a href="#-clean-abap--cloud-rule-catalog-\d+-rules"><img src="https:\/\/img\.shields\.io\/badge\/rules-\d+-brightgreen\.svg" alt="Rules" \/><\/a>/g,
    `<a href="#-clean-abap--cloud-rule-catalog-${count}-rules"><img src="https://img.shields.io/badge/rules-${count}-brightgreen.svg" alt="Rules" /></a>`
  );

  readme = readme.replace(
    /(- \*\*)\d+(\s+Clean ABAP Rules:\*\*)/g,
    `$1${count}$2`
  );

  readme = readme.replace(
    /(├── checks\/\s+#\s*)\d+(\s+modular check implementations)(?:[^\n]*)/gi,
    `$1${count}$2`
  );

  readme = readme.replace(
    /(\*\*`src\/checks\/`\*\*:\s*)\d+(\s+modular check classes)/g,
    `$1${count}$2`
  );

  const boxText = `  ⚡ ${count} Rules (if_ci_atc_check)`.padEnd(45, ' ');
  readme = readme.replace(
    /┌─+\s*┐\s*│\s*\d+\s*Rules\s*\(if_ci_atc_check\)\s*│/g,
    `┌${boxText}┐`
  );

  return readme;
}

function generateReadmeCatalog() {
  if (!fs.existsSync(readmePath)) {
    console.error('README.md not found!');
    return;
  }

  let readme = fs.readFileSync(readmePath, 'utf8');
  const total = RULES.length;

  console.log(`Generating README catalog for ${total} rules...`);

  let catalogMd = `## 📋 Clean ABAP & Cloud Rule Catalog (${total} Rules)\n\n`;
  catalogMd += `All Clean ABAP, security, and cloud-native rules implemented in Skylint:\n\n`;
  catalogMd += `| Rule ID | ABAP Class | Description | Pseudo-Comment | QuickFix |\n`;
  catalogMd += `|---|---|---|:---:|:---:|\n`;

  for (const rule of RULES) {
    const meta = extractCheckMetadata(rule);
    if (!meta) continue;

    catalogMd += `| \`${meta.ruleId}\` | [${meta.className}](${meta.path}) | ${meta.description} | \`${meta.pseudoComment}\` | ${meta.quickfix} |\n`;
  }
  catalogMd += `\n---\n\n`;

  const markerRegex = /## [^\n]*Clean ABAP & Cloud Rule Catalog[\s\S]*?(?=## [^\n]*How to Author a Custom Skylint Check)/;
  if (!markerRegex.test(readme)) {
    console.error('Could not locate Rule Catalog section in README.md!');
    return;
  }

  readme = readme.replace(markerRegex, catalogMd);
  readme = updateReadmeStats(readme, total);

  fs.writeFileSync(readmePath, readme, 'utf8');
  console.log('✅ README.md catalog generated successfully.');
}

function main() {
  let missing = 0;
  for (const rule of RULES) {
    const abapFile = path.join(checksDir, `${rule.className.toLowerCase()}.clas.abap`);
    if (!fs.existsSync(abapFile)) {
      console.error(`Missing ABAP class: ${abapFile}`);
      missing++;
    }
  }

  if (missing > 0) {
    console.error(`Found ${missing} missing checks!`);
    process.exit(1);
  }

  console.log(`✅ All ${RULES.length} check classes verified.`);
  generateReadmeCatalog();
}

main();
