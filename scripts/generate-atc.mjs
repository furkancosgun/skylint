import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { RULES, CATEGORIES } from './rules-data.mjs';
import { getCheckDescription, getCheckParameters, isRemoteEnabled } from './check-metadata.mjs';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const rootDir = path.resolve(__dirname, '..');
const srcDir = path.join(rootDir, 'src');
const checksDir = path.join(srcDir, 'checks');
const coreDir = path.join(srcDir, 'core');
const atcDir = path.join(srcDir, 'atc');

const ATC_CATEGORIES = {
  'clean-abap': {
    code: 'ZSKYLINT_CLEAN_ABAP',
    fileName: 'zskylint_clean_abap.chkc.json',
    description: 'Skylint: Clean ABAP & Modern Syntax',
  },
  'anti-patterns': {
    code: 'ZSKYLINT_ANTI_PATTERNS',
    fileName: 'zskylint_anti_patterns.chkc.json',
    description: 'Skylint: Anti-Patterns & Bad Practices',
  },
  'performance': {
    code: 'ZSKYLINT_PERFORMANCE',
    fileName: 'zskylint_performance.chkc.json',
    description: 'Skylint: Performance & Database',
  },
  'security': {
    code: 'ZSKYLINT_SECURITY',
    fileName: 'zskylint_security.chkc.json',
    description: 'Skylint: Security & Robustness',
  },
  'metrics': {
    code: 'ZSKYLINT_METRICS',
    fileName: 'zskylint_metrics.chkc.json',
    description: 'Skylint: Metrics & Complexity Limits',
  },
};

export function generateAtcObjects() {
  console.log(`Generating ATC CHKC, CHKO, and CHKV objects for ${RULES.length} rules under src/atc/...`);

  // Ensure src/atc exists
  if (!fs.existsSync(atcDir)) {
    fs.mkdirSync(atcDir, { recursive: true });
  }

  // Clean up any stale files in src/checks/ and src/core/
  for (const d of [checksDir, coreDir]) {
    if (fs.existsSync(d)) {
      for (const f of fs.readdirSync(d)) {
        if (/\.chk[ovc]\.json$/i.test(f)) {
          fs.unlinkSync(path.join(d, f));
        }
      }
    }
  }

  // Clean up existing files in src/atc/
  for (const f of fs.readdirSync(atcDir)) {
    if (/\.chk[ovc]\.json$/i.test(f)) {
      fs.unlinkSync(path.join(atcDir, f));
    }
  }

  // 1. Generate Root Category: src/atc/zskylint.chkc.json
  const rootCategoryJson = {
    formatVersion: '1',
    header: {
      description: 'Skylint Clean ABAP Checks',
      originalLanguage: 'en',
    },
  };
  fs.writeFileSync(path.join(atcDir, 'zskylint.chkc.json'), JSON.stringify(rootCategoryJson, null, 2) + '\n', 'utf8');

  // 1b. Generate Domain Sub-Categories (matching website categories 1:1)
  for (const cat of Object.values(ATC_CATEGORIES)) {
    const catJson = {
      formatVersion: '1',
      header: {
        description: cat.description,
        originalLanguage: 'en',
      },
      parentCategory: 'ZSKYLINT',
    };
    fs.writeFileSync(path.join(atcDir, cat.fileName), JSON.stringify(catJson, null, 2) + '\n', 'utf8');
  }

  // 2. Generate Check Objects (CHKO) in src/atc/
  const selectedChecks = [];
  let checksWithParams = 0;
  for (const rule of RULES) {
    const suffix = rule.className.replace(/^ZCL_SKYLINT_/, '');
    const checkName = `ZSKYLINT_${suffix}`;
    const fileName = `zskylint_${suffix.toLowerCase()}.chko.json`;
    const desc = getCheckDescription(rule);
    const params = getCheckParameters(rule);
    const catInfo = ATC_CATEGORIES[rule.category] || { code: 'ZSKYLINT' };

    const chko = {
      formatVersion: '1',
      header: {
        description: desc,
        originalLanguage: 'en',
      },
      category: catInfo.code,
      implementingClass: rule.className,
      checkType: isRemoteEnabled(rule) ? 'remoteEnabled' : 'local',
    };

    const checkEntry = { checkName };

    if (params && params.length > 0) {
      chko.parameters = params.map(p => ({ name: p.name }));
      checksWithParams++;

      const configuredParams = params
        .filter(p => p.value !== '')
        .map(p => ({ name: p.name, value: p.value }));
      if (configuredParams.length > 0) {
        checkEntry.parameters = configuredParams;
      }
    }

    fs.writeFileSync(path.join(atcDir, fileName), JSON.stringify(chko, null, 2) + '\n', 'utf8');
    selectedChecks.push(checkEntry);
  }

  // 3. Generate Variant (CHKV): src/atc/zskylint_default.chkv.json
  const variantJson = {
    formatVersion: '1',
    header: {
      description: 'Skylint Default Variant (All Rules)',
      originalLanguage: 'en',
    },
    selectedChecks,
  };
  fs.writeFileSync(path.join(atcDir, 'zskylint_default.chkv.json'), JSON.stringify(variantJson, null, 2) + '\n', 'utf8');
  // 4. Generate Registry of compiled ABAP check classes for live execution
  let registryCode = '// Auto-generated registry of compiled ABAP check classes\nexport const CHECK_MODULES = {\n';
  for (const r of RULES) {
    const clsName = r.className.toUpperCase();
    const fileName = r.className.toLowerCase() + '.clas.mjs';
    registryCode += `  '${clsName}': () => import('../output/project/${fileName}'),\n`;
  }
  registryCode += '};\n';
  fs.writeFileSync(path.join(rootDir, 'lib', 'checks-registry.mjs'), registryCode, 'utf8');

  console.log(`✓ Created 1 CHKC (category), ${RULES.length} CHKO (checks - ${checksWithParams} with parameters), 1 CHKV (variant), and lib/checks-registry.mjs.`);
}

generateAtcObjects();
