import fs from 'node:fs';
import path from 'node:path';
import { execSync } from 'node:child_process';
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

    let resolvedKind = 'String';
    if (kind === 'boolean') {
      resolvedKind = 'Boolean';
    } else if (/^\d+$/.test(defVal)) {
      resolvedKind = 'Integer';
    }

    results.push({
      name,
      kind: resolvedKind,
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

// Load default parameters from src/atc/zskylint_default.chkv.json
const chkvPath = path.join(rootDir, 'src', 'atc', 'zskylint_default.chkv.json');
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

    const fMatches = [...content.matchAll(/(?<![_a-zA-Z])text\s*=\s*(?:'([^']+)'|\|([^|]+)\|)/g)].map((x) => (x[1] || x[2]).trim());
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

  // Rule Page Title with SEO frontmatter
  const cleanDesc = (classDesc || '').replace(/"/g, '\\"');
  let ruleDoc = `---\ndescription: "${cleanDesc}"\n---\n\n# ${meta.title}\n\n`;

  // Badge bar wrapper with inline margin
  ruleDoc += `<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">\n`;
  ruleDoc += `  <Badge type="tip" text="${categoryInfo.title}" />\n`;
  if (hasQuickfix) {
    ruleDoc += `  <Badge type="warning" text="⚡ QuickFix Ready" />\n`;
  }
  ruleDoc += `  <Badge type="danger" text="#EC ${rule.pseudoComment}" />\n`;
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

  ruleDoc += `* **Implementation File:** [${rule.className.toLowerCase()}.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/${rule.className.toLowerCase()}.clas.abap)\n`;

  fs.writeFileSync(path.join(rulesDocsDir, `${rule.ruleId}.md`), ruleDoc, 'utf8');

  // Collect for interactive Variant Builder & Playground
  const checkName = rule.className.replace(/^ZCL_/, 'Z');
  catalogRules.push({
    ruleId: rule.ruleId,
    title: meta.title,
    className: rule.className,
    checkName: checkName,
    category: rule.category || 'General',
    categoryTitle: categoryInfo.title || rule.category,
    pseudoComment: rule.pseudoComment || '',
    severity: severity,
    findingCode: findingCode,
    findingTexts: findingTexts.length > 0 ? findingTexts : [classDesc],
    description: classDesc,
    rationale: meta.rationale,
    hasQuickfix: hasQuickfix,
    attributes: attributes,
    defaultParameters: defaultParamsMap[checkName] || [],
    nonCompliantCode: nonCompliantCode || '',
    compliantCode: compliantCode || '',
  });
}

// Write catalog rules JSON for interactive Vue components
const componentsDir = path.join(docsDir, 'components');
fs.mkdirSync(componentsDir, { recursive: true });
fs.writeFileSync(path.join(componentsDir, 'rules-data.json'), JSON.stringify(catalogRules, null, 2), 'utf8');

// Generate docs/variant-builder.md
const variantBuilderMd = `---
layout: page
title: ATC Variant Builder & Live Playground
description: Configure custom SAP ATC check variants, tune rule parameters, download .chkv.json files for SAP GUI / abapGit, and test Clean ABAP rules live.
---

<script setup>
import VariantBuilder from './components/VariantBuilder.vue';
</script>

<VariantBuilder />
`;
fs.writeFileSync(path.join(docsDir, 'variant-builder.md'), variantBuilderMd, 'utf8');

// Generate rules/index.md with At a Glance statistics card
let catalogMd = `---\ndescription: "Comprehensive reference and catalog for all ${RULES.length} Clean ABAP, security, performance, and architecture rules in Skylint."\n---\n\n# Rules Catalog (${RULES.length} Rules)\n\n`;
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
  catalogMd += `| Rule ID | ABAP Class | Description | Pseudo-Comment | QuickFix |\n`;
  catalogMd += `|---|---|---|:---:|:---:|\n`;

  for (const r of catRules) {
    const checkFile = path.join(checksDir, `${r.className.toLowerCase()}.clas.abap`);
    let desc = r.ruleId;
    let qf = '—';

    if (fs.existsSync(checkFile)) {
      const c = fs.readFileSync(checkFile, 'utf8');
      const dm = c.match(/description\s*=\s*'([^']+)'/);
      if (dm) desc = dm[1].replace(/^skylint:\s*/i, '');
      if (/quickfix_codes|quickfix_replace/i.test(c)) qf = '⚡ Ready';
    }

    catalogMd += `| [\`${r.ruleId}\`](/rules/${r.ruleId}) | \`${r.className}\` | ${desc} | \`#EC ${r.pseudoComment}\` | ${qf} |\n`;
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

const base = process.env.VITEPRESS_BASE || '/';

export default defineConfig({
  title: 'Skylint',
  description: 'Enterprise Clean ABAP & Cloud ATC Linter Engine',
  base,
  cleanUrls: true,
  lastUpdated: true,
  sitemap: {
    hostname: 'https://furkancosgun.github.io/skylint/',
  },
  vite: {
    build: {
      target: 'esnext',
    },
    esbuild: {
      target: 'esnext',
    },
  },
  head: [
    ['link', { rel: 'icon', type: 'image/svg+xml', href: \`\${base}logo.svg\` }],
    ['meta', { name: 'robots', content: 'index, follow' }],
    ['meta', { name: 'google-site-verification', content: 'googlebe62f3b9b7abdd43' }],
    ['meta', { property: 'og:type', content: 'website' }],
    ['meta', { property: 'og:image', content: 'https://furkancosgun.github.io/skylint/og-image.png' }],
    ['meta', { property: 'og:image:width', content: '1200' }],
    ['meta', { property: 'og:image:height', content: '630' }],
    ['meta', { property: 'og:image:type', content: 'image/png' }],
    ['meta', { name: 'twitter:card', content: 'summary_large_image' }],
    ['meta', { name: 'twitter:image', content: 'https://furkancosgun.github.io/skylint/og-image.png' }],
  ],
  transformHead: ({ pageData, title, description }) => {
    if (pageData.isNotFound) {
      return [
        ['meta', { name: 'robots', content: 'noindex, nofollow' }],
      ];
    }

    const canonicalHostname = 'https://furkancosgun.github.io/skylint';
    const cleanPath = pageData.relativePath
      .replace(/\\.md$/, '')
      .replace(/(^|\\/)index$/, '$1');
    const url = (canonicalHostname + '/' + cleanPath).replace(/\\/+$/, '') + (cleanPath === '' || cleanPath.endsWith('/') ? '/' : '');

    const ogTitle = title === 'Skylint' ? 'Skylint - Enterprise Clean ABAP & Cloud ATC Linter' : (title || 'Skylint');
    const ogDescription = pageData.frontmatter?.description || description || 'Enterprise Clean ABAP & Cloud ATC Linter Engine';

    const tags = [
      ['link', { rel: 'canonical', href: url }],
      ['meta', { property: 'og:url', content: url }],
      ['meta', { property: 'og:title', content: ogTitle }],
      ['meta', { property: 'og:description', content: ogDescription }],
      ['meta', { name: 'description', content: ogDescription }],
      ['meta', { name: 'twitter:title', content: ogTitle }],
      ['meta', { name: 'twitter:description', content: ogDescription }],
    ];

    if (cleanPath === '') {
      tags.push([
        'script',
        { type: 'application/ld+json' },
        JSON.stringify({
          '@context': 'https://schema.org',
          '@type': 'SoftwareApplication',
          'name': 'Skylint',
          'applicationCategory': 'DeveloperApplication',
          'operatingSystem': 'SAP ABAP Cloud, Node.js',
          'description': 'Enterprise Clean ABAP & Cloud ATC Linter Engine with ${RULES.length}+ Native Rules',
          'url': 'https://furkancosgun.github.io/skylint/',
          'license': 'https://github.com/furkancosgun/skylint/blob/main/LICENSE',
          'image': 'https://furkancosgun.github.io/skylint/og-image.png',
          'offers': {
            '@type': 'Offer',
            'price': '0',
            'priceCurrency': 'USD',
          },
          'author': {
            '@type': 'Person',
            'name': 'Furkan COSGUN',
            'url': 'https://github.com/furkancosgun',
          },
        }),
      ]);
    }

    return tags;
  },
  themeConfig: {
    logo: '/logo.svg',
    nav: [
      { text: 'Guide', link: '/guide/getting-started' },
      { text: 'Rules (${RULES.length})', link: '/rules/' },
      { text: 'Variant Builder', link: '/variant-builder' },
      { text: 'GitHub', link: 'https://github.com/furkancosgun/skylint' },
    ],
    sidebar: {
      '/variant-builder': [],
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
    - theme: alt
      text: 🎛️ Variant Builder
      link: /variant-builder

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
  - icon: 🎛️
    title: ATC Variant Builder & Sandbox
    details: Build custom SAP ATC check variants (.chkv.json), tune parameters, and test Clean ABAP rules live in your browser.
---
`;

fs.writeFileSync(path.join(docsDir, 'index.md'), indexMd, 'utf8');

// Generate Dynamic Open Graph Image (docs/public/og-image.svg & og-image.png)
function generateOgImage() {
  const publicDir = path.join(docsDir, 'public');
  fs.mkdirSync(publicDir, { recursive: true });
  const logoPath = path.join(publicDir, 'logo.svg');
  if (!fs.existsSync(logoPath)) return;

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
    <text y="125" font-family="-apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif" font-size="21" font-weight="400" fill="#94a3b8">Native SAP ATC Integration · ${RULES.length} Clean Rules · Automated ADT QuickFixes</text>

    <g transform="translate(0, 185)">
      <rect x="0" y="0" width="185" height="42" rx="21" fill="#0369a1" fill-opacity="0.25" stroke="#0284c7" stroke-width="1.5" />
      <text x="92" y="26" font-family="-apple-system, BlinkMacSystemFont, sans-serif" font-size="16" font-weight="600" fill="#38bdf8" text-anchor="middle">⚡ 100% Native ATC</text>

      <rect x="200" y="0" width="190" height="42" rx="21" fill="#047857" fill-opacity="0.25" stroke="#059669" stroke-width="1.5" />
      <text x="295" y="26" font-family="-apple-system, BlinkMacSystemFont, sans-serif" font-size="16" font-weight="600" fill="#34d399" text-anchor="middle">🌿 ${RULES.length} Clean Rules</text>

      <rect x="405" y="0" width="200" height="42" rx="21" fill="#7c3aed" fill-opacity="0.25" stroke="#8b5cf6" stroke-width="1.5" />
      <text x="505" y="26" font-family="-apple-system, BlinkMacSystemFont, sans-serif" font-size="16" font-weight="600" fill="#a78bfa" text-anchor="middle">🛠️ Instant QuickFixes</text>
    </g>
  </g>

  <g transform="translate(100, 560)">
    <text font-family="-apple-system, BlinkMacSystemFont, sans-serif" font-size="17" font-weight="500" fill="#64748b">https://furkancosgun.github.io/skylint</text>
    <text x="1000" font-family="-apple-system, BlinkMacSystemFont, sans-serif" font-size="17" font-weight="500" fill="#64748b" text-anchor="end">Contract C1 · Steampunk Ready</text>
  </g>
</svg>`;

  const ogSvgPath = path.join(publicDir, 'og-image.svg');
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
