import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { RULES } from './rules-data.mjs';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const rootDir = path.resolve(__dirname, '..');
const checksDir = path.join(rootDir, 'src', 'checks');
const coreDir = path.join(rootDir, 'src', 'core');

function getCheckDescription(rule) {
  const checkFile = path.join(checksDir, `${rule.className.toLowerCase()}.clas.abap`);
  if (fs.existsSync(checkFile)) {
    const content = fs.readFileSync(checkFile, 'utf8');
    const match = content.match(/description\s*=\s*'([^']+)'/);
    if (match) {
      return match[1].replace(/^skylint:\s*/i, '').trim();
    }
  }
  return `Check rule ${rule.ruleId}`;
}

export function generateAtcObjects() {
  console.log(`Generating ATC CHKC, CHKO, and CHKV objects for ${RULES.length} rules...`);

  // 1. Generate Category: src/core/zskylint.chkc.json
  const categoryJson = {
    formatVersion: '1',
    header: {
      description: 'Skylint Clean ABAP Checks',
      originalLanguage: 'en',
      abapLanguageVersion: 'cloudDevelopment',
    },
  };
  fs.writeFileSync(path.join(coreDir, 'zskylint.chkc.json'), JSON.stringify(categoryJson, null, 2) + '\n', 'utf8');

  // 2. Generate Check Objects (CHKO) in src/checks/
  const selectedChecks = [];
  for (const rule of RULES) {
    const suffix = rule.className.replace(/^ZCL_SKYLINT_/, '');
    const checkName = `ZSKYLINT_${suffix}`;
    const fileName = `zskylint_${suffix.toLowerCase()}.chko.json`;
    const desc = getCheckDescription(rule);

    const chko = {
      formatVersion: '1',
      header: {
        description: desc,
        originalLanguage: 'en',
        abapLanguageVersion: 'cloudDevelopment',
      },
      category: 'ZSKYLINT',
      implementingClass: rule.className,
      checkType: 'remoteEnabled',
    };

    fs.writeFileSync(path.join(checksDir, fileName), JSON.stringify(chko, null, 2) + '\n', 'utf8');
    selectedChecks.push({ checkName });
  }

  // 3. Generate Variant (CHKV): src/core/zskylint_default.chkv.json
  const variantJson = {
    formatVersion: '1',
    header: {
      description: 'Skylint Default Variant (All Rules)',
      originalLanguage: 'en',
      abapLanguageVersion: 'cloudDevelopment',
    },
    selectedChecks,
  };
  fs.writeFileSync(path.join(coreDir, 'zskylint_default.chkv.json'), JSON.stringify(variantJson, null, 2) + '\n', 'utf8');

  console.log(`✓ Created 1 CHKC (category), ${RULES.length} CHKO (checks), and 1 CHKV (variant).`);
}

generateAtcObjects();
