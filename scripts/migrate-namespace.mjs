// ---------------------------------------------------------------------------
// Skylint: one-shot /SKYL/ namespace migration script
// Branch feat/namespace-migration. Rewrites ABAP classes, package files and
// repo documents from ZCL_SKYLINT_* to /SKYL/CL_* and renames directories and
// abapGit/#-style file names accordingly.
// NOT touched intentionally:
//   - deps/**                 (SAP ATC framework stubs, standard naming)
//   - test/fixtures/**        (local JS harness test classes stay Z-named)
//   - finding codes / pseudo comments / ruleIds
// Rerunnable: every step degrades to a no-op when already migrated.
// ---------------------------------------------------------------------------
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';


const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const rootDir = path.resolve(__dirname, '..');

// ---------------------------------------------------------------- mapping --
// Core (framework) classes get individually approved rule-side names; all
// other rule classes use the mechanical prefix swap.
const CORE_TRUNKS = {
  check_base: 'rule_base',
  check_meta_data: 'meta_data',
  ast_util: 'ast_util',
  rtti_util: 'rtti_util',
};

/** Map an ABAP class name; preserves the case style of the input token.
 * UPPERCASE tokens (ABAP wording)   -> /SKYL/CL_…
 * lowercase tokens (identifiers)    -> /skyl/cl_…                          */
function mapClassName(name) {
  const lower = name.toLowerCase();
  if (!lower.startsWith('zcl_skylint_')) return name;
  const trunk = lower.slice('zcl_skylint_'.length);
  // fixture-style test classes are intentionally NOT migrated
  if (trunk.startsWith('test_')) return name;
  const newLower = `/skyl/cl_${CORE_TRUNKS[trunk] ?? trunk}`;
  if (name === name.toUpperCase()) return newLower.toUpperCase();
  return newLower;
}

/** abapGit file naming convention for namespaced objects:
 * /SKYL/CL_<trunk>  ->  #skyl#cl_<trunk>                                  */
function mapFileName(base) {
  return mapClassName(base).toLowerCase().replace(/\//g, '#');
}

// ---------------------------------------------------------------- helpers --
function walkFiles(dir, cb) {
  if (!fs.existsSync(dir)) return;
  for (const entry of fs.readdirSync(dir, { withFileTypes: true })) {
    const p = path.join(dir, entry.name);
    if (entry.isDirectory()) walkFiles(p, cb);
    else cb(p);
  }
}

const CLASS_TOKEN_RE = /zcl_skylint_[a-z0-9_]+/gi;
const applyClassTokens = (text) => text.replace(CLASS_TOKEN_RE, mapClassName);

// Terminology within OUR OWN constructs (SAP keywords stay untouched):
const METHOD_PATTERNS = [
  [/METHODS\s+check\s+ABSTRACT\b/gi, 'METHODS execute ABSTRACT'],
  [/METHODS\s+check\s+REDEFINITION\s*\./gi, 'METHODS execute REDEFINITION.'],
  [/METHOD\s+check\s*\./gi, 'METHOD execute.'],
  [/(?<=^|\s)check\(\s*(<ls_procedure>|is_procedure\S*)/gi, 'execute( $1'],
];
const TYPE_RENAMES = [
  [/ty_check_config/gi, 'ty_rule_config'],
];

function applyMethodRenames(text) {
  let out = text;
  for (const [re, to] of METHOD_PATTERNS) out = out.replace(re, to);
  return out;
}
function applyTypeRenames(text) {
  let out = text;
  for (const [re, to] of TYPE_RENAMES) out = out.replace(re, to);
  return out;
}

let counts = { files: 0, tokens: 0, methods: 0 };

function rewriteFile(file, { methods = false, types = false } = {}) {
  let text = fs.readFileSync(file, 'utf8');
  const before = text;
  text = applyClassTokens(text);
  if (methods) text = applyMethodRenames(text);
  if (types) text = applyTypeRenames(text);
  if (text === before) return;
  fs.writeFileSync(file, text, 'utf8');
  counts.files++;
}

function fsRename(oldAbs, newAbs) {
  fs.renameSync(oldAbs, newAbs);
}

// ---------------------------------------------------------------- step 1  --
// 1a. src/checks -> src/rules (terminology: our rules)
const checksDir = path.join(rootDir, 'src', 'checks');
const rulesDir = path.join(rootDir, 'src', 'rules');
if (fs.existsSync(checksDir) && !fs.existsSync(rulesDir)) {
  fs.renameSync(checksDir, rulesDir);
  console.log('step: src/checks -> src/rules');
} else {
  console.log('step: dir rename skipped');
}

// 1b. Rename ABAP class files to abapGit #skyl# convention.
const coreDir = path.join(rootDir, 'src', 'core');
let renamedClasses = 0;
for (const dir of [rulesDir, coreDir]) {
  if (!fs.existsSync(dir)) continue;
  for (const file of fs.readdirSync(dir)) {
    const m = file.match(/^zcl_skylint_[a-z0-9_]+(\.clas(?:\.(?:xml|abap|testclasses\.abap))?)$/);
    if (!m) continue; // package.devc.xml etc.
    const base = file.split('.')[0];
    const newName = mapFileName(base) + m[1];
    if (newName === file) continue;
    fsRename(path.join(dir, file), path.join(dir, newName));
    renamedClasses++;
  }
}
console.log(`step: ${renamedClasses} class files renamed to #skyl#`);

// 1c. Content rewrite in migrated ABAP/XML sources.
for (const dir of [rulesDir, coreDir]) {
  walkFiles(dir, (file) => {
    if (!/\.(abap|xml)$/.test(file)) return;
    if (file.endsWith('package.devc.xml')) return;
    rewriteFile(file, { methods: true, types: true });
  });
}
console.log(`step: ABAP sources rewritten (${counts.files} files changed so far)`);

// ---------------------------------------------------------------- step 2  --
// 2a. scripts/rules-data.mjs (className registry)
rewriteFile(path.join(rootDir, 'scripts', 'rules-data.mjs'));
// 2b. hand-maintained docs mentioning class names
for (const rel of [
  'README.md',
  'AGENTS.md',
  'docs/index.md',
  'docs/variant-builder.md',
  'docs/guide/getting-started.md',
  'docs/guide/atc-integration.md',
  'docs/guide/configuration.md',
  'docs/guide/suppressions.md',
]) {
  rewriteFile(path.join(rootDir, rel));
}
console.log('step: rules-data.mjs + hand-managed docs rewritten');

// ---------------------------------------------------------------- step 3  --
// 3. Generated artifacts of the old naming: remove (regenerated later by
//    `npm run index`/`generate-atc.mjs` under /SKYL/ naming).
const atcDir = path.join(rootDir, 'src', 'atc');
let removedAtc = 0;
if (fs.existsSync(atcDir)) {
  for (const f of fs.readdirSync(atcDir)) {
    if (/^zskylint_.*\.chk[ovc]\.json$/i.test(f) || f === 'zskylint.chkc.json') {
      fs.rmSync(path.join(atcDir, f));
      removedAtc++;
    }
  }
}
const oldRegistry = path.join(rootDir, 'lib', 'checks-registry.mjs');
if (fs.existsSync(oldRegistry)) fs.rmSync(oldRegistry);
const newRegistry = path.join(rootDir, 'lib', 'rules-registry.mjs');
if (fs.existsSync(newRegistry)) fs.rmSync(newRegistry);
console.log(`step: removed ${removedAtc} zskylint_* AFF files + old lib/checks-registry.mjs`);

console.log('\nDONE. Remaining manual steps: generate-atc.mjs, generate-docs.mjs,');
console.log('check-metadata.mjs -> rule-metadata.mjs, test/run.mjs, loader bridge,');
console.log('abaplint.json, .abapgit.xml, package.devc.xml files, AGENTS.md wording.');
