import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { RULES, CATEGORIES } from './rules-data.mjs';


const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const rootDir = path.resolve(__dirname, '..');
const docsDir = path.join(rootDir, 'docs');
const rulesDocsDir = path.join(docsDir, 'rules');
const guideDocsDir = path.join(docsDir, 'guide');
const fixturesDir = path.join(rootDir, 'test', 'fixtures');
const checksDir = path.join(rootDir, 'src', 'checks');

// Ensure directories exist
fs.mkdirSync(rulesDocsDir, { recursive: true });
fs.mkdirSync(guideDocsDir, { recursive: true });
fs.mkdirSync(path.join(docsDir, '.vitepress'), { recursive: true });

// Clean up stale rule doc files
const validRuleFiles = new Set(RULES.map(r => `${r.ruleId}.md`));
validRuleFiles.add('index.md');
for (const file of fs.readdirSync(rulesDocsDir)) {
  if (file.endsWith('.md') && !validRuleFiles.has(file)) {
    fs.unlinkSync(path.join(rulesDocsDir, file));
  }
}

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

function extractAttributes(content) {
  const attrBlockMatch = content.match(/attributes\s*=\s*VALUE\s*#\(([\s\S]*?)\)\s*\)\s*\./);
  if (!attrBlockMatch) return [];
  const block = attrBlockMatch[1];
  const defaultKindMatch = block.match(/kind\s*=\s*if_ci_atc_check_meta_data=>attribute_kinds-([a-z]+)/);
  const defaultKind = defaultKindMatch ? defaultKindMatch[1] : 'elementary';

  const results = [];
  const entries = [...block.matchAll(/\(\s*name\s*=\s*'([A-Za-z0-9_]+)'[\s\S]*?value\s*=\s*REF\s*#\(\s*([a-zA-Z0-9_]+)\s*\)/g)];
  for (const e of entries) {
    const name = e[1];
    const varName = e[2];
    const kindMatch = e[0].match(/kind\s*=\s*if_ci_atc_check_meta_data=>attribute_kinds-([a-z]+)/);
    const kind = kindMatch ? kindMatch[1] : defaultKind;
    const valRegex = new RegExp(`DATA\\s+${varName}\\s+TYPE\\s+\\S+\\s+VALUE\\s+('.*?'|[^.\\n\\r]+)\\.`, 'i');
    const valM = content.match(valRegex);
    let defVal = valM ? valM[1].trim() : '';
    if (defVal.toLowerCase() === 'abap_true') defVal = 'true';
    if (defVal.toLowerCase() === 'abap_false') defVal = 'false';

    results.push({
      name,
      kind: kind === 'boolean' ? 'Boolean' : 'Integer / String',
      defaultValue: defVal,
    });
  }
  return results;
}

function buildDiffSnippet(bad, good) {
  if (!bad || !good) return '';
  const badLines = bad.split('\n').map((l) => `- ${l}`);
  const goodLines = good.split('\n').map((l) => `+ ${l}`);
  return [...badLines, ...goodLines].join('\n');
}

console.log(`Generating rich enterprise documentation for ${RULES.length} rules...`);

let totalQuickFixes = 0;

for (const rule of RULES) {
  const checkFile = path.join(checksDir, `${rule.className.toLowerCase()}.clas.abap`);
  let classDesc = rule.ruleId;
  let findingCode = 'UNKNOWN';
  let findingCodes = [];
  let severity = 'warning';
  let hasQuickfix = false;
  let attributes = [];
  let findingTexts = [];

  if (fs.existsSync(checkFile)) {
    const content = fs.readFileSync(checkFile, 'utf8');
    const descMatch = content.match(/description\s*=\s*'([^']+)'/);
    if (descMatch) classDesc = descMatch[1].replace(/^skylint:\s*/i, '').trim();

    const codeBlockMatch = content.match(/BEGIN OF c_finding_codes,([\s\S]*?)END OF c_finding_codes\./);
    const codeMatches = codeBlockMatch ? [...codeBlockMatch[1].matchAll(/VALUE\s*'([A-Za-z0-9_]+)'/g)] : [];
    findingCodes = codeMatches.map((m) => m[1]);
    if (findingCodes.length > 0) findingCode = findingCodes[0];

    const sevMatch = content.match(/severity\s*=\s*if_ci_atc_check=>finding_severities-([a-z]+)/);
    if (sevMatch) severity = sevMatch[1];

    hasQuickfix = /quickfix_codes|quickfix_replace|quickfix_delete/i.test(content);
    if (hasQuickfix) totalQuickFixes++;

    attributes = extractAttributes(content);

    const fMatches = [...content.matchAll(/text\s*=\s*(?:'([^']+)'|\|([^|]+)\|)/g)].map((x) => (x[1] || x[2]).trim());
    if (fMatches.length > 0) {
      findingTexts = fMatches;
    }
  }

  const meta = {
    title: rule.title || rule.ruleId,
    rationale: rule.rationale || classDesc,
  };

  // Prioritize canonical Clean ABAP example from RULES, fallback to fixture
  let nonCompliantCode = rule.example?.bad || '';
  let compliantCode = rule.example?.good || '';

  if (!nonCompliantCode || !compliantCode) {
    const fixtureDir = path.join(fixturesDir, rule.ruleId);
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

  // Rule Page Title
  let ruleDoc = `# ${meta.title}\n\n`;

  // Badge bar wrapper with inline margin
  ruleDoc += `<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">\n`;
  ruleDoc += `  <Badge type="tip" text="${categoryInfo.title}" />\n`;
  if (hasQuickfix) {
    ruleDoc += `  <Badge type="warning" text="⚡ QuickFix Ready" />\n`;
  }
  const findingBadge = findingCodes.length > 1 ? `Finding: ${findingCode} (+${findingCodes.length - 1})` : `Finding: ${findingCode}`;
  ruleDoc += `  <Badge type="danger" text="${findingBadge}" />\n`;
  ruleDoc += `</div>\n\n`;

  // Meaningful Description: Include check purpose & specific finding text
  ruleDoc += `## Overview\n\n`;
  ruleDoc += `${classDesc}.\n\n`;
  if (findingTexts.length > 0 && findingTexts[0] !== classDesc) {
    ruleDoc += `> **ATC Finding Message:** \`${findingTexts[0]}\`\n\n`;
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

  // Quick Visual Transformation Diff
  const diffSnippet = buildDiffSnippet(nonCompliantCode, compliantCode);
  if (diffSnippet) {
    ruleDoc += `## Transformation\n\n`;
    ruleDoc += `\`\`\`diff\n${diffSnippet}\n\`\`\`\n\n`;
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
    ruleDoc += `## Configuration & Thresholds\n\n`;
    ruleDoc += `This check can be fine-tuned directly in the ATC Check Variant Editor (\`CHKV\`) in Eclipse ADT:\n\n`;
    ruleDoc += `| Parameter Name | Data Type | Default Value |\n`;
    ruleDoc += `|---|---|:---:|\n`;
    for (const attr of attributes) {
      const escapedDefault = attr.defaultValue.replace(/\|/g, '&#124;');
      ruleDoc += `| \`${attr.name}\` | \`${attr.kind}\` | <code>${escapedDefault}</code> |\n`;
    }
    ruleDoc += `\n`;
  }

  // CLI Configuration
  ruleDoc += `## CLI & CI/CD Configuration\n\n`;
  ruleDoc += `\`\`\`yaml\nchecks:\n  ${rule.ruleId}:\n    enabled: true\n    severity: ${severity}\n`;
  if (attributes.length > 0) {
    ruleDoc += `    attributes:\n`;
    for (const attr of attributes) {
      const camelName = attr.name.toLowerCase().replace(/_([a-z0-9])/g, (_, l) => l.toUpperCase());
      ruleDoc += `      ${camelName}: ${attr.defaultValue}\n`;
    }
  }
  ruleDoc += `\`\`\`\n\n`;

  // Suppression
  ruleDoc += `## Suppression\n\n`;
  ruleDoc += `To suppress findings for this rule, append the pseudo-comment to the statement:\n\n`;
  ruleDoc += `\`\`\`abap\n" Standard pseudo-comment:\n... "#EC ${rule.pseudoComment}\n\n" SAP CI_ prefix format:\n... "#EC CI_${rule.pseudoComment}\n\`\`\`\n\n`;

  // ABAP Class Details
  ruleDoc += `## Technical Details\n\n`;
  ruleDoc += `* **Native ATC Class:** \`${rule.className}\`\n`;
  ruleDoc += `### Finding Codes\n\n`;
  ruleDoc += `| Finding Code | ATC Finding Message |\n`;
  ruleDoc += `|---|---|\n`;
  for (let i = 0; i < findingCodes.length; i++) {
    const msg = findingTexts[i] || '';
    const escapedMsg = msg.replace(/\|/g, '&#124;');
    ruleDoc += `| \`${findingCodes[i]}\` | ${escapedMsg} |\n`;
  }
  ruleDoc += `\n`;
  ruleDoc += `* **Implementation File:** [${rule.className.toLowerCase()}.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/${rule.className.toLowerCase()}.clas.abap)\n`;

  fs.writeFileSync(path.join(rulesDocsDir, `${rule.ruleId}.md`), ruleDoc, 'utf8');
}

// Generate rules/index.md with At a Glance statistics card
let catalogMd = `# Rules Catalog (${RULES.length} Rules)\n\n`;
catalogMd += `Comprehensive reference for all **${RULES.length}** Clean ABAP, security, performance, and architecture rules in Skylint.\n\n`;

catalogMd += `::: tip Skylint at a Glance\n`;
catalogMd += `- **${RULES.length} Native ATC Rules:** 100% ABAP Cloud (Contract C1) & Steampunk Ready.\n`;
catalogMd += `- **${totalQuickFixes} Automated QuickFixes:** Instant one-click refactoring with <kbd>Ctrl</kbd> + <kbd>1</kbd> in Eclipse ADT.\n`;
catalogMd += `- **Zero Legacy Overhead:** Built exclusively on \`IF_CI_ATC_CHECK\` (no obsolete Code Inspector / SCI dependency).\n`;
catalogMd += `:::\n\n`;

for (const [catKey, catInfo] of Object.entries(CATEGORIES)) {
  const catRules = RULES.filter((r) => r.category === catKey);
  catalogMd += `## ${catInfo.title} (${catRules.length})\n\n`;
  catalogMd += `${catInfo.description}\n\n`;
  catalogMd += `| Rule ID | ABAP Class | Description | Finding Code | Pseudo-Comment | QuickFix |\n`;
  catalogMd += `|---|---|---|:---:|:---:|:---:|\n`;

  for (const r of catRules) {
    const checkFile = path.join(checksDir, `${r.className.toLowerCase()}.clas.abap`);
    let desc = r.ruleId;
    let code = '';
    let qf = '—';

    if (fs.existsSync(checkFile)) {
      const c = fs.readFileSync(checkFile, 'utf8');
      const dm = c.match(/description\s*=\s*'([^']+)'/);
      if (dm) desc = dm[1].replace(/^skylint:\s*/i, '');
      const cm = c.match(/c_finding_codes[\s\S]*?VALUE\s*'([A-Za-z0-9_]+)'/);
      if (cm) code = cm[1];
      if (/quickfix_codes|quickfix_replace/i.test(c)) qf = '⚡ Ready';
    }

    catalogMd += `| [\`${r.ruleId}\`](/rules/${r.ruleId}) | \`${r.className}\` | ${desc} | \`${code}\` | \`#EC ${r.pseudoComment}\` | ${qf} |\n`;
  }
  catalogMd += `\n`;
}

fs.writeFileSync(path.join(rulesDocsDir, 'index.md'), catalogMd, 'utf8');

// Generate VitePress Sidebar config
const sidebarRules = Object.entries(CATEGORIES).map(([catKey, catInfo]) => ({
  text: catInfo.title,
  collapsed: false,
  items: RULES.filter((r) => r.category === catKey).map((r) => ({
    text: r.ruleId,
    link: `/rules/${r.ruleId}`,
  })),
}));

const vpConfig = `import { defineConfig } from 'vitepress';

export default defineConfig({
  title: 'Skylint',
  description: 'Enterprise Clean ABAP & Cloud ATC Linter Engine',
  base: process.env.VITEPRESS_BASE || '/',
  cleanUrls: true,
  lastUpdated: true,
  sitemap: {
    hostname: 'https://furkancosgun.github.io/skylint/',
  },
  head: [
    ['link', { rel: 'icon', type: 'image/svg+xml', href: '${process.env.VITEPRESS_BASE || '/'}logo.svg' }],
    ['meta', { name: 'robots', content: 'index, follow' }],
    ['meta', { property: 'og:type', content: 'website' }],
    ['meta', { property: 'og:title', content: 'Skylint - Enterprise Clean ABAP & Cloud ATC Linter' }],
    ['meta', { property: 'og:description', content: 'Enterprise Clean ABAP & Cloud ATC Linter Engine' }],
    ['meta', { property: 'og:image', content: 'https://furkancosgun.github.io/skylint/logo.svg' }],
  ],
  transformHead: ({ pageData }) => {
    const rel = pageData.relativePath.replace(/\\.md$/, '').replace(/(^|\\/)index$/, '$1');
    const path = rel === '' ? '/' : '/' + rel;
    return [['link', { rel: 'canonical', href: 'https://furkancosgun.github.io/skylint' + path }]];
  },
  themeConfig: {
    logo: '/logo.svg',
    nav: [
      { text: 'Guide', link: '/guide/getting-started' },
      { text: 'Rules (${RULES.length})', link: '/rules/' },
      { text: 'GitHub', link: 'https://github.com/furkancosgun/skylint' },
    ],
    sidebar: {
      '/guide/': [
        {
          text: 'Architecture & Guides',
          items: [
            { text: 'Getting Started', link: '/guide/getting-started' },
            { text: 'Configuration (skylint.yaml)', link: '/guide/configuration' },
            { text: 'SAP ATC Integration', link: '/guide/atc-integration' },
            { text: 'Suppressions & Pragmas', link: '/guide/suppressions' },
          ],
        },
      ],
      '/rules/': [
        { text: 'All Rules Overview', link: '/rules/' },
        ...${JSON.stringify(sidebarRules, null, 2)}
      ],
    },
    search: {
      provider: 'local',
    },
    socialLinks: [
      { icon: 'github', link: 'https://github.com/furkancosgun/skylint' },
    ],
    footer: {
      message: 'Released under the MIT License.',
      copyright: 'Copyright © 2026 Skylint Contributors',
    },
  },
});
`;

fs.writeFileSync(path.join(docsDir, '.vitepress', 'config.mts'), vpConfig, 'utf8');

// Generate Landing Page (docs/index.md)
const indexMd = `---
layout: home

hero:
  name: "Skylint"
  text: "Enterprise Clean ABAP Linter"
  tagline: "${RULES.length} Native ATC Rules for Clean ABAP & Cloud-Ready Systems. 100% ABAP Cloud, zero legacy baggage, instant QuickFixes."
  image:
    src: /logo.svg
    alt: Skylint Cloud Logo
  actions:
    - theme: brand
      text: Get Started
      link: /guide/getting-started
    - theme: alt
      text: Explore ${RULES.length} Rules
      link: /rules/

features:
  - icon: ⚡
    title: Native SAP ATC Integration
    details: Zero adapter layers. Runs directly inside SAP GUI and Eclipse ADT via if_ci_atc_check with abapGit transport.
  - icon: 🌿
    title: ${RULES.length} Clean ABAP Rules
    details: Enforcing modern syntax, expression-based ABAP, safety boundaries, and object-oriented cleanliness.
  - icon: 🛠️
    title: Automated QuickFixes
    details: Built-in automated refactoring for modern syntax upgrades (lines, string templates, NEW #, etc.) with Ctrl + 1.
  - icon: 🚀
    title: High-Performance CLI & CI/CD
    details: Fast local scanning, Git pre-commit hooks, and CI/CD SARIF reports powered by transpile engine.
---
`;

fs.writeFileSync(path.join(docsDir, 'index.md'), indexMd, 'utf8');

console.log('✓ All enterprise documentation and VitePress configuration generated successfully.');
