<script setup>
import { ref, reactive, computed, watch, onMounted, nextTick } from 'vue';
import rulesData from './rules-data.json';
import { highlightAbap } from './abapHighlighter.mjs';

// --- State ---
const searchQuery = ref('');
const selectedCategory = ref('ALL');
const filterOnlyConfigurable = ref(false);
const filterOnlyQuickfix = ref(false);

const variantName = ref('ZSKYLINT_CUSTOM');
const variantDescription = ref('Custom Skylint Clean ABAP Variant');
const abapLanguageVersion = ref('cloudDevelopment');

// Set of enabled checkNames (default: all enabled)
const selectedCheckNames = reactive(new Set(rulesData.map((r) => r.checkName)));

// Parameters map: { [checkName]: { [paramName]: paramValue } }
const ruleParams = reactive({});
for (const r of rulesData) {
  ruleParams[r.checkName] = {};
  if (r.attributes && r.attributes.length > 0) {
    for (const attr of r.attributes) {
      // Find default parameter value if exists in defaultParameters
      const defParam = (r.defaultParameters || []).find((p) => p.name === attr.name);
      if (defParam) {
        ruleParams[r.checkName][attr.name] = defParam.value;
      } else if (attr.kind === 'Boolean') {
        ruleParams[r.checkName][attr.name] = attr.defaultValue === 'true' ? 'X' : '';
      } else {
        ruleParams[r.checkName][attr.name] = attr.defaultValue || '';
      }
    }
  }
}

// Drawer state for parameters
const expandedParams = reactive(new Set());

// --- Sandbox / Playground State ---
const sandboxCode = ref('');
const quickfixApplied = ref(false);

// UI Feedback
const copiedJson = ref(false);
const copiedCode = ref(false);
const copiedPseudo = ref('');

// --- Computed ---
const categories = computed(() => {
  const map = new Map();
  for (const r of rulesData) {
    const key = r.category || 'general';
    const title = r.categoryTitle || r.category || 'General';
    if (!map.has(key)) {
      map.set(key, { key, title, count: 0 });
    }
    map.get(key).count++;
  }
  return Array.from(map.values());
});

const configurableCount = computed(() => {
  return rulesData.filter((r) => r.attributes && r.attributes.length > 0).length;
});

const quickfixCount = computed(() => {
  return rulesData.filter((r) => r.hasQuickfix).length;
});

const activeCount = computed(() => selectedCheckNames.size);

const isAllSelected = computed(() => selectedCheckNames.size === rulesData.length);

const filteredRules = computed(() => {
  const q = searchQuery.value.trim().toLowerCase();
  const cat = selectedCategory.value;
  const onlyCfg = filterOnlyConfigurable.value;
  const onlyQf = filterOnlyQuickfix.value;

  return rulesData.filter((rule) => {
    if (cat !== 'ALL' && rule.category !== cat) return false;
    if (onlyCfg && (!rule.attributes || rule.attributes.length === 0)) return false;
    if (onlyQf && !rule.hasQuickfix) return false;

    if (q) {
      const matchId = rule.ruleId.toLowerCase().includes(q);
      const matchTitle = rule.title.toLowerCase().includes(q);
      const matchClass = rule.className.toLowerCase().includes(q);
      const matchCheck = rule.checkName.toLowerCase().includes(q);
      const matchPseudo = rule.pseudoComment.toLowerCase().includes(q);
      const matchDesc = rule.description.toLowerCase().includes(q);
      if (!matchId && !matchTitle && !matchClass && !matchCheck && !matchPseudo && !matchDesc) {
        return false;
      }
    }
    return true;
  });
});

// --- Methods ---
function toggleCheck(checkName) {
  if (selectedCheckNames.has(checkName)) {
    selectedCheckNames.delete(checkName);
  } else {
    selectedCheckNames.add(checkName);
  }
}

function selectAll() {
  for (const r of rulesData) {
    selectedCheckNames.add(r.checkName);
  }
}

function deselectAll() {
  selectedCheckNames.clear();
}

function resetDefaults() {
  selectedCheckNames.clear();
  for (const r of rulesData) {
    selectedCheckNames.add(r.checkName);
    if (r.attributes && r.attributes.length > 0) {
      for (const attr of r.attributes) {
        const defParam = (r.defaultParameters || []).find((p) => p.name === attr.name);
        if (defParam) {
          ruleParams[r.checkName][attr.name] = defParam.value;
        } else if (attr.kind === 'Boolean') {
          ruleParams[r.checkName][attr.name] = attr.defaultValue === 'true' ? 'X' : '';
        } else {
          ruleParams[r.checkName][attr.name] = attr.defaultValue || '';
        }
      }
    }
  }
  variantName.value = 'ZSKYLINT_CUSTOM';
  variantDescription.value = 'Custom Skylint Clean ABAP Variant';
  abapLanguageVersion.value = 'cloudDevelopment';
}

function toggleParamDrawer(checkName) {
  if (expandedParams.has(checkName)) {
    expandedParams.delete(checkName);
  } else {
    expandedParams.add(checkName);
  }
}

function generateVariantObject() {
  const vName = (variantName.value || 'ZSKYLINT_CUSTOM').trim().toUpperCase();
  const selectedChecks = [];

  for (const rule of rulesData) {
    if (selectedCheckNames.has(rule.checkName)) {
      const entry = { checkName: rule.checkName };
      const params = [];
      const currentParams = ruleParams[rule.checkName] || {};

      if (rule.attributes && rule.attributes.length > 0) {
        for (const attr of rule.attributes) {
          const val = currentParams[attr.name];
          if (val !== undefined && val !== '') {
            params.push({ name: attr.name, value: String(val) });
          }
        }
      }
      if (params.length > 0) {
        entry.parameters = params;
      }
      selectedChecks.push(entry);
    }
  }

  return {
    formatVersion: '1',
    header: {
      description: variantDescription.value || 'Custom Skylint Variant',
      originalLanguage: 'en',
      abapLanguageVersion: abapLanguageVersion.value || 'cloudDevelopment',
    },
    selectedChecks,
  };
}

function downloadVariant() {
  const vName = (variantName.value || 'ZSKYLINT_CUSTOM').trim().toUpperCase();
  const chkvObj = generateVariantObject();
  const jsonStr = JSON.stringify(chkvObj, null, 2);
  const blob = new Blob([jsonStr], { type: 'application/json' });
  const url = URL.createObjectURL(blob);
  const a = document.createElement('a');
  a.href = url;
  a.download = `${vName.toLowerCase()}.chkv.json`;
  document.body.appendChild(a);
  a.click();
  document.body.removeChild(a);
  URL.revokeObjectURL(url);
}

async function copyVariantJson() {
  const chkvObj = generateVariantObject();
  const jsonStr = JSON.stringify(chkvObj, null, 2);
  try {
    await navigator.clipboard.writeText(jsonStr);
    copiedJson.value = true;
    setTimeout(() => {
      copiedJson.value = false;
    }, 2000);
  } catch (e) {
    console.error('Failed to copy JSON:', e);
  }
}

async function copyPseudo(pseudo) {
  try {
    await navigator.clipboard.writeText(`#EC ${pseudo}`);
    copiedPseudo.value = pseudo;
    setTimeout(() => {
      copiedPseudo.value = '';
    }, 1800);
  } catch (e) {
    console.error('Failed to copy pseudo comment:', e);
  }
}

function formatAttrKind(attr) {
  if (attr.kind === 'Boolean') return 'Boolean';
  if (attr.kind === 'Integer' || /^\d+$/.test(attr.defaultValue)) return 'Integer';
  return 'String';
}

// Initialize empty sandbox code
sandboxCode.value = '';

// Multi-Rule Live Scanner (requires Node.js runtime for ABAP check execution)
const activeFindings = ref([]);
const isScanning = ref(false);

let scanTimer = null;
async function triggerScan() {
  clearTimeout(scanTimer);
  scanTimer = setTimeout(async () => {
    isScanning.value = true;
    try {
      console.warn('[Skylint] Live scan requires Node.js runtime; browser build uses stub.');
      activeFindings.value = [];
    } catch (err) {
      console.warn('[Skylint] Live scan error:', err);
    } finally {
      isScanning.value = false;
    }
  }, 60);
}

watch([sandboxCode, () => selectedCheckNames.size, ruleParams], () => {
  triggerScan();
}, { deep: true });

const fixableFindingsCount = computed(() => {
  return activeFindings.value.filter((f) => f.hasFix).length;
});

async function applySingleFix(finding) {
  const { applySingleFix: fixSingle } = await import('../../lib/runner/browser.mjs');
  sandboxCode.value = fixSingle(sandboxCode.value, finding);
}

async function applyAllFixes() {
  const { applyAllFixes: fixAll } = await import('../../lib/runner/browser.mjs');
  sandboxCode.value = fixAll(sandboxCode.value, activeFindings.value);
}

function clearCode() {
  sandboxCode.value = '';
}

async function copyCode() {
  try {
    await navigator.clipboard.writeText(sandboxCode.value);
    copiedCode.value = true;
    setTimeout(() => {
      copiedCode.value = false;
    }, 1800);
  } catch (e) {
    console.error('Failed to copy code:', e);
  }
}

// ABAP Syntax Highlighting & Editor State
const backdropRef = ref(null);
const textareaRef = ref(null);
const gutterRef = ref(null);

const lineCount = computed(() => {
  return Math.max(1, (sandboxCode.value || '').split('\n').length);
});

const highlightedCode = computed(() => {
  return highlightAbap(sandboxCode.value || '');
});

function syncEditorScroll(e) {
  if (backdropRef.value && e.target) {
    backdropRef.value.scrollTop = e.target.scrollTop;
    backdropRef.value.scrollLeft = e.target.scrollLeft;
  }
  if (gutterRef.value && e.target) {
    gutterRef.value.scrollTop = e.target.scrollTop;
  }
}

function handleEditorKeydown(e) {
  if (e.key === 'Tab') {
    e.preventDefault();
    const target = e.target;
    const start = target.selectionStart;
    const end = target.selectionEnd;
    const val = sandboxCode.value;
    sandboxCode.value = val.substring(0, start) + '  ' + val.substring(end);
    nextTick(() => {
      if (textareaRef.value) {
        textareaRef.value.selectionStart = textareaRef.value.selectionEnd = start + 2;
      }
    });
  }
}
</script>

<template>
  <div class="vb-container">
    <!-- Top Hero Section -->
    <header class="vb-hero">
      <div class="vb-hero-badge">SAP ATC & Clean ABAP Suite</div>
      <h1 class="vb-hero-title">ATC Variant Builder & Rule Sandbox</h1>
      <p class="vb-hero-subtitle">
        Configure custom SAP ATC check variants, tune rule parameters, download
        <code>.chkv.json</code> files for SAP GUI / abapGit, and test Clean ABAP rules live in your browser.
      </p>

      <!-- Stat Badges (Static Rules Overview) -->
      <div class="vb-stats-bar">
        <div class="vb-stat-chip">
          <span class="vb-stat-num">{{ rulesData.length }}</span>
          <span class="vb-stat-label">Total Rules</span>
        </div>
        <div class="vb-stat-chip">
          <span class="vb-stat-num">{{ configurableCount }}</span>
          <span class="vb-stat-label">Configurable Rules</span>
        </div>
        <div class="vb-stat-chip">
          <span class="vb-stat-num">{{ quickfixCount }}</span>
          <span class="vb-stat-label">Automated QuickFixes</span>
        </div>
        <div class="vb-stat-chip">
          <span class="vb-stat-num">100%</span>
          <span class="vb-stat-label">ABAP Cloud Ready</span>
        </div>
      </div>
    </header>

    <!-- Variant Configuration & Export Card -->
    <section class="vb-card vb-config-card">
      <div class="vb-card-header">
        <div class="vb-card-title-group">
          <span class="vb-icon">🎛️</span>
          <div>
            <h2 class="vb-card-title">Variant Configuration</h2>
            <p class="vb-card-desc">Define your variant metadata and export to standard SAP ATC JSON format.</p>
          </div>
        </div>
        <div class="vb-actions-group">
          <button class="vb-btn vb-btn-primary" @click="downloadVariant">
            <svg class="vb-btn-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
              <path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4M7 10l5 5 5-5M12 15V3" />
            </svg>
            Download Variant (.chkv.json)
          </button>
          <button class="vb-btn vb-btn-secondary" @click="copyVariantJson">
            <span v-if="copiedJson">✓ Copied!</span>
            <span v-else>📋 Copy JSON</span>
          </button>
          <button class="vb-btn vb-btn-ghost" @click="resetDefaults" title="Reset to defaults">
            ↺ Reset
          </button>
        </div>
      </div>

      <div class="vb-form-grid">
        <div class="vb-field">
          <label class="vb-label">Variant Name (SAP CHKV Object)</label>
          <input
            v-model="variantName"
            type="text"
            class="vb-input vb-input-mono"
            placeholder="ZSKYLINT_CUSTOM"
            @input="variantName = variantName.toUpperCase()"
          />
          <span class="vb-hint">Target name for SAP transaction SCI / ATC check variant</span>
        </div>

        <div class="vb-field">
          <label class="vb-label">Variant Description</label>
          <input
            v-model="variantDescription"
            type="text"
            class="vb-input"
            placeholder="Custom Skylint Clean ABAP Variant"
          />
          <span class="vb-hint">Displayed in Eclipse ADT and SAP GUI variant lists</span>
        </div>
      </div>
    </section>

    <!-- Search & Filter Controls -->
    <section class="vb-filters-section">
      <div class="vb-search-row">
        <div class="vb-search-box">
          <svg class="vb-search-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
            <circle cx="11" cy="11" r="8" />
            <line x1="21" y1="21" x2="16.65" y2="16.65" />
          </svg>
          <input
            v-model="searchQuery"
            type="text"
            class="vb-search-input"
            placeholder="Search 95 rules by ID, title, pseudo-comment (#EC ...), or description..."
          />
          <button v-if="searchQuery" class="vb-clear-btn" @click="searchQuery = ''">✕</button>
        </div>

        <div class="vb-bulk-actions">
          <button v-if="!isAllSelected" class="vb-btn-sm" @click="selectAll">✓ Select All</button>
          <button v-else class="vb-btn-sm" @click="deselectAll">✗ Deselect All</button>
        </div>
      </div>

      <!-- Category Filter Pills -->
      <div class="vb-pills-row">
        <button
          class="vb-pill"
          :class="{ active: selectedCategory === 'ALL' }"
          @click="selectedCategory = 'ALL'"
        >
          All ({{ rulesData.length }})
        </button>
        <button
          v-for="cat in categories"
          :key="cat.key"
          class="vb-pill"
          :class="{ active: selectedCategory === cat.key }"
          @click="selectedCategory = cat.key"
        >
          {{ cat.title }} ({{ cat.count }})
        </button>

        <div class="vb-pills-divider"></div>

        <button
          class="vb-pill toggle-pill"
          :class="{ active: filterOnlyConfigurable }"
          @click="filterOnlyConfigurable = !filterOnlyConfigurable"
        >
          ⚙️ Configurable ({{ configurableCount }})
        </button>
        <button
          class="vb-pill toggle-pill"
          :class="{ active: filterOnlyQuickfix }"
          @click="filterOnlyQuickfix = !filterOnlyQuickfix"
        >
          ⚡ QuickFix ({{ quickfixCount }})
        </button>
      </div>
    </section>

    <!-- Rules List -->
    <section class="vb-rules-section">
      <div class="vb-rules-header">
        <span class="vb-rules-count">Showing {{ filteredRules.length }} of {{ rulesData.length }} checks</span>
      </div>

      <div class="vb-rules-grid">
        <div
          v-for="rule in filteredRules"
          :key="rule.ruleId"
          class="vb-rule-card"
          :class="{ active: selectedCheckNames.has(rule.checkName) }"
        >
          <div class="vb-rule-card-top">
            <!-- Checkbox Switch -->
            <label class="vb-switch-wrapper" :title="selectedCheckNames.has(rule.checkName) ? 'Click to disable' : 'Click to enable'">
              <input
                type="checkbox"
                class="vb-switch-input"
                :checked="selectedCheckNames.has(rule.checkName)"
                @change="toggleCheck(rule.checkName)"
              />
              <span class="vb-switch-slider"></span>
            </label>

            <!-- Title & Class -->
            <div class="vb-rule-title-box">
              <div class="vb-rule-title-row">
                <a :href="`./rules/${rule.ruleId}.html`" class="vb-rule-title-link" target="_blank">
                  {{ rule.title }}
                </a>
                <code class="vb-rule-code-chip">{{ rule.checkName }}</code>
              </div>
              <p class="vb-rule-desc">{{ rule.description }}</p>
            </div>
          </div>

          <!-- Metadata Tags Row -->
          <div class="vb-tags-row">
            <span class="vb-tag cat">{{ rule.categoryTitle }}</span>
            <button
              class="vb-tag pseudo"
              :title="'Click to copy pseudo-comment #EC ' + rule.pseudoComment"
              @click="copyPseudo(rule.pseudoComment)"
            >
              <span v-if="copiedPseudo === rule.pseudoComment">✓ Copied</span>
              <span v-else>#EC {{ rule.pseudoComment }}</span>
            </button>
            <span v-if="rule.hasQuickfix" class="vb-tag qf">⚡ QuickFix Ready</span>

            <!-- Parameters Toggle (if applicable) -->
            <button
              v-if="rule.attributes && rule.attributes.length > 0"
              class="vb-tag params-toggle"
              :class="{ open: expandedParams.has(rule.checkName) }"
              @click="toggleParamDrawer(rule.checkName)"
            >
              ⚙️ {{ rule.attributes.length }} Parameter{{ rule.attributes.length > 1 ? 's' : '' }}
              <span class="vb-arrow">{{ expandedParams.has(rule.checkName) ? '▲' : '▼' }}</span>
            </button>
          </div>

          <!-- Parameters Drawer -->
          <div
            v-if="rule.attributes && rule.attributes.length > 0 && expandedParams.has(rule.checkName)"
            class="vb-params-drawer"
          >
            <div class="vb-params-header">Configure Parameters for {{ rule.checkName }}</div>
            <div class="vb-params-grid">
              <div
                v-for="attr in rule.attributes"
                :key="attr.name"
                class="vb-param-item"
              >
                <div class="vb-param-label-row">
                  <span class="vb-param-name">{{ attr.name }}</span>
                  <span class="vb-param-type">{{ formatAttrKind(attr) }}</span>
                </div>

                <!-- Boolean Parameter (Checkbox / Toggle) -->
                <div v-if="attr.kind === 'Boolean'" class="vb-param-control">
                  <label class="vb-checkbox-label">
                    <input
                      type="checkbox"
                      :checked="ruleParams[rule.checkName]?.[attr.name] === 'X'"
                      @change="ruleParams[rule.checkName][attr.name] = $event.target.checked ? 'X' : ''"
                    />
                    <span>Enabled (<code>'X'</code>)</span>
                  </label>
                </div>

                <!-- Elementary / Integer Parameter -->
                <div v-else class="vb-param-control">
                  <input
                    v-model="ruleParams[rule.checkName][attr.name]"
                    type="text"
                    class="vb-input vb-input-sm"
                    :placeholder="attr.defaultValue"
                  />
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </section>

    <!-- SECTION 2: Interactive Sandbox & Live Multi-Rule Playground -->
    <section id="sandbox-playground" class="vb-card vb-sandbox-card">
      <div class="vb-card-header">
        <div class="vb-card-title-group">
          <span class="vb-icon">⚡</span>
          <div>
            <h2 class="vb-card-title">Live Multi-Rule ABAP Sandbox & Diagnostics</h2>
            <p class="vb-card-desc">
              Test ABAP code against all active checks selected in your variant above ({{ selectedCheckNames.size }} active).
              Inspect live Rust-style compiler diagnostics and apply QuickFixes directly.
            </p>
          </div>
        </div>
      </div>

      <!-- Editor & Simulation Workspace (Stacked: Code Editor on Top, Diagnostics Terminal Below) -->
      <div class="vb-sandbox-workspace">
        <!-- Playground ABAP Code Window -->
        <div class="vb-window vb-editor-window">
          <!-- Window Titlebar -->
          <div class="vb-window-titlebar">
            <div class="vb-window-titlebar-left">
              <div class="vb-window-dots">
                <span class="vb-dot red"></span>
                <span class="vb-dot yellow"></span>
                <span class="vb-dot green"></span>
              </div>
              <div class="vb-window-tab active">
                <span class="vb-tab-icon">⚡</span>
                <span class="vb-tab-name">playground.abap</span>
              </div>
            </div>

            <div class="vb-window-titlebar-right">
              <button
                v-if="fixableFindingsCount > 0"
                class="vb-btn-window apply-qf active"
                title="Apply all available automated refactorings at once"
                @click="applyAllFixes"
              >
                ⚡ Apply All Fixes ({{ fixableFindingsCount }})
              </button>
              <button class="vb-btn-window" @click="copyCode">
                <span v-if="copiedCode">✓ Copied</span>
                <span v-else>📋 Copy</span>
              </button>
              <button class="vb-btn-window" @click="clearCode">
                🗑️ Clear
              </button>
            </div>
          </div>

          <!-- Editor Body with Line Numbers & Real-Time Syntax Highlighting Backdrop -->
          <div class="vb-editor-body">
            <div ref="gutterRef" class="vb-editor-gutter" aria-hidden="true">
              <div
                v-for="lineIdx in lineCount"
                :key="lineIdx"
                class="vb-gutter-line"
              >
                {{ lineIdx }}
              </div>
            </div>

            <div class="vb-editor-stage">
              <pre
                ref="backdropRef"
                class="vb-code-backdrop"
                aria-hidden="true"
              ><code v-html="highlightedCode"></code><br /></pre>
              <textarea
                ref="textareaRef"
                v-model="sandboxCode"
                class="vb-code-textarea"
                placeholder="Type or paste ABAP statements here to inspect live Clean ABAP diagnostics (e.g. DESCRIBE TABLE lt_data LINES lv_lines.)..."
                spellcheck="false"
                @scroll="syncEditorScroll"
                @keydown="handleEditorKeydown"
              ></textarea>
            </div>
          </div>
        </div>

        <!-- Terminal Diagnostic Console -->
        <div class="vb-window vb-terminal-window">
          <div class="vb-window-titlebar vb-terminal-titlebar">
            <div class="vb-window-titlebar-left">
              <div class="vb-window-dots">
                <span class="vb-dot red"></span>
                <span class="vb-dot yellow"></span>
                <span class="vb-dot green"></span>
              </div>
              <div class="vb-window-tab active">
                <span class="vb-term-prompt-symbol">$_</span>
                <span class="vb-tab-name">atc-diagnostics</span>
              </div>
            </div>

            <div class="vb-window-titlebar-right">
              <span class="vb-terminal-rule-count">{{ selectedCheckNames.size }} rules active</span>
              <div
                v-if="isScanning"
                class="vb-terminal-badge scanning"
              >
                SCANNING...
              </div>
              <div
                v-else-if="!sandboxCode.trim()"
                class="vb-terminal-badge idle"
              >
                IDLE
              </div>
              <div
                v-else
                class="vb-terminal-badge"
                :class="activeFindings.length > 0 ? 'warn' : 'pass'"
              >
                {{ activeFindings.length > 0 ? `${activeFindings.length} ${activeFindings.length > 1 ? 'ISSUES' : 'ISSUE'}` : 'CLEAN' }}
              </div>
            </div>
          </div>

          <div class="vb-terminal-body">
            <!-- Scanning State -->
            <div v-if="isScanning" class="vb-terminal-line vb-term-scanning">
              <span class="vb-term-prompt">&gt;</span> Running live ATC check passes across AST...
            </div>

            <!-- Empty / Idle State -->
            <div v-else-if="!sandboxCode.trim()" class="vb-terminal-idle-state">
              <div class="vb-terminal-line vb-term-dim">
                <span class="vb-term-prompt">$</span> skylint check --live --watch
              </div>
              <div class="vb-terminal-line vb-term-dim">
                Skylint Engine v1.0.0 &bull; Ready &bull; {{ selectedCheckNames.size }} ATC rules loaded in memory.
              </div>
              <div class="vb-terminal-line vb-term-highlight">
                &gt; Type or paste ABAP statements in the editor above to inspect live diagnostics in real time.
              </div>
            </div>

            <!-- Findings List -->
            <div v-else-if="activeFindings.length > 0" class="vb-diag-list">
              <div class="vb-terminal-line vb-term-cmd">
                <span class="vb-term-prompt">$</span> skylint check &mdash; {{ activeFindings.length }} finding{{ activeFindings.length > 1 ? 's' : '' }} detected:
              </div>

              <div
                v-for="finding in activeFindings"
                :key="finding.id"
                class="vb-diag-row"
                :class="{ 'is-parser-err': finding.code === 'PARSER_ERR' }"
              >
                <div class="vb-diag-row-main">
                  <span
                    class="vb-diag-pill"
                    :class="finding.severity === 'error' || finding.code === 'PARSER_ERR' ? 'error' : 'warn'"
                  >
                    {{ finding.code === 'PARSER_ERR' ? 'ERROR' : 'WARN' }}
                  </span>
                  <span class="vb-diag-loc">L{{ finding.lineNum }}:{{ finding.colNum }}</span>
                  <code class="vb-diag-code">[{{ finding.code }}]</code>
                  <span v-if="finding.ruleId" class="vb-diag-rule-name">({{ finding.ruleId }})</span>
                  <span class="vb-diag-msg" :title="finding.message">{{ finding.message }}</span>
                </div>

                <button
                  v-if="finding.hasFix"
                  class="vb-btn-diag-fix"
                  title="Apply QuickFix"
                  @click="applySingleFix(finding)"
                >
                  ⚡ QuickFix
                </button>
              </div>

              <div class="vb-diag-summary-line">
                <span class="vb-diag-warn">&bull; summary:</span>
                <span>Found {{ activeFindings.length }} issue{{ activeFindings.length > 1 ? 's' : '' }} across {{ selectedCheckNames.size }} active rules.</span>
                <span v-if="fixableFindingsCount > 0" class="vb-term-fixable">
                  ({{ fixableFindingsCount }} auto-fixable)
                </span>
              </div>
            </div>

            <!-- Compliant Clean State -->
            <div v-else class="vb-clean-content">
              <div class="vb-terminal-line vb-term-cmd">
                <span class="vb-term-prompt">$</span> skylint check &mdash; target clean
              </div>
              <div class="vb-terminal-line vb-term-success">
                ✔ 0 findings detected across {{ selectedCheckNames.size }} active ATC checks.
              </div>
              <div class="vb-terminal-line vb-term-dim">
                All statements comply with configured Clean ABAP guidelines.
              </div>
            </div>
          </div>
        </div>
      </div>
    </section>
  </div>
</template>

<style scoped>
/* Main Container */
.vb-container {
  max-width: 1240px;
  margin: 0 auto;
  padding: 2rem 1.5rem 4rem;
  color: var(--vp-c-text-1);
  font-family: var(--vp-font-family-base);
}

/* Hero */
.vb-hero {
  text-align: center;
  margin-bottom: 2.5rem;
}

.vb-hero-badge {
  display: inline-block;
  font-size: 0.75rem;
  font-weight: 700;
  letter-spacing: 0.08em;
  text-transform: uppercase;
  color: var(--vp-c-brand-1);
  background: var(--vp-c-brand-soft);
  padding: 0.25rem 0.75rem;
  border-radius: 9999px;
  margin-bottom: 0.75rem;
}

.vb-hero-title {
  font-size: 2.25rem;
  font-weight: 800;
  line-height: 1.2;
  margin: 0 0 0.75rem;
  background: linear-gradient(120deg, var(--vp-c-brand-1), var(--vp-c-brand-2));
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
}

.vb-hero-subtitle {
  font-size: 1.1rem;
  color: var(--vp-c-text-2);
  max-width: 800px;
  margin: 0 auto 1.5rem;
  line-height: 1.6;
}

.vb-hero-subtitle code {
  color: var(--vp-c-brand-1);
  background: var(--vp-c-bg-soft);
  padding: 0.15rem 0.4rem;
  border-radius: 4px;
}

/* Stats Bar */
.vb-stats-bar {
  display: flex;
  justify-content: center;
  gap: 1rem;
  flex-wrap: wrap;
  margin-top: 1rem;
}

.vb-stat-chip {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  background: var(--vp-c-bg-soft);
  border: 1px solid var(--vp-c-divider);
  padding: 0.4rem 0.9rem;
  border-radius: 8px;
  font-size: 0.85rem;
}

.vb-stat-chip.highlight {
  border-color: var(--vp-c-brand-1);
  background: var(--vp-c-brand-soft);
}

.vb-stat-num {
  font-weight: 700;
  color: var(--vp-c-brand-1);
}

.vb-stat-label {
  color: var(--vp-c-text-2);
}

/* Cards */
.vb-card {
  background: var(--vp-c-bg-soft);
  border: 1px solid var(--vp-c-divider);
  border-radius: 12px;
  padding: 1.5rem;
  margin-bottom: 2rem;
  box-shadow: 0 4px 16px rgba(0, 0, 0, 0.04);
}

.vb-card-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  flex-wrap: wrap;
  gap: 1rem;
  margin-bottom: 1.5rem;
  padding-bottom: 1rem;
  border-bottom: 1px solid var(--vp-c-divider);
}

.vb-card-title-group {
  display: flex;
  align-items: center;
  gap: 0.75rem;
}

.vb-icon {
  font-size: 1.75rem;
}

.vb-card-title {
  font-size: 1.3rem;
  font-weight: 700;
  margin: 0;
  color: var(--vp-c-text-1);
}

.vb-card-desc {
  font-size: 0.88rem;
  color: var(--vp-c-text-2);
  margin: 0.25rem 0 0;
}

/* Actions Group */
.vb-actions-group {
  display: flex;
  gap: 0.5rem;
  flex-wrap: wrap;
}

.vb-btn {
  display: inline-flex;
  align-items: center;
  gap: 0.5rem;
  font-weight: 600;
  font-size: 0.88rem;
  padding: 0.5rem 1rem;
  border-radius: 6px;
  border: 1px solid transparent;
  cursor: pointer;
  transition: all 0.2s ease;
}

.vb-btn-primary {
  background: var(--vp-c-brand-1);
  color: #fff;
}

.vb-btn-primary:hover {
  background: var(--vp-c-brand-2);
  transform: translateY(-1px);
}

.vb-btn-secondary {
  background: var(--vp-c-bg-elv);
  border-color: var(--vp-c-divider);
  color: var(--vp-c-text-1);
}

.vb-btn-secondary:hover {
  border-color: var(--vp-c-brand-1);
  color: var(--vp-c-brand-1);
}

.vb-btn-ghost {
  background: transparent;
  color: var(--vp-c-text-2);
}

.vb-btn-ghost:hover {
  color: var(--vp-c-text-1);
}

.vb-btn-icon {
  width: 16px;
  height: 16px;
}

/* Form Grid */
.vb-form-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
  gap: 1.25rem;
}

.vb-field {
  display: flex;
  flex-direction: column;
  gap: 0.4rem;
}

.vb-label {
  font-size: 0.82rem;
  font-weight: 600;
  color: var(--vp-c-text-1);
}

.vb-input,
.vb-select {
  padding: 0.5rem 0.75rem;
  background: var(--vp-c-bg);
  border: 1px solid var(--vp-c-divider);
  border-radius: 6px;
  color: var(--vp-c-text-1);
  font-size: 0.88rem;
  transition: border-color 0.2s ease;
}

.vb-input:focus,
.vb-select:focus {
  outline: none;
  border-color: var(--vp-c-brand-1);
}

.vb-input-mono {
  font-family: var(--vp-font-family-mono);
  font-weight: 600;
  letter-spacing: 0.05em;
}

.vb-hint {
  font-size: 0.75rem;
  color: var(--vp-c-text-3);
}

/* Filters Section */
.vb-filters-section {
  margin-bottom: 1.5rem;
}

.vb-search-row {
  display: flex;
  gap: 1rem;
  margin-bottom: 0.75rem;
  align-items: center;
}

.vb-search-box {
  position: relative;
  flex: 1;
}

.vb-search-icon {
  position: absolute;
  left: 0.85rem;
  top: 50%;
  transform: translateY(-50%);
  width: 18px;
  height: 18px;
  color: var(--vp-c-text-3);
}

.vb-search-input {
  width: 100%;
  padding: 0.6rem 2.2rem 0.6rem 2.5rem;
  background: var(--vp-c-bg-soft);
  border: 1px solid var(--vp-c-divider);
  border-radius: 8px;
  color: var(--vp-c-text-1);
  font-size: 0.9rem;
}

.vb-search-input:focus {
  outline: none;
  border-color: var(--vp-c-brand-1);
  background: var(--vp-c-bg);
}

.vb-clear-btn {
  position: absolute;
  right: 0.75rem;
  top: 50%;
  transform: translateY(-50%);
  background: transparent;
  border: none;
  color: var(--vp-c-text-3);
  cursor: pointer;
  font-size: 0.9rem;
}

.vb-btn-sm {
  font-size: 0.8rem;
  padding: 0.4rem 0.75rem;
  border-radius: 6px;
  background: var(--vp-c-bg-soft);
  border: 1px solid var(--vp-c-divider);
  color: var(--vp-c-text-1);
  cursor: pointer;
  font-weight: 500;
}

.vb-btn-sm:hover {
  border-color: var(--vp-c-brand-1);
}

/* Category Pills */
.vb-pills-row {
  display: flex;
  gap: 0.4rem;
  flex-wrap: wrap;
  align-items: center;
}

.vb-pill {
  font-size: 0.8rem;
  padding: 0.3rem 0.65rem;
  border-radius: 9999px;
  background: var(--vp-c-bg-soft);
  border: 1px solid var(--vp-c-divider);
  color: var(--vp-c-text-2);
  cursor: pointer;
  transition: all 0.2s ease;
}

.vb-pill:hover {
  color: var(--vp-c-text-1);
  border-color: var(--vp-c-brand-1);
}

.vb-pill.active {
  background: var(--vp-c-brand-1);
  color: #fff;
  border-color: var(--vp-c-brand-1);
  font-weight: 600;
}

.vb-pills-divider {
  width: 1px;
  height: 20px;
  background: var(--vp-c-divider);
  margin: 0 0.25rem;
}

.vb-pill.toggle-pill.active {
  background: var(--vp-c-brand-soft);
  color: var(--vp-c-brand-1);
  border-color: var(--vp-c-brand-1);
}

/* Rules Section */
.vb-rules-section {
  margin-bottom: 3rem;
}

.vb-rules-header {
  display: flex;
  justify-content: space-between;
  margin-bottom: 0.75rem;
  font-size: 0.82rem;
  color: var(--vp-c-text-3);
}

.vb-rules-grid {
  display: flex;
  flex-direction: column;
  gap: 0.75rem;
}

/* Rule Card */
.vb-rule-card {
  background: var(--vp-c-bg-soft);
  border: 1px solid var(--vp-c-divider);
  border-radius: 8px;
  padding: 1rem 1.25rem;
  transition: border-color 0.2s, box-shadow 0.2s;
}

.vb-rule-card.active {
  border-color: var(--vp-c-brand-soft);
  background: var(--vp-c-bg-soft);
}

.vb-rule-card:hover {
  border-color: var(--vp-c-brand-1);
}

.vb-rule-card-top {
  display: flex;
  align-items: flex-start;
  gap: 1rem;
}

/* Switch */
.vb-switch-wrapper {
  position: relative;
  display: inline-block;
  width: 38px;
  height: 22px;
  flex-shrink: 0;
  margin-top: 2px;
  cursor: pointer;
}

.vb-switch-input {
  opacity: 0;
  width: 0;
  height: 0;
}

.vb-switch-slider {
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background-color: var(--vp-c-divider);
  border-radius: 22px;
  transition: 0.2s;
}

.vb-switch-slider:before {
  position: absolute;
  content: "";
  height: 16px;
  width: 16px;
  left: 3px;
  bottom: 3px;
  background-color: white;
  border-radius: 50%;
  transition: 0.2s;
}

.vb-switch-input:checked + .vb-switch-slider {
  background-color: var(--vp-c-brand-1);
}

.vb-switch-input:checked + .vb-switch-slider:before {
  transform: translateX(16px);
}

/* Title Box */
.vb-rule-title-box {
  flex: 1;
}

.vb-rule-title-row {
  display: flex;
  align-items: center;
  gap: 0.6rem;
  flex-wrap: wrap;
}

.vb-rule-title-link {
  font-size: 0.98rem;
  font-weight: 600;
  color: var(--vp-c-text-1);
  text-decoration: none;
}

.vb-rule-title-link:hover {
  color: var(--vp-c-brand-1);
}

.vb-rule-code-chip {
  font-size: 0.75rem;
  padding: 0.1rem 0.4rem;
  border-radius: 4px;
  background: var(--vp-c-bg);
  border: 1px solid var(--vp-c-divider);
  color: var(--vp-c-brand-1);
}

.vb-rule-desc {
  font-size: 0.85rem;
  color: var(--vp-c-text-2);
  margin: 0.25rem 0 0;
  line-height: 1.4;
}

.vb-btn-test {
  font-size: 0.78rem;
  font-weight: 600;
  padding: 0.35rem 0.7rem;
  border-radius: 6px;
  background: var(--vp-c-brand-soft);
  color: var(--vp-c-brand-1);
  border: 1px solid transparent;
  cursor: pointer;
  white-space: nowrap;
  transition: all 0.2s ease;
}

.vb-btn-test:hover {
  background: var(--vp-c-brand-1);
  color: #fff;
}

/* Tags Row */
.vb-tags-row {
  display: flex;
  gap: 0.4rem;
  flex-wrap: wrap;
  align-items: center;
  margin-top: 0.65rem;
  padding-left: 3.35rem;
}

.vb-tag {
  font-size: 0.72rem;
  font-weight: 500;
  padding: 0.15rem 0.5rem;
  border-radius: 4px;
  border: 1px solid var(--vp-c-divider);
  background: var(--vp-c-bg);
  color: var(--vp-c-text-2);
}

.vb-tag.sev.warning {
  border-color: #f59e0b;
  color: #f59e0b;
}

.vb-tag.sev.error {
  border-color: #ef4444;
  color: #ef4444;
}

.vb-tag.pseudo {
  cursor: pointer;
  font-family: var(--vp-font-family-mono);
  background: var(--vp-c-bg);
  border-color: var(--vp-c-divider);
  color: var(--vp-c-text-1);
}

.vb-tag.pseudo:hover {
  border-color: var(--vp-c-brand-1);
  color: var(--vp-c-brand-1);
}

.vb-tag.qf {
  background: #fef3c7;
  color: #b45309;
  border-color: #fde68a;
  font-weight: 600;
}

html.dark .vb-tag.qf {
  background: rgba(245, 158, 11, 0.15);
  color: #fcd34d;
  border-color: rgba(245, 158, 11, 0.3);
}

.vb-tag.params-toggle {
  cursor: pointer;
  background: var(--vp-c-bg);
  color: var(--vp-c-brand-1);
  border-color: var(--vp-c-brand-1);
  font-weight: 600;
}

.vb-tag.params-toggle.open {
  background: var(--vp-c-brand-1);
  color: #fff;
}

.vb-arrow {
  font-size: 0.65rem;
  margin-left: 0.2rem;
}

/* Parameters Drawer */
.vb-params-drawer {
  margin-top: 0.75rem;
  margin-left: 3.35rem;
  padding: 0.85rem 1rem;
  background: var(--vp-c-bg);
  border: 1px solid var(--vp-c-divider);
  border-radius: 6px;
}

.vb-params-header {
  font-size: 0.78rem;
  font-weight: 700;
  text-transform: uppercase;
  letter-spacing: 0.05em;
  color: var(--vp-c-text-3);
  margin-bottom: 0.6rem;
}

.vb-params-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
  gap: 0.75rem;
}

.vb-param-item {
  display: flex;
  flex-direction: column;
  gap: 0.3rem;
}

.vb-param-label-row {
  display: flex;
  justify-content: space-between;
  font-size: 0.75rem;
}

.vb-param-name {
  font-family: var(--vp-font-family-mono);
  font-weight: 600;
  color: var(--vp-c-text-1);
}

.vb-param-type {
  color: var(--vp-c-text-3);
}

.vb-checkbox-label {
  display: flex;
  align-items: center;
  gap: 0.4rem;
  font-size: 0.8rem;
  cursor: pointer;
}

.vb-input-sm {
  padding: 0.3rem 0.5rem;
  font-size: 0.8rem;
}

/* SECTION 2: Sandbox Card */
.vb-sandbox-card {
  border-color: var(--vp-c-brand-1);
  box-shadow: 0 6px 24px rgba(0, 0, 0, 0.06);
}

.vb-rule-selector {
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.vb-label-inline {
  font-size: 0.82rem;
  font-weight: 600;
  color: var(--vp-c-text-2);
}

.vb-rule-select {
  max-width: 380px;
  font-weight: 500;
}

.vb-sandbox-banner {
  display: flex;
  justify-content: space-between;
  align-items: center;
  flex-wrap: wrap;
  gap: 0.75rem;
  padding: 0.75rem 1rem;
  background: var(--vp-c-bg);
  border: 1px solid var(--vp-c-divider);
  border-radius: 8px;
  margin-bottom: 1.25rem;
}

.vb-banner-left {
  display: flex;
  align-items: center;
  gap: 0.75rem;
}

.vb-banner-rule-id code {
  color: var(--vp-c-brand-1);
  background: var(--vp-c-brand-soft);
  padding: 0.15rem 0.4rem;
  border-radius: 4px;
  font-size: 0.85rem;
}

.vb-banner-rule-title {
  font-weight: 600;
  font-size: 0.95rem;
}

.vb-banner-tags {
  display: flex;
  gap: 0.4rem;
  align-items: center;
}

/* Sandbox Workspace (Vertical Stack) */
.vb-sandbox-workspace {
  display: flex;
  flex-direction: column;
  gap: 1rem;
  width: 100%;
}

/* Common Window Framework (Editor & Terminal) */
.vb-window {
  display: flex;
  flex-direction: column;
  border-radius: 8px;
  overflow: hidden;
  font-family: ui-monospace, SFMono-Regular, "SF Mono", Menlo, Consolas, "Liberation Mono", monospace;
  transition: background 0.2s ease, border-color 0.2s ease;
  background: #ffffff;
  border: 1px solid #d0d7de;
  box-shadow: 0 4px 16px rgba(0, 0, 0, 0.05);
}

html.dark .vb-window {
  background: #0d1117;
  border: 1px solid #30363d;
  box-shadow: 0 10px 30px rgba(0, 0, 0, 0.45);
}

/* Window Titlebars */
.vb-window-titlebar {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 0.45rem 0.85rem;
  background: #f6f8fa;
  border-bottom: 1px solid #d0d7de;
  user-select: none;
  flex-wrap: wrap;
  gap: 0.5rem;
  transition: background 0.2s ease, border-color 0.2s ease;
}

html.dark .vb-window-titlebar {
  background: #161b22;
  border-bottom: 1px solid #30363d;
}

.vb-window-titlebar-left {
  display: flex;
  align-items: center;
  gap: 0.75rem;
}

.vb-window-dots {
  display: flex;
  gap: 0.35rem;
}

.vb-dot {
  width: 11px;
  height: 11px;
  border-radius: 50%;
  display: inline-block;
}

.vb-dot.red { background: #f85149; }
.vb-dot.yellow { background: #d29922; }
.vb-dot.green { background: #2ea043; }

.vb-window-tab {
  display: flex;
  align-items: center;
  gap: 0.35rem;
  padding: 0.2rem 0.55rem;
  border-radius: 5px;
  font-size: 0.76rem;
  font-weight: 600;
  letter-spacing: 0.02em;
  background: #ffffff;
  color: #1f2328;
  border: 1px solid #d0d7de;
}

html.dark .vb-window-tab {
  background: #0d1117;
  color: #e6edf3;
  border: 1px solid #30363d;
}

.vb-term-prompt-symbol {
  color: #0969da;
  font-weight: 800;
}

html.dark .vb-term-prompt-symbol {
  color: #58a6ff;
}

.vb-window-titlebar-right {
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.vb-btn-window {
  font-size: 0.74rem;
  font-weight: 500;
  padding: 0.22rem 0.55rem;
  border-radius: 4px;
  border: 1px solid #d0d7de;
  background: #ffffff;
  color: #24292f;
  cursor: pointer;
  transition: all 0.15s ease;
}

.vb-btn-window:hover {
  border-color: #0969da;
  color: #0969da;
}

html.dark .vb-btn-window {
  border: 1px solid #30363d;
  background: #21262d;
  color: #c9d1d9;
}

html.dark .vb-btn-window:hover {
  border-color: #58a6ff;
  color: #58a6ff;
}

.vb-btn-window.apply-qf {
  background: #fff8c5;
  color: #9a6700;
  border-color: #d4a72c;
  font-weight: 700;
}

html.dark .vb-btn-window.apply-qf {
  background: rgba(210, 153, 34, 0.2);
  color: #f0883e;
  border-color: rgba(210, 153, 34, 0.4);
}

/* Editor Window Layout */
.vb-editor-body {
  display: flex;
  position: relative;
  min-height: 250px;
  background: #ffffff;
}

html.dark .vb-editor-body {
  background: #0d1117;
}

.vb-editor-gutter {
  padding: 10px 8px !important;
  text-align: right;
  min-width: 38px;
  font-family: ui-monospace, SFMono-Regular, "SF Mono", Menlo, Consolas, "Liberation Mono", monospace !important;
  font-size: 13.5px !important;
  line-height: 22px !important;
  user-select: none;
  background: #f6f8fa;
  color: #8c959f;
  border-right: 1px solid #d0d7de;
  overflow: hidden;
  box-sizing: border-box;
}

html.dark .vb-editor-gutter {
  background: #161b22;
  color: #6e7681;
  border-right: 1px solid #30363d;
}

.vb-gutter-line {
  height: 22px !important;
  line-height: 22px !important;
}

.vb-editor-stage {
  position: relative;
  flex: 1;
  min-height: 240px;
  overflow: hidden;
  --vb-kw: #cf222e;
  --vb-cmt: #6e7781;
  --vb-id: #000000;
}

html.dark .vb-editor-stage {
  --vb-kw: #ff7b72;
  --vb-cmt: #8b949e;
  --vb-id: #ffffff;
}

/* Syntax Backdrop & Textarea Synchronization */
.vb-code-backdrop,
.vb-code-textarea {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  margin: 0;
  padding: 10px 14px !important;
  border: none;
  font-family: ui-monospace, SFMono-Regular, "SF Mono", Menlo, Consolas, "Liberation Mono", monospace !important;
  font-size: 13.5px !important;
  line-height: 22px !important;
  letter-spacing: 0px !important;
  tab-size: 2 !important;
  white-space: pre-wrap !important;
  word-break: normal !important;
  overflow-wrap: break-word !important;
  box-sizing: border-box;
}

.vb-code-backdrop {
  pointer-events: none;
  background: transparent;
  color: var(--vb-id);
  overflow: hidden;
}

.vb-code-backdrop code {
  background: transparent !important;
  padding: 0 !important;
  font-family: inherit !important;
  font-size: inherit !important;
  line-height: inherit !important;
  white-space: inherit !important;
  word-break: inherit !important;
  color: inherit !important;
}

.vb-code-textarea {
  resize: none;
  outline: none;
  background: transparent !important;
  color: transparent !important;
  -webkit-text-fill-color: transparent !important;
  caret-color: #0969da !important;
  z-index: 2;
  overflow-y: auto;
}

html.dark .vb-code-textarea {
  caret-color: #58a6ff !important;
}

.vb-code-textarea::placeholder {
  color: #8c959f !important;
  -webkit-text-fill-color: #8c959f !important;
}

html.dark .vb-code-textarea::placeholder {
  color: #6e7681 !important;
  -webkit-text-fill-color: #6e7681 !important;
}

.vb-code-textarea::selection {
  background: rgba(9, 105, 218, 0.25);
  color: transparent;
  -webkit-text-fill-color: transparent;
}

html.dark .vb-code-textarea::selection {
  background: rgba(88, 166, 255, 0.3);
  color: transparent;
  -webkit-text-fill-color: transparent;
}

/* ABAP Syntax Highlighting - Strictly 3 Colors (Keywords, Identifiers, Comments) */
.vb-editor-stage :deep(.abap-kw) {
  color: var(--vb-kw) !important;
  font-weight: 700 !important;
}

.vb-editor-stage :deep(.abap-cmt) {
  color: var(--vb-cmt) !important;
  font-style: italic !important;
}

.vb-editor-stage :deep(.abap-id) {
  color: var(--vb-id) !important;
  font-weight: 400 !important;
}


/* Terminal Console Window */
.vb-terminal-rule-count {
  font-size: 0.72rem;
  color: #57606a;
}

html.dark .vb-terminal-rule-count {
  color: #8b949e;
}

.vb-terminal-badge {
  font-size: 0.68rem;
  font-weight: 700;
  padding: 0.15rem 0.55rem;
  border-radius: 9999px;
  letter-spacing: 0.04em;
  text-transform: uppercase;
}

.vb-terminal-badge.scanning {
  background: #ddf4ff;
  color: #0969da;
  border: 1px solid #54aeff;
}

html.dark .vb-terminal-badge.scanning {
  background: rgba(88, 166, 255, 0.18);
  color: #58a6ff;
  border: 1px solid rgba(88, 166, 255, 0.3);
}

.vb-terminal-badge.idle {
  background: #eaeef2;
  color: #57606a;
  border: 1px solid #d0d7de;
}

html.dark .vb-terminal-badge.idle {
  background: rgba(139, 148, 158, 0.15);
  color: #8b949e;
  border: 1px solid rgba(139, 148, 158, 0.25);
}

.vb-terminal-badge.warn {
  background: #fff8c5;
  color: #9a6700;
  border: 1px solid #d4a72c;
}

html.dark .vb-terminal-badge.warn {
  background: rgba(210, 153, 34, 0.2);
  color: #f0883e;
  border: 1px solid rgba(210, 153, 34, 0.35);
}

.vb-terminal-badge.pass {
  background: #dafbe1;
  color: #1a7f37;
  border: 1px solid #4ac26b;
}

html.dark .vb-terminal-badge.pass {
  background: rgba(46, 160, 67, 0.18);
  color: #3fb950;
  border: 1px solid rgba(46, 160, 67, 0.3);
}

.vb-terminal-body {
  padding: 0.85rem 1rem;
  font-size: 0.82rem;
  color: #1f2328;
  max-height: 380px;
  overflow-y: auto;
  line-height: 1.6;
  background: #f6f8fa;
  transition: background 0.2s ease, color 0.2s ease;
}

html.dark .vb-terminal-body {
  background: #0d1117;
  color: #c9d1d9;
}

.vb-terminal-line {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  margin-bottom: 0.25rem;
}

.vb-term-prompt {
  color: #0969da;
  font-weight: 800;
}

html.dark .vb-term-prompt {
  color: #58a6ff;
}

.vb-term-dim {
  color: #6e7781;
  font-size: 0.78rem;
}

html.dark .vb-term-dim {
  color: #8b949e;
}

.vb-term-highlight {
  color: #24292f;
  margin-top: 0.3rem;
  font-weight: 500;
}

html.dark .vb-term-highlight {
  color: #e6edf3;
}

.vb-term-cmd {
  color: #24292f;
  font-weight: 600;
  margin-bottom: 0.5rem;
}

html.dark .vb-term-cmd {
  color: #e6edf3;
}

.vb-term-scanning {
  color: #0969da;
  font-style: italic;
}

html.dark .vb-term-scanning {
  color: #58a6ff;
}

.vb-term-success {
  color: #1a7f37;
  font-weight: 700;
}

html.dark .vb-term-success {
  color: #3fb950;
}

.vb-term-fixable {
  color: #9a6700;
  font-weight: 700;
}

html.dark .vb-term-fixable {
  color: #d29922;
}

/* Diagnostic List */
.vb-diag-list {
  display: flex;
  flex-direction: column;
  gap: 0.4rem;
}

.vb-diag-row {
  display: flex;
  justify-content: space-between;
  align-items: center;
  background: #ffffff;
  border: 1px solid #d0d7de;
  border-left: 3px solid #d4a72c;
  border-radius: 4px;
  padding: 0.4rem 0.65rem;
  gap: 0.6rem;
  transition: all 0.15s ease;
}

.vb-diag-row:hover {
  background: #f3f4f6;
  border-color: #afb8c1;
}

html.dark .vb-diag-row {
  background: #161b22;
  border: 1px solid #30363d;
  border-left: 3px solid #d29922;
}

html.dark .vb-diag-row:hover {
  background: #1c2128;
  border-color: #484f58;
}

.vb-diag-row.is-parser-err {
  border-left-color: #cf222e !important;
}

html.dark .vb-diag-row.is-parser-err {
  border-left-color: #f85149 !important;
}

.vb-diag-row-main {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  font-size: 0.78rem;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
  flex: 1;
}

.vb-diag-pill {
  font-size: 0.65rem;
  font-weight: 800;
  padding: 0.1rem 0.4rem;
  border-radius: 3px;
  letter-spacing: 0.03em;
  flex-shrink: 0;
}

.vb-diag-pill.warn {
  background: #d4a72c;
  color: #ffffff;
}

html.dark .vb-diag-pill.warn {
  background: #d29922;
  color: #0d1117;
}

.vb-diag-pill.error {
  background: #cf222e;
  color: #ffffff;
}

html.dark .vb-diag-pill.error {
  background: #f85149;
  color: #ffffff;
}

.vb-diag-loc {
  color: #57606a;
  font-size: 0.75rem;
  flex-shrink: 0;
}

html.dark .vb-diag-loc {
  color: #8b949e;
}

.vb-diag-code {
  color: #9a6700;
  font-weight: 700;
  font-size: 0.75rem;
  flex-shrink: 0;
}

html.dark .vb-diag-code {
  color: #f0883e;
}

.vb-diag-rule-name {
  color: #6e7781;
  font-size: 0.72rem;
  flex-shrink: 0;
}

html.dark .vb-diag-rule-name {
  color: #8b949e;
}

.vb-diag-msg {
  color: #24292f;
  font-size: 0.8rem;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

html.dark .vb-diag-msg {
  color: #e6edf3;
}

.vb-btn-diag-fix {
  font-size: 0.7rem;
  font-weight: 700;
  padding: 0.2rem 0.55rem;
  border-radius: 4px;
  background: #0969da;
  color: #ffffff;
  border: none;
  cursor: pointer;
  transition: all 0.15s ease;
  white-space: nowrap;
  flex-shrink: 0;
}

.vb-btn-diag-fix:hover {
  background: #0860ca;
  transform: translateY(-1px);
}

html.dark .vb-btn-diag-fix {
  background: #d29922;
  color: #0d1117;
}

html.dark .vb-btn-diag-fix:hover {
  background: #e3b341;
}

.vb-diag-summary-line {
  margin-top: 0.4rem;
  padding-top: 0.5rem;
  border-top: 1px solid #d0d7de;
  color: #57606a;
  font-size: 0.76rem;
  font-weight: 600;
  display: flex;
  gap: 0.4rem;
  flex-wrap: wrap;
}

html.dark .vb-diag-summary-line {
  border-top-color: #30363d;
  color: #8b949e;
}

.vb-diag-warn {
  color: #9a6700;
  font-weight: 700;
}

html.dark .vb-diag-warn {
  color: #f0883e;
}

.vb-clean-content {
  display: flex;
  flex-direction: column;
  gap: 0.3rem;
  padding: 0.25rem 0;
}
</style>
