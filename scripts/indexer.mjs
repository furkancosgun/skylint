import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const rootDir = path.resolve(__dirname, '..');
const checksDir = path.join(rootDir, 'src', 'checks');
const readmePath = path.join(rootDir, 'README.md');

/**
 * Discover all existing check files sorted by their numeric value
 */
function discoverChecks() {
  const files = fs.readdirSync(checksDir);
  const checks = [];

  for (const file of files) {
    const match = file.match(/^zcl_skylint_check_(\d+)\.clas\.abap$/);
    if (match) {
      checks.push({
        num: parseInt(match[1], 10),
        id: match[1],
      });
    }
  }

  checks.sort((a, b) => a.num - b.num);
  return checks;
}

/**
 * Renumber checks to be strictly sequential (001, 002, ...)
 */
function renumberChecks(checks) {
  const renames = [];

  checks.forEach((item, index) => {
    const newNum = index + 1;
    const newId = String(newNum).padStart(3, '0');
    if (item.id !== newId) {
      renames.push({
        oldId: item.id,
        newId: newId,
        oldNum: item.num,
        newNum: newNum,
      });
    }
  });

  if (renames.length === 0) {
    console.log('✓ All checks are already sequentially indexed.');
    return;
  }

  console.log(`Found ${renames.length} check(s) out of order. Renumbering...`);

  const tempPrefix = 'TMP_RENAME_';

  // 1. Move to temporary filenames to avoid overwrite collisions
  for (const r of renames) {
    const files = [
      path.join(checksDir, `zcl_skylint_check_${r.oldId}.clas.abap`),
      path.join(checksDir, `zcl_skylint_check_${r.oldId}.clas.xml`),
    ];

    for (const f of files) {
      if (fs.existsSync(f)) {
        const dir = path.dirname(f);
        const base = path.basename(f);
        fs.renameSync(f, path.join(dir, `${tempPrefix}${r.newId}_${base}`));
      }
    }

    // Fixture dirs live outside checks/: rename the whole directory
    const fixturesDir = path.join(rootDir, 'tests', 'fixtures');
    const oldFixture = path.join(fixturesDir, `check_${r.oldId}`);
    if (fs.existsSync(oldFixture)) {
      fs.renameSync(oldFixture, path.join(fixturesDir, `${tempPrefix}${r.newId}_check_${r.oldId}`));
    }
  }

  // 2. Rename from temp to target names and update identifiers in file content
  const fixturesDir = path.join(rootDir, 'tests', 'fixtures');
  for (const r of renames) {
    const mappings = [
      {
        temp: path.join(checksDir, `${tempPrefix}${r.newId}_zcl_skylint_check_${r.oldId}.clas.abap`),
        dest: path.join(checksDir, `zcl_skylint_check_${r.newId}.clas.abap`),
      },
      {
        temp: path.join(checksDir, `${tempPrefix}${r.newId}_zcl_skylint_check_${r.oldId}.clas.xml`),
        dest: path.join(checksDir, `zcl_skylint_check_${r.newId}.clas.xml`),
      },
    ];

    for (const m of mappings) {
      if (fs.existsSync(m.temp)) {
        let content = fs.readFileSync(m.temp, 'utf8');

        content = content
          .replace(new RegExp(`zcl_skylint_check_${r.oldId}`, 'g'), `zcl_skylint_check_${r.newId}`)
          .replace(new RegExp(`ZCL_SKYLINT_CHECK_${r.oldId}`, 'g'), `ZCL_SKYLINT_CHECK_${r.newId}`)
          .replace(new RegExp(`zcl_skylint_test_${r.oldId}`, 'g'), `zcl_skylint_test_${r.newId}`)
          .replace(new RegExp(`ZCL_SKYLINT_TEST_${r.oldId}`, 'g'), `ZCL_SKYLINT_TEST_${r.newId}`)
          .replace(new RegExp(`\\(${r.oldId}\\)`, 'g'), `(${r.newId})`);

        fs.writeFileSync(m.dest, content, 'utf8');
        fs.unlinkSync(m.temp);
      }
    }

    // Fixture dir: rename + rewrite test-class references inside source.abap
    const tempFixture = path.join(fixturesDir, `${tempPrefix}${r.newId}_check_${r.oldId}`);
    if (fs.existsSync(tempFixture)) {
      const destFixture = path.join(fixturesDir, `check_${r.newId}`);
      for (const f of fs.readdirSync(tempFixture)) {
        const p = path.join(tempFixture, f);
        let content = fs.readFileSync(p, 'utf8');
        content = content
          .replace(new RegExp(`zcl_skylint_test_${r.oldId}`, 'g'), `zcl_skylint_test_${r.newId}`)
          .replace(new RegExp(`ZCL_SKYLINT_TEST_${r.oldId}`, 'g'), `ZCL_SKYLINT_TEST_${r.newId}`);
        fs.writeFileSync(p, content, 'utf8');
      }
      fs.renameSync(tempFixture, destFixture);
    }
    console.log(`Renumbered: ${r.oldId} -> ${r.newId}`);
  }
}

/**
 * Detect QuickFix support purely by inspecting check source code
 */
function detectQuickFixStatus(checkContent) {
  // 1. Checks if check uses base class quickfix helpers or passes details
  const hasQuickFixCall = /quickfix_codes|quickfix_replace|quickfix_insert_before|quickfix_insert_after|quickfix_delete|c_quickfix_codes|io_details/i.test(checkContent);

  // 2. Checks if check has explicit quickfix metadata annotation in comment
  const hasQuickFixComment = /quickfix\s*:\s*(ready|true|enabled|yes)/i.test(checkContent);

  return (hasQuickFixCall || hasQuickFixComment) ? '⚡ Ready' : '—';
}

/**
 * Extract metadata directly from the ABAP check class and test class
 */
function extractCheckMetadata(id) {
  const checkFilePath = path.join(checksDir, `zcl_skylint_check_${id}.clas.abap`);

  if (!fs.existsSync(checkFilePath)) {
    return null;
  }

  const checkContent = fs.readFileSync(checkFilePath, 'utf8');

  const descMatch = checkContent.match(/description\s*=\s*'([^']+)'/);
  let description = descMatch ? descMatch[1].trim() : `Check rule ${id}`;
  description = description.replace(/^skylint:\s*/i, '');

  // 2. Finding Code
  const codeValMatch = checkContent.match(/c_finding_codes[\s\S]*?VALUE\s*'([A-Za-z0-9_]+)'/);
  let findingCode = codeValMatch ? codeValMatch[1].trim() : '';
  if (!findingCode) {
    const codeMatch = checkContent.match(/code\s*=\s*c_finding_codes-([a-zA-Z0-9_]+)/);
    findingCode = codeMatch ? codeMatch[1].toUpperCase() : 'UNKNOWN';
  }

  // 3. Pseudo Comment
  const pcomMatch = checkContent.match(/c_pseudo_comment\s+TYPE\s+string\s+VALUE\s+'([^']+)'/);
  const pseudoComment = pcomMatch ? `"#EC ${pcomMatch[1].trim()}"` : '—';

  // 4. QuickFix Status (read entirely from source code)
  const quickfix = detectQuickFixStatus(checkContent);

  return {
    id,
    name: `zcl_skylint_check_${id}`,
    path: `src/checks/zcl_skylint_check_${id}.clas.abap`,
    description,
    findingCode,
    pseudoComment,
    status: '✅ Done',
    quickfix,
  };
}

/**
 * Generate README.md check catalog purely from source code without levels
 */
function generateReadmeCatalog(checks) {
  if (!fs.existsSync(readmePath)) {
    console.error('README.md not found!');
    return;
  }

  let readme = fs.readFileSync(readmePath, 'utf8');
  const total = checks.length;

  console.log(`Generating README catalog for ${total} rules...`);

  let catalogMd = `## 📋 Clean ABAP & Cloud Rule Catalog (${total} Rules)\n\n`;
  catalogMd += `All Clean ABAP, security, and cloud-native rules implemented in Skylint:\n\n`;
  catalogMd += `| ID | Rule Name & Class | Description | Finding Code | Pseudo-Comment | Status | QuickFix |\n`;
  catalogMd += `|:---:|---|---|:---:|:---:|:---:|:---:|\n`;

  for (const c of checks) {
    const meta = extractCheckMetadata(c.id);
    if (!meta) continue;

    catalogMd += `| **${meta.id}** | [${meta.name}](${meta.path}) | ${meta.description} | \`${meta.findingCode}\` | \`${meta.pseudoComment}\` | ${meta.status} | ${meta.quickfix} |\n`;
  }
  catalogMd += `\n---\n\n`;

  const markerRegex = /## 📋 Clean ABAP & Cloud Rule Catalog[\s\S]*?(?=## 🚀 How to Author a Custom Skylint Check)/;
  if (!markerRegex.test(readme)) {
    console.error('Could not locate Rule Catalog section in README.md!');
    return;
  }

  readme = readme.replace(markerRegex, catalogMd);
  fs.writeFileSync(readmePath, readme, 'utf8');
  console.log('✓ README.md catalog generated successfully.');
}

function main() {
  console.log('🔍 Checking rules indexing...');

  // 1. Discover current checks
  let checks = discoverChecks();

  // 2. Renumber if any gaps/non-sequential
  renumberChecks(checks);

  // 3. Re-read discovered checks after renumbering
  checks = discoverChecks();

  // 4. Generate README catalog
  generateReadmeCatalog(checks);

  console.log(`\n🎉 Indexer complete! Active checks: ${checks.length}`);
}

main();

