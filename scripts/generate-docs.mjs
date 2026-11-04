import fs from 'node:fs';
import path from 'node:path';
import { execSync } from 'node:child_process';
import { fileURLToPath } from 'node:url';
import { RULES, CATEGORIES } from './rules-data.mjs';
import { extractAttributes, isRemoteEnabled, ruleFileBase, ruleShortName } from './rule-metadata.mjs';


const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const rootDir = path.resolve(__dirname, '..');
const docsDir = path.join(rootDir, 'docs');
const rulesDocsDir = path.join(docsDir, 'rules');
const guideDocsDir = path.join(docsDir, 'guide');
const fixturesDir = path.join(rootDir, 'test', 'fixtures');
const rulesDir = path.join(rootDir, 'src', 'rules');

// Ensure directories exist
fs.mkdirSync(rulesDocsDir, { recursive: true });
fs.mkdirSync(guideDocsDir, { recursive: true });
fs.mkdirSync(path.join(docsDir, '.vitepress'), { recursive: true });

// Clean up stale rule doc files
const validRuleFiles = new Set(RULES.map(r => `${r.ruleId}.md`));
validRuleFiles.add('index.md');
for (const catKey of Object.keys(CATEGORIES)) {
  validRuleFiles.add(`${catKey}.md`);
}
for (const file of fs.readdirSync(rulesDocsDir)) {
  if (file.endsWith('.md') && !validRuleFiles.has(file)) {
    fs.unlinkSync(path.join(rulesDocsDir, file));
  }
}

function validateRulesCompleteness() {
  const errors = [];
  const validCategories = new Set(Object.keys(CATEGORIES));

  // 1. Check all ABAP class files vs rules-data
  const ruleFiles = fs.readdirSync(rulesDir).filter(f => f.endsWith('.clas.abap'));
  const utilityClasses = new Set([
    '#skyl#cl_rule_base.clas.abap',
    '#skyl#cl_meta_data.clas.abap',
    '#skyl#cl_ast_util.clas.abap',
    '#skyl#cl_rtti_util.clas.abap'
  ]);
  const registeredClassMap = new Map(RULES.map(r => [ruleFileBase(r), r]));

  // Check for rule files on disk that are NOT registered in rules-data.mjs
  for (const file of ruleFiles) {
    if (utilityClasses.has(file)) continue;
    const fileBase = file.replace(/\.clas\.abap$/, '');
    if (!registeredClassMap.has(fileBase)) {
      errors.push(`[UNREGISTERED RULE] Found rule class '${file}' in src/rules/ but it is NOT registered in rules-data.mjs!`);
    }
  }

  // 2. Comprehensive check for each rule in rules-data.mjs
  for (const rule of RULES) {
    const abapFile = path.join(rulesDir, `${ruleFileBase(rule)}.clas.abap`);
    const xmlFile = path.join(rulesDir, `${ruleFileBase(rule)}.clas.xml`);

    if (!fs.existsSync(abapFile)) {
      errors.push(`[MISSING ABAP FILE] Rule '${rule.ruleId}' specifies class '${rule.className}' but '${abapFile}' does not exist!`);
      continue;
    }
    if (!fs.existsSync(xmlFile)) {
      errors.push(`[MISSING XML FILE] Rule '${rule.ruleId}' specifies class '${rule.className}' but '${xmlFile}' does not exist!`);
      continue;
    }

    const abapContent = fs.readFileSync(abapFile, 'utf8');
    const xmlContent = fs.readFileSync(xmlFile, 'utf8');

    // Category validity
    if (!validCategories.has(rule.category)) {
      errors.push(`[INVALID CATEGORY] Rule '${rule.ruleId}' has invalid category '${rule.category}'!`);
    }

    // Pseudo-comment match between ABAP constant and rules-data
    const pcomMatch = abapContent.match(/c_pseudo_comment\s+TYPE\s+string\s+VALUE\s+'([^']+)'/);
    if (pcomMatch) {
      const classPcom = pcomMatch[1].trim();
      if (classPcom !== rule.pseudoComment) {
        errors.push(`[PSEUDO-COMMENT MISMATCH] Rule '${rule.ruleId}': ABAP class defines '${classPcom}', but rules-data.mjs has '${rule.pseudoComment}'!`);
      }
    }

    // XML CLSNAME match
    const clsMatch = xmlContent.match(/<CLSNAME>([^<]+)<\/CLSNAME>/);
    if (clsMatch && clsMatch[1].trim() !== rule.className) {
      errors.push(`[XML CLSNAME MISMATCH] Rule '${rule.ruleId}': XML CLSNAME is '${clsMatch[1].trim()}', but class is '${rule.className}'!`);
    }

    // Finding code length & prefix in ABAP class
    const codeValMatch = abapContent.match(/c_finding_codes[\s\S]*?VALUE\s*'([A-Za-z0-9_]+)'/);
    if (codeValMatch) {
      const fc = codeValMatch[1].trim();
      if (fc.length > 10) {
        errors.push(`[FINDING CODE TOO LONG] Finding code '${fc}' exceeds SAP ATC 10-char limit in ${rule.className}!`);
      }
      if (!/^(PREF_|NO_|MAX_)/.test(fc)) {
        errors.push(`[INVALID FINDING CODE PREFIX] Finding code '${fc}' must start with PREF_, NO_, or MAX_ in ${rule.className}!`);
      }
    }

    // Constructor description length and prefix
    const descMatch = abapContent.match(/description\s*=\s*'([^']+)'/);
    if (descMatch) {
      const desc = descMatch[1];
      if (desc.startsWith('skylint:')) {
        errors.push(`[CONSTRUCTOR PREFIX INVALID] Description in ${rule.className} constructor should not start with 'skylint:'!`);
      }
      if (desc.length > 60) {
        errors.push(`[CONSTRUCTOR DESC TOO LONG] Description in ${rule.className} constructor exceeds 60 chars (${desc.length})!`);
      }
    }

    // XML description prefix
    const xmlDescMatch = xmlContent.match(/<DESCRIPT>([^<]+)<\/DESCRIPT>/);
    if (xmlDescMatch && !xmlDescMatch[1].trim().startsWith('skylint:')) {
      errors.push(`[XML DESC MISSING PREFIX] Description in ${rule.className}.clas.xml must start with 'skylint:'!`);
    }

    // Bidirectional parameter parity!
    const attrs = extractAttributes(abapContent);
    const classParamNames = new Set(attrs.map(a => a.name));
    const ruleParamNames = new Set(Object.keys(rule.parameters || {}));

    // Missing parameter in rules-data
    for (const p of classParamNames) {
      if (!ruleParamNames.has(p)) {
        errors.push(`[MISSING PARAMETER GUIDANCE] Rule '${rule.ruleId}' (${rule.className}) parameter '${p}' is defined in ABAP but missing in rules-data.mjs!`);
      } else {
        const desc = rule.parameters[p];
        if (typeof desc !== 'string' || desc.trim().length < 10) {
          errors.push(`[PARAMETER GUIDANCE TOO SHORT] Rule '${rule.ruleId}' parameter '${p}' guidance is too brief/placeholder!`);
        }
      }
    }

    // Stale parameter in rules-data that was removed/renamed from class
    for (const p of ruleParamNames) {
      if (!classParamNames.has(p)) {
        errors.push(`[STALE PARAMETER] Rule '${rule.ruleId}' documents parameter '${p}' in rules-data.mjs, but it was REMOVED from ${rule.className}!`);
      }
    }

    // Parameters declared on non-parameterized class
    if (attrs.length === 0 && rule.parameters && Object.keys(rule.parameters).length > 0) {
      errors.push(`[EXTRANEOUS PARAMETERS] Rule '${rule.ruleId}' has parameters in rules-data.mjs, but ${rule.className} has 0 attributes!`);
    }

    // SEO metadata checks
    if (!rule.seo) {
      errors.push(`[MISSING SEO] Rule '${rule.ruleId}' is missing the 'seo' metadata object!`);
    } else {
      if (!rule.seo.description || typeof rule.seo.description !== 'string' || rule.seo.description.trim().length < 40) {
        errors.push(`[SEO DESCRIPTION TOO SHORT] Rule '${rule.ruleId}' requires a comprehensive meta description (>= 40 chars)!`);
      }
      if (!Array.isArray(rule.seo.keywords) || rule.seo.keywords.length < 3) {
        errors.push(`[SEO KEYWORDS INSUFFICIENT] Rule '${rule.ruleId}' must have at least 3 relevant SEO keywords!`);
      }
    }

    // Core content checks
    if (!rule.title || rule.title.trim().length < 10) {
      errors.push(`[TITLE TOO SHORT] Rule '${rule.ruleId}' requires a clear, informative title (>= 10 chars)!`);
    }
    if (!rule.rationale || rule.rationale.trim().length < 30) {
      errors.push(`[RATIONALE TOO SHORT] Rule '${rule.ruleId}' requires a substantive architectural rationale (>= 30 chars)!`);
    }
    if (!rule.example || !rule.example.bad || !rule.example.good) {
      errors.push(`[MISSING EXAMPLES] Rule '${rule.ruleId}' must include both 'bad' and 'good' code examples!`);
    }

    // Related rules check (declaratively defined in rules-data.mjs)
    if (!Array.isArray(rule.relatedRules) || rule.relatedRules.length < 2) {
      errors.push(`[MISSING RELATED RULES] Rule '${rule.ruleId}' must declare at least 2 relatedRules in rules-data.mjs!`);
    } else {
      for (const relId of rule.relatedRules) {
        if (relId === rule.ruleId) {
          errors.push(`[SELF REFERENCE] Rule '${rule.ruleId}' cannot reference itself in relatedRules!`);
        }
        if (!registeredClassMap.has(relId) && !RULES.some(r => r.ruleId === relId)) {
          errors.push(`[INVALID RELATED RULE] Rule '${rule.ruleId}' references unknown related rule '${relId}'!`);
        }
      }
    }
  }

  if (errors.length > 0) {
    console.error(`\n❌ Comprehensive validation failed with ${errors.length} error(s):`);
    for (const err of errors) {
      console.error(`  - ${err}`);
    }
    process.exit(1);
  }

  console.log(`✓ Validation passed: all ${RULES.length} rules verified (all registered, SEO tags complete, parameter parity 100%).`);
}

validateRulesCompleteness();

function extractSnippet(lines, methodName) {
  const upper = methodName.toUpperCase();
  let inside = false;
  const buffer = [];

  for (const line of lines) {
    const trimmed = line.trim();
    if (new RegExp(`^METHOD\\s+${upper}\\b`, 'i').test(trimmed)) {
      inside = true;
      continue;
    }
    if (inside) {
      if (/^ENDMETHOD\b/i.test(trimmed)) {
        break;
      }
      buffer.push(line);
    }
  }

  if (buffer.length === 0) return '';
  const minIndent = buffer.reduce((min, l) => {
    if (l.trim() === '') return min;
    const match = l.match(/^(\s*)/);
    return Math.min(min, match ? match[1].length : 0);
  }, 999);

  return buffer.map((l) => (l.length >= minIndent ? l.slice(minIndent) : l)).join('\n').trim();
}


console.log(`Generating rich enterprise documentation for ${RULES.length} rules...`);

// Load default parameters from src/atc/(skyl)default.chkv.json
const chkvPath = path.join(rootDir, 'src', 'atc', '(skyl)default.chkv.json');
const defaultParamsMap = {};
if (fs.existsSync(chkvPath)) {
  const chkv = JSON.parse(fs.readFileSync(chkvPath, 'utf8'));
  for (const item of chkv.selectedChecks || []) {
    if (item.parameters) {
      defaultParamsMap[item.checkName] = item.parameters;
    }
  }
}

let totalQuickFixes = 0;
const catalogRules = [];

// Map each ruleId to its exact line number in scripts/rules-data.mjs for one-click GitHub editing
const rulesDataRaw = fs.readFileSync(path.join(rootDir, 'scripts', 'rules-data.mjs'), 'utf8');
const ruleLineMap = new Map();
rulesDataRaw.split('\n').forEach((line, idx) => {
  const match = line.match(/"ruleId":\s*"([^"]+)"/);
  if (match) {
    ruleLineMap.set(match[1], idx + 1);
  }
});

for (const rule of RULES) {
  const checkFile = path.join(rulesDir, `${ruleFileBase(rule)}.clas.abap`);
  let classDesc = rule.ruleId;
  let severity = 'warning';
  let hasQuickfix = false;
  let attributes = [];
  let findingTexts = [];

  if (fs.existsSync(checkFile)) {
    const content = fs.readFileSync(checkFile, 'utf8');
    const descMatch = content.match(/description\s*=\s*'([^']+)'/);
    if (descMatch) classDesc = descMatch[1].replace(/^skylint:\s*/i, '').trim();

    const sevMatch = content.match(/severity\s*=\s*if_ci_atc_check=>finding_severities-([a-z]+)/);
    if (sevMatch) severity = sevMatch[1];

    hasQuickfix = /quickfix_codes|quickfix_replace|quickfix_delete/i.test(content);
    if (hasQuickfix) totalQuickFixes++;

    attributes = extractAttributes(content);

    const fMatches = [...content.matchAll(/(?<![_a-zA-Z])text\s*=\s*(?:'([^']+)'|\|([^|]+)\|)/g)].map((x) => (x[1] || x[2]).trim());
    if (fMatches.length > 0) {
      findingTexts = fMatches;
    }
  }

  const meta = {
    title: rule.title || rule.ruleId,
    rationale: rule.rationale || classDesc,
  };

  const remoteEnabled = isRemoteEnabled(rule);

  // Prioritize canonical Clean ABAP example from RULES, fallback to fixture
  let nonCompliantCode = rule.example?.bad || '';
  let compliantCode = rule.example?.good || '';

  if (!nonCompliantCode || !compliantCode) {
    const shortName = ruleShortName(rule);
    const fixtureDir = fs.existsSync(path.join(fixturesDir, shortName))
      ? path.join(fixturesDir, shortName)
      : path.join(fixturesDir, rule.ruleId);
    if (fs.existsSync(fixtureDir)) {
      const sourcePath = path.join(fixtureDir, 'source.abap');
      const expectedPath = path.join(fixtureDir, 'expected.json');

      if (fs.existsSync(sourcePath) && fs.existsSync(expectedPath)) {
        const sourceLines = fs.readFileSync(sourcePath, 'utf8').split('\n');
        const expected = JSON.parse(fs.readFileSync(expectedPath, 'utf8'));

        const failRow = expected.find((r) => r.code !== null);
        const passRow = expected.find((r) => r.code === null);

        if (!nonCompliantCode && failRow && failRow.method) {
          nonCompliantCode = extractSnippet(sourceLines, failRow.method);
        }
        if (!compliantCode && passRow && passRow.method) {
          compliantCode = extractSnippet(sourceLines, passRow.method);
        }
      }
    }
  }

  const categoryInfo = CATEGORIES[rule.category] || { title: rule.category };

  // Rule Page Title with SEO frontmatter
  const seoDesc = (rule.seo?.description || classDesc || '').replace(/"/g, '\\"');
  const seoTitle = (meta.title || '').replace(/"/g, '\\"');
  const seoKeywords = rule.seo?.keywords ? rule.seo.keywords.join(', ') : '';
  const severityType = severity === 'error' ? 'danger' : severity === 'note' ? 'info' : 'warning';
  const severityLabel = severity.charAt(0).toUpperCase() + severity.slice(1);
  const ruleLineNumber = ruleLineMap.get(rule.ruleId) || 1;
  const ruleEditUrl = `https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L${ruleLineNumber}`;

  let ruleDoc = `---\ntitle: "${seoTitle}"\ndescription: "${seoDesc}"\n`;
  if (seoKeywords) {
    ruleDoc += `keywords: "${seoKeywords.replace(/"/g, '\\"')}"\n`;
  }
  ruleDoc += `category: "${rule.category}"\n`;
  ruleDoc += `ruleId: "${rule.ruleId}"\n`;
  ruleDoc += `customEditUrl: "${ruleEditUrl}"\n`;
  ruleDoc += `---\n\n# ${meta.title}\n\n`;

  // Badge bar wrapper with inline margin
  ruleDoc += `<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">\n`;
  ruleDoc += `  <Badge type="${severityType}" text="${severityLabel}" />\n`;
  ruleDoc += `  <Badge type="tip" text="${categoryInfo.title}" />\n`;
  if (hasQuickfix) {
    ruleDoc += `  <Badge type="warning" text="QuickFix Ready" />\n`;
  }
  ruleDoc += `  <Badge type="danger" text="#EC ${rule.pseudoComment}" />\n`;
  ruleDoc += `  <Badge type="${remoteEnabled ? 'info' : 'warning'}" text="${remoteEnabled ? 'Remote Enabled' : 'Local Only'}" />\n`;
  ruleDoc += `  <a href="${ruleEditUrl}" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>\n`;
  ruleDoc += `</div>\n\n`;

  // Meaningful Description: Include check purpose & specific finding text
  ruleDoc += `## Overview\n\n`;
  ruleDoc += `${classDesc}.\n\n`;
  if (findingTexts.length > 0) {
    if (findingTexts.length === 1) {
      ruleDoc += `> **ATC Finding Message:** \`${findingTexts[0]}\`\n\n`;
    } else {
      ruleDoc += `> **ATC Finding Messages:**\n`;
      for (const t of findingTexts) {
        ruleDoc += `> - \`${t}\`\n`;
      }
      ruleDoc += `\n`;
    }
  }

  // Rationale & Best Practices
  ruleDoc += `## Rationale\n\n${meta.rationale}\n\n`;

  // Code Examples
  if (nonCompliantCode) {
    ruleDoc += `### Non-Compliant\n\n\`\`\`abap\n${nonCompliantCode}\n\`\`\`\n\n`;
  }

  if (compliantCode) {
    ruleDoc += `### Compliant\n\n\`\`\`abap\n${compliantCode}\n\`\`\`\n\n`;
  }

  // QuickFix section if available
  if (hasQuickfix) {
    ruleDoc += `## Automated QuickFix\n\n`;
    ruleDoc += `This rule provides an **automated QuickFix** directly in Eclipse ABAP Development Tools (ADT):\n`;
    ruleDoc += `1. Position the cursor on the flagged statement.\n`;
    ruleDoc += `2. Press <kbd>Ctrl</kbd> + <kbd>1</kbd> (Quick Assist).\n`;
    ruleDoc += `3. Select the automated refactoring to apply the clean syntax immediately.\n\n`;
  }

  // Configuration Table & Attributes
  if (attributes.length > 0) {
    const hasParamDesc = attributes.some(attr => (rule.parameters && rule.parameters[attr.name]));
    ruleDoc += `## Configuration & Thresholds\n\n`;
    ruleDoc += `This check can be fine-tuned directly in the ATC Check Variant Editor (\`CHKV\`) in Eclipse ADT:\n\n`;
    if (hasParamDesc) {
      ruleDoc += `| Parameter Name | Data Type | Default Value | Description & Guidance |\n`;
      ruleDoc += `|---|---|:---:|---|\n`;
      for (const attr of attributes) {
        const escapedDefault = attr.defaultValue.replace(/\|/g, '&#124;').replace(/</g, '&lt;').replace(/>/g, '&gt;');
        const pDesc = (rule.parameters && rule.parameters[attr.name]) ? rule.parameters[attr.name].replace(/\|/g, '&#124;') : '-';
        ruleDoc += `| \`${attr.name}\` | \`${attr.kind}\` | <code>${escapedDefault}</code> | ${pDesc} |\n`;
      }
    } else {
      ruleDoc += `| Parameter Name | Data Type | Default Value |\n`;
      ruleDoc += `|---|---|:---:|\n`;
      for (const attr of attributes) {
        const escapedDefault = attr.defaultValue.replace(/\|/g, '&#124;').replace(/</g, '&lt;').replace(/>/g, '&gt;');
        ruleDoc += `| \`${attr.name}\` | \`${attr.kind}\` | <code>${escapedDefault}</code> |\n`;
      }
    }
    ruleDoc += `\n`;
  }

  // Suppression
  ruleDoc += `## Suppression\n\n`;
  ruleDoc += `To suppress findings for this rule, append the pseudo-comment to the statement:\n\n`;
  ruleDoc += `\`\`\`abap\n" Standard pseudo-comment:\n... "#EC ${rule.pseudoComment}\n\n" SAP CI_ prefix format:\n... "#EC CI_${rule.pseudoComment}\n\`\`\`\n\n`;

  // Custom section if provided (e.g. reference tables)
  if (rule.customSection) {
    ruleDoc += `${rule.customSection.trim()}\n\n`;
  }


  // Related Rules from rules-data.mjs
  if (Array.isArray(rule.relatedRules) && rule.relatedRules.length > 0) {
    ruleDoc += `\n## Related Rules\n\n`;
    for (const relId of rule.relatedRules) {
      const rel = RULES.find(r => r.ruleId === relId);
      if (rel) {
        ruleDoc += `* [${rel.title}](/rules/${rel.ruleId}) — <code>#EC ${rel.pseudoComment}</code>\n`;
      }
    }
  }

  // ABAP Class Details
  ruleDoc += `\n## Technical Details\n\n`;
  ruleDoc += `* **Native ATC Class:** \`${rule.className}\`\n`;
  ruleDoc += `* **ABAP Implementation:** [${rule.className.toLowerCase()}.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/${encodeURIComponent(ruleFileBase(rule))}.clas.abap)\n`;
  ruleDoc += `* **Rule Metadata:** [rules-data.mjs (Line ${ruleLineNumber})](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L${ruleLineNumber})\n`;

  // Community Feedback Links
  const bugTitle = encodeURIComponent(`[Bug]: Issue in ${rule.ruleId}`);
  const bugUrl = `https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=${encodeURIComponent(rule.className)}&title=${bugTitle}`;
  const propTitle = encodeURIComponent(`[Proposal]: Enhance ${rule.ruleId}`);
  const propUrl = `https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=${propTitle}`;

  ruleDoc += `\n## Community & Feedback\n\n`;
  ruleDoc += `* 🐛 **[Report a False Positive or Bug for this rule](${bugUrl})**\n`;
  ruleDoc += `* 💡 **[Suggest a QuickFix or Rule Improvement](${propUrl})**\n`;

  fs.writeFileSync(path.join(rulesDocsDir, `${rule.ruleId}.md`), ruleDoc, 'utf8');

  // Collect for interactive Variant Builder
  const checkName = `/SKYL/${rule.className.replace(/^\/SKYL\/CL_/i, '')}`;
  catalogRules.push({
    ruleId: rule.ruleId,
    title: meta.title,
    className: rule.className,
    checkName: checkName,
    category: rule.category || 'General',
    categoryTitle: categoryInfo.title || rule.category,
    pseudoComment: rule.pseudoComment || '',
    description: classDesc,
    hasQuickfix: hasQuickfix,
    remoteEnabled: remoteEnabled,
    attributes: attributes,
    relatedRules: rule.relatedRules || [],
    defaultParameters: defaultParamsMap[checkName] || [],
  });
}

// Generate dedicated category landing pages for SEO (replaces fragment hashes)
for (const [catKey, catInfo] of Object.entries(CATEGORIES)) {
  const catTitle = catInfo.title;
  const catDesc = `${catInfo.description} Comprehensive reference, finding codes, and Clean ABAP examples for ${catInfo.title}.`;

  let catMd = `---\n`;
  catMd += `title: "${catTitle}"\n`;
  catMd += `description: "${catDesc}"\n`;
  catMd += `category: "${catKey}"\n`;
  catMd += `editLink: false\n`;
  catMd += `keywords: "Clean ABAP, ABAP Cloud, SAP ATC, ${catInfo.title}, S/4HANA Readiness, SAP BTP, Steampunk"\n`;
  catMd += `---\n\n`;

  catMd += `# ${catTitle}\n\n`;
  catMd += `${catInfo.description}\n\n`;
  catMd += `<script setup>\n`;
  catMd += `import RuleCatalog from '../components/RuleCatalog.vue';\n`;
  catMd += `</script>\n\n`;
  catMd += `<RuleCatalog category="${catKey}" />\n`;

  fs.writeFileSync(path.join(rulesDocsDir, `${catKey}.md`), catMd, 'utf8');
}

// Write catalog rules JSON for interactive Vue components
const componentsDir = path.join(docsDir, 'components');
fs.mkdirSync(componentsDir, { recursive: true });
fs.writeFileSync(path.join(componentsDir, 'rules-data.json'), JSON.stringify(catalogRules, null, 2), 'utf8');

const catalogData = {
  categories: Object.entries(CATEGORIES).map(([key, info]) => ({
    key,
    title: info.title,
    description: info.description,
    count: RULES.filter((r) => r.category === key).length,
  })),
  rules: catalogRules.map((r) => ({
    ruleId: r.ruleId,
    title: r.title,
    className: r.className,
    description: r.description,
    category: r.category,
    categoryTitle: r.categoryTitle,
    pseudoComment: r.pseudoComment,
    hasQuickfix: r.hasQuickfix,
    remoteEnabled: r.remoteEnabled,
    configurable: Array.isArray(r.attributes) && r.attributes.length > 0,
  })),
};
fs.writeFileSync(path.join(componentsDir, 'catalog-data.json'), JSON.stringify(catalogData, null, 2), 'utf8');

// Generate rules/index.md with At a Glance statistics card
let catalogMd = `---\ndescription: "Comprehensive reference and catalog for Clean ABAP, security, performance, and architecture rules in Skylint."\neditLink: false\n---\n\n# Rules Catalog\n\n`;
catalogMd += `Comprehensive reference for Clean ABAP, security, performance, and architecture rules in Skylint.\n\n`;

catalogMd += `::: tip Skylint at a Glance\n`;
catalogMd += `- **Native ATC Rules:** 100% ABAP Cloud (Contract C1) & Steampunk Ready.\n`;
catalogMd += `- **Automated QuickFixes:** Instant one-click refactoring with <kbd>Ctrl</kbd> + <kbd>1</kbd> in Eclipse ADT.\n`;
catalogMd += `- **Zero Legacy Overhead:** Built exclusively on \`IF_CI_ATC_CHECK\` (no obsolete Code Inspector / SCI dependency).\n`;
catalogMd += `:::\n\n`;

catalogMd += `<script setup>\nimport RuleCatalog from '../components/RuleCatalog.vue';\n</script>\n\n<RuleCatalog />\n`;

fs.writeFileSync(path.join(rulesDocsDir, 'index.md'), catalogMd, 'utf8');

// Generate Dynamic Open Graph Image (docs/public/og-image.svg & og-image.png)
function generateOgImage() {
  const publicDir = path.join(docsDir, 'public');
  fs.mkdirSync(publicDir, { recursive: true });
  const ogSvgPath = path.join(publicDir, 'og-image.svg');
  if (fs.existsSync(ogSvgPath) && process.env.FORCE_OG_IMAGE !== '1') return;

  const logoPath = path.join(publicDir, 'logo.svg');
  if (!fs.existsSync(logoPath)) return;

  const ogRuleCount = '100+';
  const logoSvg = fs.readFileSync(logoPath, 'utf8');
  const defsMatch = logoSvg.match(/<defs>([\s\S]*?)<\/defs>/);
  const innerMatch = logoSvg.match(/<circle[\s\S]*?<\/g>/);
  if (!defsMatch || !innerMatch) return;

  const ogSvg = `<svg width="1200" height="630" viewBox="0 0 1200 630" xmlns="http://www.w3.org/2000/svg">
  <defs>
    ${defsMatch[1]}
    <linearGradient id="bgGrad" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" stop-color="#0a0e17" />
      <stop offset="50%" stop-color="#0f172a" />
      <stop offset="100%" stop-color="#030712" />
    </linearGradient>
    <radialGradient id="cardGlow" cx="20%" cy="30%" r="60%">
      <stop offset="0%" stop-color="#0284c7" stop-opacity="0.25" />
      <stop offset="100%" stop-color="#0284c7" stop-opacity="0" />
    </radialGradient>
  </defs>

  <rect width="1200" height="630" fill="url(#bgGrad)" />
  <rect width="1200" height="630" fill="url(#cardGlow)" />
  <rect x="1" y="1" width="1198" height="628" rx="8" fill="none" stroke="#1e293b" stroke-width="2" />

  <g transform="translate(100, 155) scale(0.32)">
    ${innerMatch[0]}
  </g>

  <g transform="translate(480, 210)">
    <text font-family="-apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif" font-size="76" font-weight="800" fill="#ffffff" letter-spacing="-1">Skylint</text>
    <text y="68" font-family="-apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif" font-size="28" font-weight="500" fill="#38bdf8">Enterprise Clean ABAP &amp; Cloud ATC Linter Engine</text>
    <text y="125" font-family="-apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif" font-size="21" font-weight="400" fill="#94a3b8">Native SAP ATC Integration · Clean ABAP Rules · Automated ADT QuickFixes</text>

    <g transform="translate(0, 185)">
      <rect x="0" y="0" width="185" height="42" rx="21" fill="#0369a1" fill-opacity="0.25" stroke="#0284c7" stroke-width="1.5" />
      <text x="92" y="26" font-family="-apple-system, BlinkMacSystemFont, sans-serif" font-size="16" font-weight="600" fill="#38bdf8" text-anchor="middle">⚡ 100% Native ATC</text>

      <rect x="200" y="0" width="190" height="42" rx="21" fill="#047857" fill-opacity="0.25" stroke="#059669" stroke-width="1.5" />
      <text x="295" y="26" font-family="-apple-system, BlinkMacSystemFont, sans-serif" font-size="16" font-weight="600" fill="#34d399" text-anchor="middle">🌿 Clean ABAP Rules</text>

      <rect x="405" y="0" width="200" height="42" rx="21" fill="#7c3aed" fill-opacity="0.25" stroke="#8b5cf6" stroke-width="1.5" />
      <text x="505" y="26" font-family="-apple-system, BlinkMacSystemFont, sans-serif" font-size="16" font-weight="600" fill="#a78bfa" text-anchor="middle">Instant QuickFixes</text>
    </g>
  </g>

  <g transform="translate(100, 560)">
    <text font-family="-apple-system, BlinkMacSystemFont, sans-serif" font-size="17" font-weight="500" fill="#64748b">https://skylint.org</text>
    <text x="1000" font-family="-apple-system, BlinkMacSystemFont, sans-serif" font-size="17" font-weight="500" fill="#64748b" text-anchor="end">Contract C1 · Steampunk Ready</text>
  </g>
</svg>`;

  const ogPngPath = path.join(publicDir, 'og-image.png');
  fs.writeFileSync(ogSvgPath, ogSvg, 'utf8');

  try {
    execSync(`which sips && sips -s format png "${ogSvgPath}" --out "${ogPngPath}"`, { stdio: 'ignore' });
  } catch {
    // Graceful fallback on environments where sips is unavailable (e.g. Linux CI)
  }
}

generateOgImage();

console.log('✓ All enterprise documentation and VitePress configuration generated successfully.');
