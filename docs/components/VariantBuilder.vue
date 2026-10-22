<script setup>
import { ref, reactive, computed } from 'vue';
import rulesData from './rules-data.json';

// --- State ---
const searchQuery = ref('');
const selectedCategory = ref('ALL');
const filterOnlyConfigurable = ref(false);
const filterOnlyQuickfix = ref(false);
const filterOnlyRemoteEnabled = ref(false);

const variantName = ref('ZSKYLINT_CUSTOM');
const variantDescription = ref('Custom Skylint Clean ABAP Variant');
const abapLanguageVersion = ref('standard');

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
        ruleParams[r.checkName][attr.name] = stripQuotes(defParam.value);
      } else if (attr.kind === 'Boolean') {
        ruleParams[r.checkName][attr.name] = attr.defaultValue === 'true' ? 'X' : '';
      } else {
        ruleParams[r.checkName][attr.name] = stripQuotes(attr.defaultValue || '');
      }
    }
  }
}

// Drawer state for parameters
const expandedParams = reactive(new Set());

// --- UI Feedback ---
const copiedJson = ref(false);
const copiedPseudo = ref('');

// --- Wizard state ---
const currentStep = ref(1);
const steps = [
  { id: 1, label: 'Metadata' },
  { id: 2, label: 'Rules' },
  { id: 3, label: 'Review & Export' },
];

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

const remoteEnabledCount = computed(() => {
  return rulesData.filter((r) => r.remoteEnabled).length;
});

const activeCount = computed(() => selectedCheckNames.size);

const isAllSelected = computed(() => selectedCheckNames.size === rulesData.length);

const selectedByCategory = computed(() => {
  return categories.value
    .map((cat) => ({
      ...cat,
      selected: rulesData.filter(
        (r) => r.category === cat.key && selectedCheckNames.has(r.checkName)
      ).length,
    }))
    .filter((cat) => cat.selected > 0);
});

const variantJson = computed(() => JSON.stringify(generateVariantObject(), null, 2));

const highlightedJson = computed(() => highlightJson(variantJson.value));

const selectedQuickfixCount = computed(
  () => rulesData.filter((r) => r.hasQuickfix && selectedCheckNames.has(r.checkName)).length
);

const filteredRules = computed(() => {
  const q = searchQuery.value.trim().toLowerCase();
  const cat = selectedCategory.value;
  const onlyCfg = filterOnlyConfigurable.value;
  const onlyQf = filterOnlyQuickfix.value;
  const onlyRemote = filterOnlyRemoteEnabled.value;

  return rulesData.filter((rule) => {
    if (cat !== 'ALL' && rule.category !== cat) return false;
    if (onlyCfg && (!rule.attributes || rule.attributes.length === 0)) return false;
    if (onlyQf && !rule.hasQuickfix) return false;
    if (onlyRemote && !rule.remoteEnabled) return false;

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
function setStep(stepId) {
  currentStep.value = Math.min(Math.max(stepId, 1), steps.length);

  if (typeof window === 'undefined' || !window.matchMedia('(max-width: 640px)').matches) {
    return;
  }

  const target = document.querySelector('.vb-mobile-progress');
  if (!target) {
    return;
  }

  const reduceMotion = window.matchMedia('(prefers-reduced-motion: reduce)').matches;
  target.scrollIntoView({
    behavior: reduceMotion ? 'auto' : 'smooth',
    block: 'start',
  });
}

function goToStep(stepId) {
  setStep(stepId);
}

function nextStep() {
  setStep(currentStep.value + 1);
}

function prevStep() {
  setStep(currentStep.value - 1);
}

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
          ruleParams[r.checkName][attr.name] = stripQuotes(defParam.value);
        } else if (attr.kind === 'Boolean') {
          ruleParams[r.checkName][attr.name] = attr.defaultValue === 'true' ? 'X' : '';
        } else {
          ruleParams[r.checkName][attr.name] = stripQuotes(attr.defaultValue || '');
        }
      }
    }
  }
  variantName.value = 'ZSKYLINT_CUSTOM';
  variantDescription.value = 'Custom Skylint Clean ABAP Variant';
  abapLanguageVersion.value = 'standard';
}

function toggleParamDrawer(checkName) {
  if (expandedParams.has(checkName)) {
    expandedParams.delete(checkName);
  } else {
    expandedParams.add(checkName);
  }
}

function stripQuotes(value) {
  const trimmed = String(value ?? '').trim();
  const match = trimmed.match(/^'((?:[^']|'')*)'$/);
  if (!match) return trimmed;
  return match[1].replace(/''/g, "'");
}

function escapeHtml(value) {
  return String(value)
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;');
}

function highlightJson(json) {
  const escaped = escapeHtml(json);
  return escaped.replace(
    /("(?:\\u[a-fA-F0-9]{4}|\\[^u]|[^\\"])*"(\s*:)?|\b(?:true|false|null)\b|-?\d+(?:\.\d*)?(?:[eE][+-]?\d+)?)/g,
    (match) => {
      let cls = 'number';
      if (match.startsWith('"')) {
        cls = /:\s*$/.test(match) ? 'key' : 'string';
      } else if (match === 'true' || match === 'false') {
        cls = 'boolean';
      } else if (match === 'null') {
        cls = 'null';
      }
      return `<span class="vb-json-${cls}">${match}</span>`;
    }
  );
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
            params.push({ name: attr.name, value: stripQuotes(val) });
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
      abapLanguageVersion: abapLanguageVersion.value || 'standard',
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

</script>

<template>
  <div class="vb-container">
    <!-- Top Hero Section -->
    <header class="vb-hero">
      <div class="vb-hero-badge">SAP ATC & Clean ABAP Suite</div>
      <h1 class="vb-hero-title">ATC Variant Builder</h1>
      <p class="vb-hero-subtitle">
        Configure custom SAP ATC check variants, tune rule parameters and download
        <code>.chkv.json</code> files for SAP GUI / abapGit.
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

    <nav class="vb-stepper" aria-label="Variant builder steps">
      <button
        v-for="step in steps"
        :key="step.id"
        type="button"
        class="vb-step"
        :class="{ active: currentStep === step.id, complete: currentStep > step.id }"
        :aria-current="currentStep === step.id ? 'step' : undefined"
        @click="goToStep(step.id)"
      >
        <span class="vb-step-num">
          <svg v-if="currentStep > step.id" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3" aria-hidden="true">
            <path d="m5 12 4 4L19 6" />
          </svg>
          <template v-else>{{ step.id }}</template>
        </span>
        <span>{{ step.label }}</span>
      </button>
    </nav>

    <div class="vb-mobile-progress">
      <div class="vb-mobile-progress-row">
        <span class="vb-mobile-progress-step">Step {{ currentStep }} of {{ steps.length }}</span>
        <strong class="vb-mobile-progress-label">{{ steps[currentStep - 1].label }}</strong>
      </div>
      <div
        class="vb-mobile-progress-track"
        role="progressbar"
        :aria-valuenow="currentStep"
        aria-valuemin="1"
        :aria-valuemax="steps.length"
      >
        <span :style="{ width: `${(currentStep / steps.length) * 100}%` }"></span>
      </div>
    </div>

    <!-- Variant Configuration & Export Card -->
    <section v-show="currentStep === 1" class="vb-card">
      <div class="vb-card-header">
        <div class="vb-card-title-group">
          <svg class="vb-icon-svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" aria-hidden="true">
            <path d="M4 6h10M18 6h2M4 12h4M12 12h8M4 18h10M18 18h2" />
            <circle cx="16" cy="6" r="2" />
            <circle cx="10" cy="12" r="2" />
            <circle cx="16" cy="18" r="2" />
          </svg>
          <div>
            <h2 class="vb-card-title">Variant Configuration</h2>
            <p class="vb-card-desc">Define your variant metadata and export to standard SAP ATC JSON format.</p>
          </div>
        </div>
        <button class="vb-btn vb-btn-ghost" type="button" @click="resetDefaults" title="Reset to defaults">
          <svg class="vb-btn-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" aria-hidden="true">
            <path d="M3 12a9 9 0 1 0 3-6.7M3 4v5h5" />
          </svg>
          Reset defaults
        </button>
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
        </div>

        <div class="vb-field">
          <label class="vb-label">Variant Description</label>
          <input
            v-model="variantDescription"
            type="text"
            class="vb-input"
            placeholder="Custom Skylint Clean ABAP Variant"
          />
        </div>

        <div class="vb-field">
          <label class="vb-label">ABAP Language Version</label>
          <select v-model="abapLanguageVersion" class="vb-select">
            <option value="standard">Standard</option>
            <option value="cloudDevelopment">ABAP Cloud Development</option>
          </select>
        </div>
      </div>
    </section>

    <!-- Search & Filter Controls -->
    <section v-show="currentStep === 2" class="vb-filters-section">
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
            :placeholder="`Search ${rulesData.length} rules by ID, title, pseudo-comment (#EC ...), or description...`"
          />
          <button v-if="searchQuery" class="vb-clear-btn" type="button" aria-label="Clear search" @click="searchQuery = ''">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" aria-hidden="true">
              <path d="M18 6 6 18M6 6l12 12" />
            </svg>
          </button>
        </div>

        <button v-if="!isAllSelected" class="vb-btn-sm" type="button" @click="selectAll">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" aria-hidden="true">
            <path d="m5 12 4 4L19 6" />
          </svg>
          Select all
        </button>
        <button v-else class="vb-btn-sm" type="button" @click="deselectAll">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" aria-hidden="true">
            <path d="M18 6 6 18M6 6l12 12" />
          </svg>
          Deselect all
        </button>
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
          Configurable ({{ configurableCount }})
        </button>
        <button
          class="vb-pill toggle-pill"
          :class="{ active: filterOnlyQuickfix }"
          @click="filterOnlyQuickfix = !filterOnlyQuickfix"
        >
          QuickFix ({{ quickfixCount }})
        </button>
        <button
          class="vb-pill toggle-pill"
          :class="{ active: filterOnlyRemoteEnabled }"
          @click="filterOnlyRemoteEnabled = !filterOnlyRemoteEnabled"
        >
          Remote Enabled ({{ remoteEnabledCount }})
        </button>
      </div>
    </section>

    <!-- Rules List -->
    <section v-show="currentStep === 2" class="vb-rules-section">
      <div class="vb-rules-header">
        <span>Showing {{ filteredRules.length }} of {{ rulesData.length }} checks</span>
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
            <span class="vb-tag">{{ rule.categoryTitle }}</span>
            <button
              class="vb-tag pseudo"
              type="button"
              :title="'Click to copy pseudo-comment #EC ' + rule.pseudoComment"
              @click="copyPseudo(rule.pseudoComment)"
            >
              <span v-if="copiedPseudo === rule.pseudoComment" class="vb-inline-status">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" aria-hidden="true">
                  <path d="m5 12 4 4L19 6" />
                </svg>
                Copied
              </span>
              <span v-else>#EC {{ rule.pseudoComment }}</span>
            </button>
            <span v-if="rule.hasQuickfix" class="vb-tag qf">
              <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" aria-hidden="true">
                <path d="M13 2 4 14h6l-1 8 9-12h-6l1-8Z" />
              </svg>
              QuickFix
            </span>
            <span v-if="!rule.remoteEnabled" class="vb-tag local" title="Check runs locally only (remote_enablement = abap_false)">
              <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" aria-hidden="true">
                <rect x="5" y="11" width="14" height="10" rx="2" />
                <path d="M8 11V8a4 4 0 0 1 8 0v3" />
              </svg>
              Local Only
            </span>

            <!-- Parameters Toggle (if applicable) -->
            <button
              v-if="rule.attributes && rule.attributes.length > 0"
              class="vb-tag params-toggle"
              type="button"
              :class="{ open: expandedParams.has(rule.checkName) }"
              @click="toggleParamDrawer(rule.checkName)"
            >
              <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" aria-hidden="true">
                <path d="M4 7h16M4 12h16M4 17h16" />
                <circle cx="9" cy="7" r="2" />
                <circle cx="15" cy="12" r="2" />
                <circle cx="9" cy="17" r="2" />
              </svg>
              {{ rule.attributes.length }} Parameter{{ rule.attributes.length > 1 ? 's' : '' }}
              <svg class="vb-arrow" :class="{ rotated: expandedParams.has(rule.checkName) }" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" aria-hidden="true">
                <path d="m6 9 6 6 6-6" />
              </svg>
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
                <div v-if="attr.kind === 'Boolean'">
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
                <div v-else>
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

    <section v-show="currentStep === 3" class="vb-card">
      <div class="vb-card-header">
        <div class="vb-card-title-group">
          <svg class="vb-icon-svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" aria-hidden="true">
            <path d="M9 3h6l1 2h3a1 1 0 0 1 1 1v14a1 1 0 0 1-1 1H5a1 1 0 0 1-1-1V6a1 1 0 0 1 1-1h3l1-2Z" />
            <path d="m8 13 3 3 5-6" />
          </svg>
          <div>
            <h2 class="vb-card-title">Review &amp; Export</h2>
            <p class="vb-card-desc">Validate the selected checks and inspect the generated CHKV JSON before exporting.</p>
          </div>
        </div>
      </div>

      <div class="vb-review-grid">
        <div class="vb-review-item">
          <span class="vb-review-label">Variant name</span>
          <strong class="vb-review-value">{{ variantName || 'ZSKYLINT_CUSTOM' }}</strong>
        </div>
        <div class="vb-review-item">
          <span class="vb-review-label">Language version</span>
          <strong class="vb-review-value">{{ abapLanguageVersion === 'cloudDevelopment' ? 'ABAP Cloud Development' : 'Standard' }}</strong>
        </div>
        <div class="vb-review-item">
          <span class="vb-review-label">Enabled checks</span>
          <strong class="vb-review-value">{{ activeCount }} / {{ rulesData.length }}</strong>
        </div>
        <div class="vb-review-item">
          <span class="vb-review-label">QuickFixes included</span>
          <strong class="vb-review-value">{{ selectedQuickfixCount }}</strong>
        </div>
      </div>

      <div class="vb-review-categories">
        <span v-for="cat in selectedByCategory" :key="cat.key" class="vb-count-pill">
          {{ cat.title }}: {{ cat.selected }}
        </span>
      </div>

      <div class="vb-json-header">
        <span>Variant JSON preview</span>
        <div class="vb-json-header-actions">
          <span>{{ activeCount }} checks · {{ abapLanguageVersion }}</span>
          <button class="vb-json-copy" type="button" title="Copy variant JSON" @click="copyVariantJson">
            <svg v-if="copiedJson" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" aria-hidden="true">
              <path d="m5 12 4 4L19 6" />
            </svg>
            <svg v-else viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" aria-hidden="true">
              <rect x="9" y="9" width="12" height="12" rx="2" />
              <path d="M5 15H4a2 2 0 0 1-2-2V4a2 2 0 0 1 2-2h9a2 2 0 0 1 2 2v1" />
            </svg>
            {{ copiedJson ? 'Copied' : 'Copy JSON' }}
          </button>
        </div>
      </div>
      <pre class="vb-json-preview" aria-label="Generated CHKV JSON"><code v-html="highlightedJson"></code></pre>
    </section>

    <div class="vb-sticky-bar" role="region" aria-label="Variant builder actions">
      <div class="vb-sticky-info">
        <span class="vb-sticky-step">Step {{ currentStep }} of {{ steps.length }}</span>
        <span class="vb-sticky-count">{{ activeCount }} checks enabled</span>
      </div>
      <div class="vb-sticky-actions">
        <button
          class="vb-btn vb-btn-secondary"
          type="button"
          :disabled="currentStep === 1"
          @click="prevStep"
        >
          Back
        </button>
        <button v-if="currentStep < steps.length" class="vb-btn vb-btn-primary" type="button" @click="nextStep">
          Continue
        </button>
        <button v-else class="vb-btn vb-btn-primary" type="button" @click="downloadVariant">
          <svg class="vb-btn-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" aria-hidden="true">
            <path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4M7 10l5 5 5-5M12 15V3" />
          </svg>
          Download<span class="vb-download-ext"> .chkv.json</span>
        </button>
      </div>
    </div>

  </div>
</template>

<style scoped>
/* Main Container */
.vb-container {
  max-width: 1240px;
  margin: 0 auto;
  padding: 2rem 1.5rem 8rem;
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

.vb-btn {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  gap: 0.5rem;
  font-weight: 600;
  font-size: 0.88rem;
  padding: 0.5rem 1rem;
  border-radius: 6px;
  border: 1px solid transparent;
  cursor: pointer;
  transition: all 0.2s ease;
}

.vb-btn:disabled {
  opacity: 0.45;
  cursor: not-allowed;
  transform: none;
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
  display: inline-flex;
  align-items: center;
  gap: 0.35rem;
  padding: 0.4rem 0.75rem;
  border: 1px solid var(--vp-c-divider);
  border-radius: 6px;
  background: var(--vp-c-bg-soft);
  color: var(--vp-c-text-1);
  font-size: 0.8rem;
  font-weight: 500;
  cursor: pointer;
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
  margin-bottom: 0.75rem;
  color: var(--vp-c-text-3);
  font-size: 0.82rem;
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
  display: inline-flex;
  align-items: center;
  gap: 0.3rem;
  padding: 0.15rem 0.5rem;
  border: 1px solid var(--vp-c-divider);
  border-radius: 4px;
  background: var(--vp-c-bg);
  color: var(--vp-c-text-2);
  font-size: 0.72rem;
  font-weight: 500;
}

.vb-tag.pseudo {
  color: var(--vp-c-text-1);
  font-family: var(--vp-font-family-mono);
  cursor: pointer;
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

.vb-tag.local {
  background: #e0e7ff;
  color: #4338ca;
  border-color: #c7d2fe;
  font-weight: 600;
}

html.dark .vb-tag.local {
  background: rgba(99, 102, 241, 0.15);
  color: #a5b4fc;
  border-color: rgba(99, 102, 241, 0.3);
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

/* Wizard stepper */
.vb-stepper {
  display: flex;
  gap: 0.4rem;
  max-width: 760px;
  margin: 0 auto 2rem;
  padding: 0.4rem;
  background: var(--vp-c-bg-soft);
  border: 1px solid var(--vp-c-divider);
  border-radius: 12px;
}

.vb-step {
  flex: 1;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 0.5rem;
  padding: 0.6rem 0.75rem;
  border: 0;
  border-radius: 8px;
  background: transparent;
  color: var(--vp-c-text-2);
  cursor: pointer;
  font-family: inherit;
  font-size: 0.85rem;
  font-weight: 600;
  transition: background-color 0.2s ease, color 0.2s ease;
}

.vb-step:hover {
  color: var(--vp-c-text-1);
}

.vb-step.active {
  background: var(--vp-c-bg);
  color: var(--vp-c-brand-1);
  box-shadow: 0 1px 4px rgba(0, 0, 0, 0.08);
}

.vb-step.complete {
  color: var(--vp-c-brand-1);
}

.vb-step-num {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  width: 24px;
  height: 24px;
  border-radius: 999px;
  border: 1px solid var(--vp-c-divider);
  font-size: 0.72rem;
  font-weight: 700;
  flex-shrink: 0;
}

.vb-step-num svg {
  width: 13px;
  height: 13px;
}

.vb-step.active .vb-step-num {
  background: var(--vp-c-brand-1);
  border-color: var(--vp-c-brand-1);
  color: #fff;
}

.vb-step.complete .vb-step-num {
  background: var(--vp-c-brand-soft);
  border-color: transparent;
  color: var(--vp-c-brand-1);
}

.vb-mobile-progress {
  display: none;
}

@media (max-width: 640px) {
  .vb-stepper {
    display: none;
  }

  .vb-mobile-progress {
    display: block;
    max-width: 760px;
    margin: 0 auto 1.25rem;
    padding: 0 0.25rem;
    scroll-margin-top: calc(var(--vp-nav-height) + 16px);
  }

  .vb-mobile-progress-row {
    display: flex;
    align-items: baseline;
    justify-content: space-between;
    gap: 0.5rem;
    margin-bottom: 0.4rem;
  }

  .vb-mobile-progress-step {
    font-size: 0.7rem;
    font-weight: 700;
    letter-spacing: 0.05em;
    text-transform: uppercase;
    color: var(--vp-c-text-3);
  }

  .vb-mobile-progress-label {
    font-size: 0.9rem;
    color: var(--vp-c-text-1);
  }

  .vb-mobile-progress-track {
    height: 4px;
    overflow: hidden;
    border: 1px solid var(--vp-c-divider);
    border-radius: 999px;
    background: var(--vp-c-bg-soft);
  }

  .vb-mobile-progress-track span {
    display: block;
    height: 100%;
    background: var(--vp-c-brand-1);
    transition: width 0.25s ease;
  }
}

/* Inline icons */
.vb-icon-svg {
  width: 1.75rem;
  height: 1.75rem;
  color: var(--vp-c-brand-1);
  flex-shrink: 0;
}

.vb-btn-sm svg,
.vb-clear-btn svg {
  width: 14px;
  height: 14px;
}

.vb-clear-btn svg {
  display: block;
}

.vb-tag svg {
  width: 12px;
  height: 12px;
}

.vb-inline-status {
  display: inline-flex;
  align-items: center;
  gap: 0.25rem;
}

.vb-inline-status svg {
  width: 12px;
  height: 12px;
}

.vb-arrow {
  width: 12px;
  height: 12px;
  margin-left: 0.15rem;
  transition: transform 0.2s ease;
}

.vb-arrow.rotated {
  transform: rotate(180deg);
}

/* Review & export */
.vb-review-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 1rem;
}

.vb-review-item {
  display: flex;
  flex-direction: column;
  gap: 0.3rem;
  padding: 1rem;
  background: var(--vp-c-bg);
  border: 1px solid var(--vp-c-divider);
  border-radius: 8px;
}

.vb-review-label {
  font-size: 0.72rem;
  font-weight: 700;
  letter-spacing: 0.05em;
  text-transform: uppercase;
  color: var(--vp-c-text-3);
}

.vb-review-value {
  font-size: 1rem;
  color: var(--vp-c-text-1);
}

.vb-review-categories {
  display: flex;
  flex-wrap: wrap;
  gap: 0.4rem;
  margin-top: 1rem;
}

.vb-count-pill {
  padding: 0.2rem 0.55rem;
  border-radius: 999px;
  background: var(--vp-c-brand-soft);
  color: var(--vp-c-brand-1);
  font-size: 0.75rem;
  font-weight: 600;
}

.vb-json-header {
  display: flex;
  justify-content: space-between;
  gap: 1rem;
  flex-wrap: wrap;
  margin: 1.5rem 0 0.5rem;
  font-size: 0.75rem;
  font-weight: 700;
  letter-spacing: 0.04em;
  text-transform: uppercase;
  color: var(--vp-c-text-3);
}

.vb-json-header-actions {
  display: flex;
  align-items: center;
  gap: 0.6rem;
  flex-wrap: wrap;
}

.vb-json-copy {
  display: inline-flex;
  align-items: center;
  gap: 0.3rem;
  padding: 0.3rem 0.55rem;
  border: 1px solid var(--vp-c-divider);
  border-radius: 6px;
  background: var(--vp-c-bg-soft);
  color: var(--vp-c-text-2);
  font-family: inherit;
  font-size: 0.7rem;
  font-weight: 600;
  letter-spacing: normal;
  text-transform: none;
  cursor: pointer;
}

.vb-json-copy:hover {
  border-color: var(--vp-c-brand-1);
  color: var(--vp-c-brand-1);
}

.vb-json-copy svg {
  width: 14px;
  height: 14px;
}

.vb-json-preview :deep(.vb-json-key) {
  color: #0369a1;
  font-weight: 600;
}

.vb-json-preview :deep(.vb-json-string) {
  color: #15803d;
}

.vb-json-preview :deep(.vb-json-number) {
  color: #b45309;
}

.vb-json-preview :deep(.vb-json-boolean) {
  color: #7c3aed;
}

.vb-json-preview :deep(.vb-json-null) {
  color: #b91c1c;
}

html.dark .vb-json-preview :deep(.vb-json-key) {
  color: #7dd3fc;
}

html.dark .vb-json-preview :deep(.vb-json-string) {
  color: #86efac;
}

html.dark .vb-json-preview :deep(.vb-json-number) {
  color: #fcd34d;
}

html.dark .vb-json-preview :deep(.vb-json-boolean) {
  color: #c4b5fd;
}

html.dark .vb-json-preview :deep(.vb-json-null) {
  color: #fca5a5;
}

.vb-json-preview {
  margin: 0;
  max-height: 420px;
  overflow: auto;
  padding: 1rem;
  background: var(--vp-c-bg);
  border: 1px solid var(--vp-c-divider);
  border-radius: 8px;
  font-family: var(--vp-font-family-mono);
  font-size: 0.78rem;
  line-height: 1.55;
  tab-size: 2;
}

/* Sticky export bar */
.vb-sticky-bar {
  position: fixed;
  left: 50%;
  bottom: 1.25rem;
  transform: translateX(-50%);
  z-index: 30;
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 1rem;
  width: min(1100px, calc(100vw - 2rem));
  padding: 0.65rem 0.85rem 0.65rem 1rem;
  background: color-mix(in srgb, var(--vp-c-bg) 88%, transparent);
  border: 1px solid var(--vp-c-divider);
  border-radius: 12px;
  box-shadow: 0 12px 30px rgba(0, 0, 0, 0.18);
  backdrop-filter: blur(14px);
}

.vb-sticky-info {
  display: flex;
  flex-direction: column;
  gap: 0.1rem;
}

.vb-sticky-step {
  font-size: 0.72rem;
  font-weight: 700;
  letter-spacing: 0.05em;
  text-transform: uppercase;
  color: var(--vp-c-text-3);
}

.vb-sticky-count {
  font-size: 0.85rem;
  font-weight: 600;
}

.vb-sticky-actions {
  display: flex;
  gap: 0.5rem;
  flex-wrap: wrap;
}

@media (max-width: 640px) {
  .vb-sticky-bar {
    bottom: 0;
    width: 100%;
    padding: 0.5rem 0.65rem calc(0.5rem + env(safe-area-inset-bottom));
    border-radius: 12px 12px 0 0;
  }

  .vb-sticky-info {
    display: none;
  }

  .vb-sticky-actions {
    width: 100%;
    flex-wrap: nowrap;
    justify-content: center;
  }

  .vb-sticky-actions .vb-btn {
    flex: 1 1 0;
    max-width: 160px;
    min-height: 36px;
    padding: 0.45rem 0.7rem;
    font-size: 0.8rem;
    white-space: nowrap;
  }

  .vb-download-ext {
    display: none;
  }

  .vb-sticky-actions .vb-btn-icon {
    width: 14px;
    height: 14px;
  }
}
</style>
