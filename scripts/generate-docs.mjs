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

  // De-indent snippet
  if (buffer.length === 0) return '';
  const minIndent = buffer.reduce((min, l) => {
    if (l.trim() === '') return min;
    const match = l.match(/^(\s*)/);
    return Math.min(min, match ? match[1].length : 0);
  }, 999);

  return buffer.map((l) => (l.length >= minIndent ? l.slice(minIndent) : l)).join('\n').trim();
}

console.log(`Generating documentation for ${RULES.length} rules...`);

for (const rule of RULES) {
  const checkFile = path.join(checksDir, `${rule.className.toLowerCase()}.clas.abap`);
  let description = rule.ruleId;
  let findingCode = 'UNKNOWN';
  let severity = 'warning';
  let hasQuickfix = false;

  if (fs.existsSync(checkFile)) {
    const content = fs.readFileSync(checkFile, 'utf8');
    const descMatch = content.match(/description\s*=\s*'([^']+)'/);
    if (descMatch) description = descMatch[1].replace(/^skylint:\s*/i, '');

    const codeMatch = content.match(/c_finding_codes[\s\S]*?VALUE\s*'([A-Za-z0-9_]+)'/);
    if (codeMatch) findingCode = codeMatch[1];

    hasQuickfix = /quickfix_codes|quickfix_replace|quickfix_delete/i.test(content);
  }

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

  let ruleDoc = `# \`${rule.ruleId}\`\n\n`;
  ruleDoc += `> **Category:** [${categoryInfo.title}](/rules/#${rule.category}) &nbsp;|&nbsp; `;
  ruleDoc += `**Severity:** \`${severity}\` &nbsp;|&nbsp; `;
  ruleDoc += `**Finding Code:** \`${findingCode}\` &nbsp;|&nbsp; `;
  ruleDoc += `**QuickFix:** ${hasQuickfix ? '⚡ Yes' : 'No'}\n\n`;

  ruleDoc += `## Description\n\n${description}.\n\n`;

  if (nonCompliantCode) {
    ruleDoc += `## ❌ Non-Compliant Code\n\n\`\`\`abap\n${nonCompliantCode}\n\`\`\`\n\n`;
  }

  if (compliantCode) {
    ruleDoc += `## ✅ Compliant Code\n\n\`\`\`abap\n${compliantCode}\n\`\`\`\n\n`;
  }

  ruleDoc += `## 🤫 Suppression & Pseudo-Comments\n\n`;
  ruleDoc += `To suppress findings for this rule, append the pseudo-comment or pragma to the statement:\n\n`;
  ruleDoc += `\`\`\`abap\n" Using pseudo-comment:\n... "#EC ${rule.pseudoComment}\n" Or with SAP CI_ prefix:\n... "#EC CI_${rule.pseudoComment}\n\n" Using pragma:\n... ##${rule.pseudoComment}.\n" Or with SAP CI_ prefix:\n... ##CI_${rule.pseudoComment}.\n\`\`\`\n\n`;

  ruleDoc += `## Configuration (\`skylint.yaml\`)\n\n`;
  ruleDoc += `\`\`\`yaml\nchecks:\n  ${rule.ruleId}:\n    enabled: true\n    severity: ${severity}\n\`\`\`\n\n`;

  ruleDoc += `## ABAP Class Details\n\n`;
  ruleDoc += `* **Native ATC Class:** \`${rule.className}\`\n`;
  ruleDoc += `* **Implementation File:** [${rule.className.toLowerCase()}.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/${rule.className.toLowerCase()}.clas.abap)\n`;

  fs.writeFileSync(path.join(rulesDocsDir, `${rule.ruleId}.md`), ruleDoc, 'utf8');
}

// Generate rules/index.md
let catalogMd = `# 📋 Skylint Rules Catalog (${RULES.length} Rules)\n\n`;
catalogMd += `Comprehensive reference for all ${RULES.length} Clean ABAP, security, performance, and architecture rules in Skylint.\n\n`;

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
  themeConfig: {
    logo: '/logo.svg',
    nav: [
      { text: 'Guide', link: '/guide/getting-started' },
      { text: 'Rules', link: '/rules/' },
      { text: 'GitHub', link: 'https://github.com/furkancosgun/skylint' },
    ],
    sidebar: {
      '/guide/': [
        {
          text: 'Introduction',
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
  tagline: "${RULES.length} Native ATC Rules for Clean ABAP & Cloud-Ready Systems. Blazing fast CLI & SAP-native integration."
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
    details: Zero adapter layers. Runs directly inside SAP GUI and ADT via if_ci_atc_check with abapGit transport.
  - icon: 🌿
    title: ${RULES.length} Clean ABAP Rules
    details: Enforcing modern syntax, expression-based ABAP, safety boundaries, and object-oriented cleanliness.
  - icon: 🛠️
    title: Automated QuickFixes
    details: Built-in automated refactoring for modern syntax upgrades (lines, string templates, NEW #, etc.).
  - icon: 🚀
    title: High-Performance CLI
    details: Fast local scanning, Git pre-commit hooks, and CI/CD SARIF reports powered by transpile engine.
---
`;

fs.writeFileSync(path.join(docsDir, 'index.md'), indexMd, 'utf8');

console.log('✓ All documentation and VitePress configuration generated successfully.');
