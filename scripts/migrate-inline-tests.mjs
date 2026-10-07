import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const rootDir = path.resolve(__dirname, '..');
const checksDir = path.join(rootDir, 'src', 'checks');
const testsDir = path.join(rootDir, 'src', 'tests');

function discoverIds(dir, prefix) {
  const files = fs.readdirSync(dir);
  const ids = [];
  for (const file of files) {
    const m = file.match(new RegExp(`^${prefix}_(\\d+)\\.clas\\.abap$`));
    if (m) ids.push(m[1]);
  }
  return ids.sort();
}

function escapeLine(line) {
  return line.replace(/`/g, '``');
}

function buildTestclasses(id, fixtureLines, expectedBlock, ltcl) {
  const out = [];
  out.push(`CLASS ${ltcl} DEFINITION FINAL`);
  out.push(`  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.`);
  out.push(``);
  out.push(`  PRIVATE SECTION.`);
  out.push(`    METHODS test_check FOR TESTING RAISING cx_static_check.`);
  out.push(`ENDCLASS.`);
  out.push(``);
  out.push(``);
  out.push(`CLASS ${ltcl} IMPLEMENTATION.`);
  out.push(`  METHOD test_check.`);
  out.push(`    DATA lt_source TYPE string_table.`);
  out.push(``);
  out.push(`    lt_source = VALUE #(`);
  fixtureLines.forEach((ln, idx) => {
    const last = idx === fixtureLines.length - 1 ? ' ) ).' : ' )';
    out.push(`        ( \`${escapeLine(ln)}\`${last}`);
  });
  out.push(``);
  out.push(`    zcl_skylint_test_runner=>run(`);
  out.push(`        io_check    = NEW zcl_skylint_check_${id}( )`);
  out.push(`        it_source   = lt_source`);
  out.push(`        it_expected = ${expectedBlock} ) ).`);
  out.push(`  ENDMETHOD.`);
  out.push(`ENDCLASS.`);
  return out.join('\n') + '\n';
}

function main() {
  const write = process.argv.includes('--write');
  const checkIds = discoverIds(checksDir, 'zcl_skylint_check');
  let migrated = 0;
  const missing = [];
  for (const id of checkIds) {
    const tcPath = path.join(checksDir, `zcl_skylint_check_${id}.clas.testclasses.abap`);
    const fxPath = path.join(testsDir, `zcl_skylint_test_${id}.clas.abap`);
    if (!fs.existsSync(tcPath)) continue;
    if (!fs.existsSync(fxPath)) {
      missing.push(id);
      continue;
    }
    const tc = fs.readFileSync(tcPath, 'utf8');
    const ltclM = tc.match(/CLASS\s+(ltcl_check_\d+)\s+DEFINITION/i);
    const ltcl = ltclM ? ltclM[1] : `ltcl_check_${id}`;
    const expM = tc.match(/it_expected\s*=\s*VALUE\s*#\(([\s\S]*?)\)\s*\)/);
    if (!expM) {
      console.error(`WARN ${id}: it_expected VALUE block not found, skipped`);
      continue;
    }
    const expectedBlock = `VALUE #(${expM[1]})`;
    const fixture = fs.readFileSync(fxPath, 'utf8').replace(/\r\n/g, '\n');
    const lines = fixture.split('\n');
    if (lines.length > 0 && lines[lines.length - 1] === '') lines.pop();
    const next = buildTestclasses(id, lines, expectedBlock, ltcl);
    if (write) fs.writeFileSync(tcPath, next, 'utf8');
    migrated++;
  }
  console.log(`checks=${checkIds.length} migrated=${migrated} missing_fixture=[${missing.join(',')}] mode=${write ? 'WRITE' : 'DRY'}`);
}

main();
