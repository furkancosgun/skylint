import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { RULES } from './rules-data.mjs';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const rootDir = path.resolve(__dirname, '..');
const checksDir = path.join(rootDir, 'src', 'checks');
const outPath = path.join(rootDir, 'lib', 'checks-registry.mjs');

function main() {
  const entries = [];
  let missing = 0;

  for (const rule of RULES) {
    const clsName = rule.className.toLowerCase();
    const abapFile = path.join(checksDir, `${clsName}.clas.abap`);
    if (!fs.existsSync(abapFile)) {
      console.error(`Missing ABAP class: ${abapFile}`);
      missing++;
      continue;
    }
    entries.push(`  '${rule.className.toUpperCase()}': () => import('../output/project/${clsName}.clas.mjs'),`);
  }

  if (missing > 0) {
    console.error(`Found ${missing} missing checks!`);
    process.exit(1);
  }

  const header = '// Auto-generated registry of compiled ABAP check classes\n// Run: npm run index\n// Do not edit manually.\n\nexport const CHECK_MODULES = {\n';
  const footer = '};\n';
  const content = header + entries.join('\n') + '\n' + footer;

  fs.writeFileSync(outPath, content, 'utf8');
  console.log(`✅ Registry generated: ${outPath} (${entries.length} checks)`);
}

main();
