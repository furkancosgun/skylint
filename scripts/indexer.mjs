import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { RULES } from './rules-data.mjs';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const rootDir = path.resolve(__dirname, '..');
const checksDir = path.join(rootDir, 'src', 'checks');

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
}

main();
