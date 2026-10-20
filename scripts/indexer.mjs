import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { RULES, CATEGORIES } from './rules-data.mjs';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const rootDir = path.resolve(__dirname, '..');
const checksDir = path.join(rootDir, 'src', 'checks');
const readmePath = path.join(rootDir, 'README.md');

/**
 * Detect QuickFix support purely by inspecting check source code
 */
function detectQuickFixStatus(checkContent) {
  const hasQuickFixCall = /quickfix_codes|quickfix_replace|quickfix_insert_before|quickfix_insert_after|quickfix_delete|c_quickfix_codes|io_details/i.test(checkContent);
  const hasQuickFixComment = /quickfix\s*:\s*(ready|true|enabled|yes)/i.test(checkContent);
  return (hasQuickFixCall || hasQuickFixComment) ? '⚡ Ready' : '—';
}

/**
 * Extract metadata directly from the ABAP check class
 */
function extractCheckMetadata(rule) {
  const checkFilePath = path.join(checksDir, `${rule.className.toLowerCase()}.clas.abap`);

  if (!fs.existsSync(checkFilePath)) {
    return null;
  }

  const checkContent = fs.readFileSync(checkFilePath, 'utf8');

  const descMatch = checkContent.match(/description\s*=\s*'([^']+)'/);
  let description = descMatch ? descMatch[1].trim() : `Check rule ${rule.ruleId}`;
  description = description.replace(/^skylint:\s*/i, '');

  const codeValMatch = checkContent.match(/c_finding_codes[\s\S]*?VALUE\s*'([A-Za-z0-9_]+)'/);
  let findingCode = codeValMatch ? codeValMatch[1].trim() : '';
  if (!findingCode) {
    const codeMatch = checkContent.match(/code\s*=\s*c_finding_codes-([a-zA-Z0-9_]+)/);
    findingCode = codeMatch ? codeMatch[1].toUpperCase() : 'UNKNOWN';
  }

  const pcomMatch = checkContent.match(/c_pseudo_comment\s+TYPE\s+string\s+VALUE\s+'([^']+)'/);
  const pseudoComment = pcomMatch ? `"#EC ${pcomMatch[1].trim()}"` : `"#EC ${rule.pseudoComment}"`;

  const quickfix = detectQuickFixStatus(checkContent);

  return {
    ruleId: rule.ruleId,
    className: rule.className,
    path: `src/checks/${rule.className.toLowerCase()}.clas.abap`,
    description,
    findingCode,
    pseudoComment,
    category: rule.category,
    status: '✅ Done',
    quickfix,
  };
}

/**
 * Update global rule counts and statistics across README.md
 */
function updateReadmeStats(readme, count) {
  // 1. Header rules badge and anchor link
  readme = readme.replace(
    /<a href="#-clean-abap--cloud-rule-catalog-\d+-rules"><img src="https:\/\/img\.shields\.io\/badge\/rules-\d+-brightgreen\.svg" alt="Rules" \/><\/a>/g,
    `<a href="#-clean-abap--cloud-rule-catalog-${count}-rules"><img src="https://img.shields.io/badge/rules-${count}-brightgreen.svg" alt="Rules" /></a>`
  );

  // 2. Highlights bullet
  readme = readme.replace(
    /(- \*\*)\d+(\s+Clean ABAP Rules:\*\*)/g,
    `$1${count}$2`
  );

  // 3. Directory tree comment
  readme = readme.replace(
    /(├── checks\/\s+#\s*)\d+(\s+modular check implementations)(?:[^\n]*)/gi,
    `$1${count}$2`
  );

  // 4. Architecture section list item
  readme = readme.replace(
    /(\*\*`src\/checks\/`\*\*:\s*)\d+(\s+modular check classes)/g,
    `$1${count}$2`
  );

  // 5. Architecture ASCII box diagram (if present)
  const boxText = `  • ${count} Rules (if_ci_atc_check)`.padEnd(45, ' ');
  readme = readme.replace(
    /│\s*•\s*\d+\s*Rules\s*\(if_ci_atc_check\)\s*│/g,
    `│${boxText}│`
  );

  return readme;
}

/**
 * Generate README.md check catalog
 */
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

  const markerRegex = /## 📋 Clean ABAP & Cloud Rule Catalog[\s\S]*?(?=## 🚀 How to Author a Custom Skylint Check)/;
  if (!markerRegex.test(readme)) {
    console.error('Could not locate Rule Catalog section in README.md!');
    return;
  }

  readme = readme.replace(markerRegex, catalogMd);
  readme = updateReadmeStats(readme, total);

  fs.writeFileSync(readmePath, readme, 'utf8');
  console.log('✓ README.md catalog generated successfully.');
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

  console.log(`✓ All ${RULES.length} check classes verified.`);
  generateReadmeCatalog();
}

main();
