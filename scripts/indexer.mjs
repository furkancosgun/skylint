import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const rootDir = path.resolve(__dirname, '..');
const checksDir = path.join(rootDir, 'src', 'checks');
const testsDir = path.join(rootDir, 'src', 'tests');
const readmePath = path.join(rootDir, 'README.md');

// Level definitions with boundary ranges
const LEVEL_DEFINITIONS = [
  {
    level: 1,
    title: '### 🟢 Level 1: Beginner / Direct Pattern Matching',
    desc: 'Direct single-statement keyword matching and literal replacements.',
    start: 1,
    end: 10,
  },
  {
    level: 2,
    title: '### 🟡 Level 2: Intermediate / Block Scope & Control Statements',
    desc: 'Structure boundaries, control blocks (`IF`, `CASE`, `LOOP`, `TRY`), and condition evaluation.',
    start: 11,
    end: 25,
  },
  {
    level: 3,
    title: '### 🔵 Level 3: Modern ABAP & OO Architecture',
    desc: 'Modern expression syntax, encapsulation, test double design, and exception hygiene.',
    start: 26,
    end: 35,
  },
  {
    level: 4,
    title: '### 🔴 Level 4: Database Performance & Scope Hygiene',
    desc: 'Cloud database integrity, SQL performance optimization, and variable scope safety.',
    start: 36,
    end: 40,
  },
  {
    level: 5,
    title: '### 🟣 Level 5: Code Quality, Complexity & Structure',
    desc: 'Procedural limits, nesting depth control, typing clarity, and method length.',
    start: 41,
    end: 50,
  },
  {
    level: 6,
    title: '### 🟡 Level 6: Security, Authority & Robust Error Handling',
    desc: 'Authorization enforcement, system variable safety, SQL host escaping, and class-based exceptions.',
    start: 51,
    end: 60,
  },
  {
    level: 7,
    title: '### 🟧 Level 7: Modern Data Types, Literals & Expressions',
    desc: 'Modern literal forms, table expressions, functional constructs, and typing cleanliness.',
    start: 61,
    end: 70,
  },
  {
    level: 8,
    title: '### 🟫 Level 8: Object-Oriented Design & Clean Interfaces',
    desc: 'Encapsulation, component coupling, exception handling, and clean interface design.',
    start: 71,
    end: 80,
  },
  {
    level: 9,
    title: '### 🟦 Level 9: Error Handling, Exception Design & Cloud Safety',
    desc: 'Exception handling, resource disposal, RAP transactional consistency, and Cloud-safe modularization.',
    start: 81,
    end: 90,
  },
  {
    level: 10,
    title: '### 🟪 Level 10: Clean Methods, Security & Modern Syntax',
    desc: 'Method modifiers, modern string built-ins, calculation operators, guard clauses, and dynamic SQL safety.',
    start: 91,
    end: 100,
  },
  {
    level: 11,
    title: '### 🟧 Level 11: Declarations, Modern Table Operations & Assignment',
    desc: 'Declaration hygiene, parameter escaping, and modern table operations.',
    start: 101,
    end: Infinity,
  },
];

/**
 * Delete a check and all its 5 associated files
 */
function deleteCheck(checkIdStr) {
  const num = parseInt(checkIdStr, 10);
  const id = String(num).padStart(3, '0');
  const filesToDelete = [
    path.join(checksDir, `zcl_skylint_check_${id}.clas.abap`),
    path.join(checksDir, `zcl_skylint_check_${id}.clas.testclasses.abap`),
    path.join(checksDir, `zcl_skylint_check_${id}.clas.xml`),
    path.join(testsDir, `zcl_skylint_test_${id}.clas.abap`),
    path.join(testsDir, `zcl_skylint_test_${id}.clas.xml`),
  ];

  let deletedCount = 0;
  for (const f of filesToDelete) {
    if (fs.existsSync(f)) {
      fs.unlinkSync(f);
      deletedCount++;
    }
  }
  console.log(`Deleted check ${id} (${deletedCount} files removed).`);
}

/**
 * Discover existing checks sorted by integer ID
 */
function discoverChecks() {
  const files = fs.readdirSync(checksDir);
  const checkIds = [];
  for (const file of files) {
    const match = file.match(/^zcl_skylint_check_(\d+)\.clas\.abap$/);
    if (match) {
      checkIds.push({
        num: parseInt(match[1], 10),
        id: match[1],
      });
    }
  }
  checkIds.sort((a, b) => a.num - b.num);
  return checkIds;
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
    console.log('Checks are already sequentially indexed.');
    return;
  }

  console.log(`Renumbering ${renames.length} checks...`);

  // To prevent filename collisions during renames, first move to temp names if needed
  const tempPrefix = 'TMP_RENAME_';

  for (const r of renames) {
    const oldFiles = [
      path.join(checksDir, `zcl_skylint_check_${r.oldId}.clas.abap`),
      path.join(checksDir, `zcl_skylint_check_${r.oldId}.clas.testclasses.abap`),
      path.join(checksDir, `zcl_skylint_check_${r.oldId}.clas.xml`),
      path.join(testsDir, `zcl_skylint_test_${r.oldId}.clas.abap`),
      path.join(testsDir, `zcl_skylint_test_${r.oldId}.clas.xml`),
    ];

    for (const f of oldFiles) {
      if (fs.existsSync(f)) {
        const dir = path.dirname(f);
        const base = path.basename(f);
        const tempPath = path.join(dir, `${tempPrefix}${r.newId}_${base}`);
        fs.renameSync(f, tempPath);
      }
    }
  }

  // Now rename temp files to final target names and rewrite contents
  for (const r of renames) {
    const tempMappings = [
      {
        temp: path.join(checksDir, `${tempPrefix}${r.newId}_zcl_skylint_check_${r.oldId}.clas.abap`),
        dest: path.join(checksDir, `zcl_skylint_check_${r.newId}.clas.abap`),
      },
      {
        temp: path.join(checksDir, `${tempPrefix}${r.newId}_zcl_skylint_check_${r.oldId}.clas.testclasses.abap`),
        dest: path.join(checksDir, `zcl_skylint_check_${r.newId}.clas.testclasses.abap`),
      },
      {
        temp: path.join(checksDir, `${tempPrefix}${r.newId}_zcl_skylint_check_${r.oldId}.clas.xml`),
        dest: path.join(checksDir, `zcl_skylint_check_${r.newId}.clas.xml`),
      },
      {
        temp: path.join(testsDir, `${tempPrefix}${r.newId}_zcl_skylint_test_${r.oldId}.clas.abap`),
        dest: path.join(testsDir, `zcl_skylint_test_${r.newId}.clas.abap`),
      },
      {
        temp: path.join(testsDir, `${tempPrefix}${r.newId}_zcl_skylint_test_${r.oldId}.clas.xml`),
        dest: path.join(testsDir, `zcl_skylint_test_${r.newId}.clas.xml`),
      },
    ];

    for (const m of tempMappings) {
      if (fs.existsSync(m.temp)) {
        let content = fs.readFileSync(m.temp, 'utf8');

        // Replace all class identifiers and test class references
        const regexes = [
          new RegExp(`zcl_skylint_check_${r.oldId}`, 'g'),
          new RegExp(`ZCL_SKYLINT_CHECK_${r.oldId}`, 'g'),
          new RegExp(`ltcl_check_${r.oldId}`, 'g'),
          new RegExp(`LTCL_CHECK_${r.oldId}`, 'g'),
          new RegExp(`zcl_skylint_test_${r.oldId}`, 'g'),
          new RegExp(`ZCL_SKYLINT_TEST_${r.oldId}`, 'g'),
          new RegExp(`\\(${r.oldId}\\)`, 'g'),
        ];

        content = content
          .replace(regexes[0], `zcl_skylint_check_${r.newId}`)
          .replace(regexes[1], `ZCL_SKYLINT_CHECK_${r.newId}`)
          .replace(regexes[2], `ltcl_check_${r.newId}`)
          .replace(regexes[3], `LTCL_CHECK_${r.newId}`)
          .replace(regexes[4], `zcl_skylint_test_${r.newId}`)
          .replace(regexes[5], `ZCL_SKYLINT_TEST_${r.newId}`)
          .replace(regexes[6], `(${r.newId})`);

        fs.writeFileSync(m.dest, content, 'utf8');
        fs.unlinkSync(m.temp);
      }
    }
    console.log(`Renumbered check ${r.oldId} -> ${r.newId}`);
  }
}

/**
 * Extract metadata for README generation from check class file
 */
function extractCheckMetadata(id, existingReadmeMap) {
  const filePath = path.join(checksDir, `zcl_skylint_check_${id}.clas.abap`);
  if (!fs.existsSync(filePath)) {
    return null;
  }

  const content = fs.readFileSync(filePath, 'utf8');

  // Extract description
  let description = '';
  const descMatch = content.match(/description\s*=\s*'([^']+)'/);
  if (descMatch) {
    description = descMatch[1].trim();
  }

  // Extract finding code
  let findingCode = '';
  const codeValMatch = content.match(/c_finding_codes[\s\S]*?VALUE\s*'([A-Z0-9_]+)'/);
  if (codeValMatch) {
    findingCode = codeValMatch[1].trim();
  } else {
    const codeMatch = content.match(/code\s*=\s*c_finding_codes-([a-zA-Z0-9_]+)/);
    if (codeMatch) {
      findingCode = codeMatch[1].toUpperCase();
    }
  }

  // Extract pseudo comment
  let pseudoComment = '';
  const pcomMatch = content.match(/c_pseudo_comment\s+TYPE\s+string\s+VALUE\s+'([^']+)'/);
  if (pcomMatch) {
    pseudoComment = pcomMatch[1].trim();
  }

  // Check QuickFix status: preserve from existing README if available, or check testclasses/source
  let quickfix = '⚡ Ready';
  if (existingReadmeMap && existingReadmeMap.has(id)) {
    quickfix = existingReadmeMap.get(id).quickfix;
  }

  return {
    id,
    name: `zcl_skylint_check_${id}`,
    path: `src/checks/zcl_skylint_check_${id}.clas.abap`,
    description,
    findingCode,
    pseudoComment: pseudoComment ? `"#EC ${pseudoComment}"` : '—',
    status: '✅ Done',
    quickfix,
  };
}

/**
 * Parse existing README to preserve manual quickfix flags or descriptions if needed
 */
function parseExistingReadme() {
  if (!fs.existsSync(readmePath)) {
    return new Map();
  }
  const content = fs.readFileSync(readmePath, 'utf8');
  const map = new Map();
  const rowRegex = /\|\s*\*\*(\d+)\*\*\s*\|\s*\[([^\]]+)\]\([^)]+\)\s*\|\s*([^|]+)\|\s*`([^`]+)`\s*\|\s*`([^`]+)`\s*\|\s*([^|]+)\|\s*([^|]+)\|/g;
  let match;
  while ((match = rowRegex.exec(content)) !== null) {
    const id = match[1].padStart(3, '0');
    map.set(id, {
      description: match[3].trim(),
      findingCode: match[4].trim(),
      pseudoComment: match[5].trim(),
      status: match[6].trim(),
      quickfix: match[7].trim(),
    });
  }
  return map;
}

/**
 * Regenerate the Rule Catalog section in README.md
 */
function generateReadmeCatalog(checks) {
  if (!fs.existsSync(readmePath)) {
    console.error('README.md not found!');
    return;
  }

  let readme = fs.readFileSync(readmePath, 'utf8');
  const existingMap = parseExistingReadme();

  const totalChecks = checks.length;
  console.log(`Generating README catalog for ${totalChecks} rules...`);

  // Build catalog markdown
  let catalogMd = `## 📋 Clean ABAP & Cloud Rule Catalog (${totalChecks} Rules)\n\n`;
  catalogMd += `All Clean ABAP, security, and cloud-native rules are organized across 11 focused levels:\n\n`;

  for (const lvl of LEVEL_DEFINITIONS) {
    const lvlChecks = checks.filter(c => c.num >= lvl.start && c.num <= lvl.end);
    if (lvlChecks.length === 0) continue;

    const actualStart = String(lvlChecks[0].num).padStart(3, '0');
    const actualEnd = String(lvlChecks[lvlChecks.length - 1].num).padStart(3, '0');
    const rangeStr = `(${actualStart} - ${actualEnd})`;

    catalogMd += `${lvl.title} ${rangeStr}\n`;
    catalogMd += `${lvl.desc}\n\n`;
    catalogMd += `| ID | Rule Name & Class | Description | Finding Code | Pseudo-Comment | Status | QuickFix |\n`;
    catalogMd += `|:---:|---|---|:---:|:---:|:---:|:---:|\n`;

    for (const c of lvlChecks) {
      const meta = extractCheckMetadata(c.id, existingMap);
      if (!meta) continue;

      catalogMd += `| **${meta.id}** | [${meta.name}](${meta.path}) | ${meta.description} | \`${meta.findingCode}\` | \`${meta.pseudoComment}\` | ${meta.status} | ${meta.quickfix} |\n`;
    }
    catalogMd += `\n---\n\n`;
  }

  // Replace catalog in README.md
  // The catalog is between "## 📋 Clean ABAP & Cloud Rule Catalog" and "## 🚀 How to Author a Custom Skylint Check"
  const startMarker = /## 📋 Clean ABAP & Cloud Rule Catalog[\s\S]*?(?=## 🚀 How to Author a Custom Skylint Check)/;
  if (!startMarker.test(readme)) {
    console.error('Could not locate Rule Catalog section in README.md!');
    return;
  }

  readme = readme.replace(startMarker, catalogMd);
  fs.writeFileSync(readmePath, readme, 'utf8');
  console.log('README.md rule catalog updated successfully.');
}

// Main execution
function main() {
  const args = process.argv.slice(2);

  // Check for --delete argument
  const deleteIdx = args.indexOf('--delete');
  if (deleteIdx !== -1 && args[deleteIdx + 1]) {
    const toDelete = args[deleteIdx + 1].split(',').map(s => s.trim());
    for (const id of toDelete) {
      deleteCheck(id);
    }
  }

  // 1. Discover current checks
  let checks = discoverChecks();

  // 2. Renumber any non-sequential checks
  renumberChecks(checks);

  // 3. Re-discover after renumbering
  checks = discoverChecks();

  // 4. Update README catalog
  generateReadmeCatalog(checks);

  console.log(`\n🎉 Indexer finished! Total active checks: ${checks.length}`);
}

main();
