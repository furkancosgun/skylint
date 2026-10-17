import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { RULES } from './rules-data.mjs';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const rootDir = path.resolve(__dirname, '..');
const srcDir = path.join(rootDir, 'src');
const checksDir = path.join(srcDir, 'checks');
const coreDir = path.join(srcDir, 'core');
const atcDir = path.join(srcDir, 'atc');

function getCheckDescription(rule) {
  const checkFile = path.join(checksDir, `${rule.className.toLowerCase()}.clas.abap`);
  if (fs.existsSync(checkFile)) {
    const content = fs.readFileSync(checkFile, 'utf8');
    const match = content.match(/description\s*=\s*'([^']+)'/);
    if (match) {
      let desc = match[1].replace(/^skylint:\s*/i, '').trim();
      if (desc.length > 60) {
        throw new Error(`ABAP class ${rule.className} description exceeds 60 characters (${desc.length}): "${desc}"`);
      }
      return desc;
    }
  }
  return `Check rule ${rule.ruleId}`.slice(0, 60);
}

function getCheckParameters(rule) {
  const checkFile = path.join(checksDir, `${rule.className.toLowerCase()}.clas.abap`);
  if (!fs.existsSync(checkFile)) return undefined;

  const content = fs.readFileSync(checkFile, 'utf8');
  const attrMatch = content.match(/attributes\s*=\s*VALUE #\([\s\S]*?\)\s*\)\s*\)/);
  if (!attrMatch) return undefined;

  const bound = [...attrMatch[0].matchAll(/name\s*=\s*['"]([^'"\s]+)['"][\s\S]*?REF #\(\s*([a-zA-Z0-9_]+)\s*\)/g)];
  if (bound.length === 0) return undefined;

  return bound.map(([_, name, varName]) => {
    let value = '';
    const varDecl = content.match(new RegExp('DATA\\s+' + varName + '\\s+TYPE\\s+([^\\.\\n]+)\\.', 'i'));
    if (varDecl) {
      const valMatch = varDecl[1].match(/VALUE\s+([a-zA-Z0-9_]+)/i);
      if (valMatch) {
        const raw = valMatch[1];
        value = raw.toLowerCase() === 'abap_true' ? 'X' : (raw.toLowerCase() === 'abap_false' ? '' : raw);
      }
    }
    return { name, value };
  });
}

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

  // 1. Generate Category: src/atc/zskylint.chkc.json
  const categoryJson = {
    formatVersion: '1',
    header: {
      description: 'Skylint Clean ABAP Checks',
      originalLanguage: 'en',
      abapLanguageVersion: 'cloudDevelopment',
    },
  };
  fs.writeFileSync(path.join(atcDir, 'zskylint.chkc.json'), JSON.stringify(categoryJson, null, 2) + '\n', 'utf8');

  // 2. Generate Check Objects (CHKO) in src/atc/
  const selectedChecks = [];
  let checksWithParams = 0;
  for (const rule of RULES) {
    const suffix = rule.className.replace(/^ZCL_SKYLINT_/, '');
    const checkName = `ZSKYLINT_${suffix}`;
    const fileName = `zskylint_${suffix.toLowerCase()}.chko.json`;
    const desc = getCheckDescription(rule);
    const params = getCheckParameters(rule);

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
      abapLanguageVersion: 'cloudDevelopment',
    },
    selectedChecks,
  };
  fs.writeFileSync(path.join(atcDir, 'zskylint_default.chkv.json'), JSON.stringify(variantJson, null, 2) + '\n', 'utf8');

  console.log(`✓ Created 1 CHKC (category), ${RULES.length} CHKO (checks - ${checksWithParams} with parameters), and 1 CHKV (variant) in src/atc/.`);
}

generateAtcObjects();
