import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { RULES, CATEGORIES } from './rules-data.mjs';
import { getRuleDescription, getRuleParameters, isRemoteEnabled } from './rule-metadata.mjs';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const rootDir = path.resolve(__dirname, '..');
const srcDir = path.join(rootDir, 'src');
const rulesDir = path.join(srcDir, 'rules');
const coreDir = path.join(srcDir, 'core');
const atcDir = path.join(srcDir, 'atc');

// abapGit namespaced file prefix: /SKYL/NAME -> (skyl)name
const nsFile = (name) => `(skyl)${name.toLowerCase().replace(/^\/skyl\//, '')}`;

const ATC_CATEGORIES = {
  'clean-abap': {
    code: '/SKYL/CLEAN_ABAP',
    description: 'Skylint: Clean ABAP & Modern Syntax',
  },
  'anti-patterns': {
    code: '/SKYL/ANTI_PATTERNS',
    description: 'Skylint: Anti-Patterns & Bad Practices',
  },
  'performance': {
    code: '/SKYL/PERFORMANCE',
    description: 'Skylint: Performance & Database',
  },
  'security': {
    code: '/SKYL/SECURITY',
    description: 'Skylint: Security & Robustness',
  },
  'metrics': {
    code: '/SKYL/METRICS',
    description: 'Skylint: Metrics & Complexity Limits',
  },
};

export function generateAtcObjects() {
  console.log(`Generating ATC CHKC, CHKO, and CHKV objects for ${RULES.length} rules under src/atc/...`);

  // Ensure src/atc exists
  if (!fs.existsSync(atcDir)) {
    fs.mkdirSync(atcDir, { recursive: true });
  }

  // Clean up any stale files in src/rules/ and src/core/
  for (const d of [rulesDir, coreDir]) {
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

  // 1. Generate Root Category: src/atc/(skyl)main.chkc.json
  const rootCategoryJson = {
    formatVersion: '1',
    header: {
      description: 'Skylint Clean ABAP Rules',
      originalLanguage: 'en',
    },
  };
  fs.writeFileSync(path.join(atcDir, nsFile('/SKYL/MAIN') + '.chkc.json'), JSON.stringify(rootCategoryJson, null, 2) + '\n', 'utf8');

  // 1b. Generate Domain Sub-Categories (matching website categories 1:1)
  for (const cat of Object.values(ATC_CATEGORIES)) {
    const catJson = {
      formatVersion: '1',
      header: {
        description: cat.description,
        originalLanguage: 'en',
      },
      parentCategory: '/SKYL/MAIN',
    };
    fs.writeFileSync(path.join(atcDir, nsFile(cat.code) + '.chkc.json'), JSON.stringify(catJson, null, 2) + '\n', 'utf8');
  }

  // 2. Generate Check Objects (CHKO) in src/atc/
  const selectedChecks = [];
  let checksWithParams = 0;
  for (const rule of RULES) {
    const suffix = rule.className.replace(/^\/SKYL\/CL_/i, '');
    const checkName = `/SKYL/${suffix}`;
    const fileName = `${nsFile(checkName)}.chko.json`;
    const desc = getRuleDescription(rule);
    const params = getRuleParameters(rule);
    const catInfo = ATC_CATEGORIES[rule.category] || { code: '/SKYL/MAIN' };

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

  // 3. Generate Variant (CHKV): src/atc/(skyl)default.chkv.json
  const variantJson = {
    formatVersion: '1',
    header: {
      description: 'Skylint Default Variant (All Rules)',
      originalLanguage: 'en',
    },
    selectedChecks,
  };
  fs.writeFileSync(path.join(atcDir, nsFile('/SKYL/DEFAULT') + '.chkv.json'), JSON.stringify(variantJson, null, 2) + '\n', 'utf8');

  // 4. Generate Registry of compiled ABAP rule classes for live execution.
  // Transpiler emits namespaced objects as #skyl#cl_<trunk>.clas.mjs.
  // The '#' in module specifiers must be %23-escaped (URL resolution);
  // './' relative resolution keeps './%23…' intact.
  const rules = [];
  for (const r of RULES) {
    const clsUpper = r.className.toUpperCase();
    const fileBase = r.className.toLowerCase().replace(/\//g, '#'); // #skyl#cl_x
    const sym = r.className.toLowerCase().replace(/\//g, '$');      // $skyl$cl_x
    rules.push(`  '${clsUpper}': { file: '${fileBase}.clas.mjs', sym: '${sym}' },`);
  }
  const registryCode = `// Auto-generated registry of compiled ABAP rule classes
export const RULE_MODULES = {
${rules.join('\n')}
};
`;
  fs.writeFileSync(path.join(rootDir, 'lib', 'rules-registry.mjs'), registryCode, 'utf8');

  console.log(`✓ Created 1 CHKC (root) + ${Object.keys(ATC_CATEGORIES).length} CHKC (domain), ${RULES.length} CHKO (checks - ${checksWithParams} with parameters), 1 CHKV (variant), and lib/rules-registry.mjs.`);
}

generateAtcObjects();
