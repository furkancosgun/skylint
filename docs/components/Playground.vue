<script setup>
import { ref, reactive, computed, onMounted, onUnmounted, nextTick } from 'vue';
import { withBase } from 'vitepress';
import { EditorView, basicSetup } from 'codemirror';
import { EditorState } from '@codemirror/state';
import { lintGutter, setDiagnostics } from '@codemirror/lint';
import { abapSupport } from './cm-abap.mjs';
import { analyze, applyFix, RULE_DEFS, PLAYGROUND_RULE_IDS, SAMPLE_SOURCE } from './playground-rules.mjs';

// --- State ---
const source = ref(SAMPLE_SOURCE);
const findings = ref([]);
const parseError = ref(null);
const statementCount = ref(0);
const ms = ref(0);
const activeLine = ref(0);
const totalLines = computed(() => source.value.split('\n').length);

const editorContainer = ref(null);
let cmView = null;

const ruleState = reactive({});
for (const rule of RULE_DEFS) {
  ruleState[rule.id] = { enabled: rule.enabled, maxLen: rule.maxLen || 120 };
}

const enabledCount = computed(() => RULE_DEFS.filter((r) => ruleState[r.id].enabled).length);

const countByRule = computed(() => {
  const map = {};
  for (const f of findings.value) map[f.rule] = (map[f.rule] || 0) + 1;
  return map;
});

// --- CodeMirror Theme ---
const skylintTheme = EditorView.theme({
  '&': {
    height: '500px',
    fontSize: '13px',
    fontFamily: 'var(--vp-font-family-mono)',
    backgroundColor: 'var(--vp-c-bg)',
    color: 'var(--vp-c-text-1)',
    borderRadius: '12px',
    border: '1px solid var(--vp-c-divider)',
    overflow: 'hidden',
  },
  '.cm-scroller': {
    overflow: 'auto',
    fontFamily: 'var(--vp-font-family-mono)',
  },
  '.cm-content': {
    padding: '10px 0',
    caretColor: 'var(--vp-c-brand-1)',
  },
  '.cm-line': {
    padding: '0 12px',
    lineHeight: '1.6',
  },
  '&.cm-focused': {
    outline: 'none',
  },
  '.cm-gutters': {
    backgroundColor: 'var(--vp-c-bg-soft)',
    color: 'var(--vp-c-text-3)',
    borderRight: '1px solid var(--vp-c-divider)',
    fontFamily: 'var(--vp-font-family-mono)',
    fontSize: '11.5px',
    minWidth: '42px',
  },
  '.cm-lineNumbers .cm-gutterElement': {
    padding: '0 8px 0 6px',
  },
  '.cm-activeLine': {
    backgroundColor: 'var(--vp-c-default-soft)',
  },
  '.cm-activeLineGutter': {
    backgroundColor: 'transparent',
    color: 'var(--vp-c-brand-1)',
    fontWeight: 'bold',
  },
  '.cm-selectionBackground, ::selection': {
    backgroundColor: 'var(--vp-c-brand-soft) !important',
  },
  '.cm-cursor': {
    borderLeftColor: 'var(--vp-c-brand-1)',
  },
  '.cm-tooltip': {
    backgroundColor: 'var(--vp-c-bg)',
    border: '1px solid var(--vp-c-divider)',
    borderRadius: '8px',
    boxShadow: '0 8px 24px rgba(0, 0, 0, 0.18)',
    padding: '6px 10px',
    color: 'var(--vp-c-text-1)',
    fontFamily: 'var(--vp-font-family-base)',
    fontSize: '12px',
  },
  '.cm-tooltip.cm-tooltip-lint': {
    maxWidth: '380px',
  },
  '.cm-diagnostic': {
    padding: '4px 6px',
    borderLeft: '3px solid #f59e0b',
  },
  '.cm-diagnosticAction': {
    display: 'inline-block',
    marginTop: '4px',
    padding: '2px 8px',
    borderRadius: '4px',
    backgroundColor: 'var(--vp-c-brand-1)',
    color: '#fff',
    fontSize: '11px',
    fontWeight: '600',
    cursor: 'pointer',
    border: 'none',
  },
  '.cm-lintRange-warning': {
    backgroundImage: 'none',
    borderBottom: '2px wavy #f59e0b',
  },
});

// --- Diagnostics Sync ---
function updateDiagnostics() {
  if (!cmView) return;
  const doc = cmView.state.doc;
  const diagnostics = [];

  for (const f of findings.value) {
    if (!f.line || f.line > doc.lines || f.line < 1) continue;
    const lineObj = doc.line(f.line);
    const col = Math.max(0, (f.column || 1) - 1);
    const from = Math.min(lineObj.to, lineObj.from + col);
    const remaining = lineObj.to - from;
    const len = Math.max(1, Math.min(remaining, 16));
    const to = Math.min(lineObj.to, from + len);

    diagnostics.push({
      from,
      to,
      severity: 'warning',
      message: `[${f.code}] ${f.message}`,
      actions: f.fix ? [{
        name: 'Apply QuickFix',
        apply() {
          fixFinding(f);
        },
      }] : [],
    });
  }

  cmView.dispatch(setDiagnostics(cmView.state, diagnostics));
}

// --- Analysis ---
function runAnalysis() {
  const result = analyze(source.value, ruleState);
  findings.value = result.findings;
  parseError.value = result.parseError;
  statementCount.value = result.statementCount;
  ms.value = result.ms;
  updateDiagnostics();
}

let debounceTimer = null;
function debounceAnalysis() {
  clearTimeout(debounceTimer);
  debounceTimer = setTimeout(runAnalysis, 100);
}

function applyHash() {
  const hash = typeof window !== 'undefined' ? window.location.hash : '';
  const hashMatch = hash ? hash.match(/rule=([\w-]+)/) : null;
  if (hashMatch && PLAYGROUND_RULE_IDS.includes(hashMatch[1])) {
    for (const [id, state] of Object.entries(ruleState)) {
      state.enabled = id === hashMatch[1];
    }
    runAnalysis();
  }
}

onMounted(() => {
  applyHash();

  if (editorContainer.value) {
    const updateListener = EditorView.updateListener.of((update) => {
      if (update.docChanged) {
        source.value = update.state.doc.toString();
        debounceAnalysis();
      }
    });

    const state = EditorState.create({
      doc: source.value,
      extensions: [
        basicSetup,
        lintGutter(),
        abapSupport,
        skylintTheme,
        updateListener,
        EditorView.lineWrapping,
      ],
    });

    cmView = new EditorView({
      state,
      parent: editorContainer.value,
    });
  }

  runAnalysis();

  if (typeof window !== 'undefined') {
    window.addEventListener('hashchange', applyHash);
  }
});

onUnmounted(() => {
  if (typeof window !== 'undefined') {
    window.removeEventListener('hashchange', applyHash);
  }
  if (cmView) {
    cmView.destroy();
    cmView = null;
  }
});

// --- Actions ---
function showFinding(finding) {
  activeLine.value = finding.line;
  if (!cmView) return;
  const doc = cmView.state.doc;
  if (finding.line > doc.lines || finding.line < 1) return;
  const lineObj = doc.line(finding.line);
  const col = Math.max(0, (finding.column || 1) - 1);
  const pos = Math.min(lineObj.to, lineObj.from + col);
  cmView.dispatch({
    selection: { anchor: pos, head: Math.min(lineObj.to, pos + 10) },
    scrollIntoView: true,
  });
  cmView.focus();
}

function fixFinding(finding) {
  const newSource = applyFix(source.value, finding);
  source.value = newSource;
  if (cmView) {
    cmView.dispatch({
      changes: { from: 0, to: cmView.state.doc.length, insert: newSource },
    });
  }
  runAnalysis();
}

function resetSample() {
  activeLine.value = 0;
  source.value = SAMPLE_SOURCE;
  if (cmView) {
    cmView.dispatch({
      changes: { from: 0, to: cmView.state.doc.length, insert: SAMPLE_SOURCE },
    });
  }
  runAnalysis();
}
</script>

<template>
  <div class="pg">
    <div class="pg-rules-row">
      <button
        v-for="rule in RULE_DEFS"
        :key="rule.id"
        type="button"
        class="pg-chip"
        :class="{ off: !ruleState[rule.id].enabled }"
        :title="`${rule.category} · x${ruleState[rule.id].enabled ? (countByRule[rule.id] || 0) : 0} findings`"
        @click="ruleState[rule.id].enabled = !ruleState[rule.id].enabled; runAnalysis()"
      >
        <span class="pg-chip-dot" aria-hidden="true"></span>
        {{ rule.title }}
        <span v-if="countByRule[rule.id]" class="pg-chip-count">{{ countByRule[rule.id] }}</span>
      </button>

      <label v-if="ruleState['max-line-len'].enabled" class="pg-len-label">
        MAX_LENGTH:
        <input
          v-model.number="ruleState['max-line-len'].maxLen"
          type="number"
          min="20"
          max="400"
          class="pg-len-input"
          @input="runAnalysis"
        />
      </label>

      <span class="pg-spacer"></span>
      <button class="pg-ghost-btn" type="button" @click="resetSample">
        ⟨/⟩ Reset sample
      </button>
    </div>

    <div class="pg-grid">
      <div class="pg-editor-wrap">
        <div ref="editorContainer" class="pg-cm-container"></div>
        <p class="pg-status">
          <template v-if="parseError">⚠ Parser error</template>
          <template v-else>
            {{ statementCount }} statements · {{ totalLines }} lines · analyzed in {{ ms }} ms
          </template>
        </p>
      </div>

      <div class="pg-findings">
        <p class="pg-findings-head">
          Findings
          <span class="pg-findings-count">{{ findings.length }}</span>
        </p>

        <div v-if="parseError" class="pg-finding pg-parse-error">
          {{ parseError }}
        </div>
        <ul v-else-if="findings.length" class="pg-list">
          <li
            v-for="(f, i) in findings"
            :key="i"
            class="pg-finding"
            @mouseenter="activeLine = f.line"
            @mouseleave="activeLine = 0"
          >
            <div class="pg-finding-top">
              <code class="pg-code">{{ f.code }}</code>
              <span class="pg-loc">Ln {{ f.line }}, Col {{ f.column }}</span>
              <a
                v-if="f.rule"
                :href="withBase(`/rules/${f.rule}.html`)"
                target="_blank"
                class="pg-doc-link"
                title="View rule documentation"
              >
                Docs ↗
              </a>
              <button class="pg-fix-btn" type="button" @click="showFinding(f)">Go ⇥</button>
              <button v-if="f.fix" class="pg-fix-btn pg-fix-primary" type="button" @click="fixFinding(f)">
                Apply fix
              </button>
            </div>
            <p class="pg-msg">{{ f.message }}</p>
          </li>
        </ul>
        <div v-else class="pg-empty">
          No findings — clean code. 🎉
        </div>
      </div>
    </div>

    <p class="pg-note">
      💡 <strong>Zero Server Overhead:</strong> The parser and rules run 100% locally in your browser
      using Skylint's AST pipeline. Hover over code squiggles in the editor to see ATC finding details or apply QuickFixes directly.
    </p>
  </div>
</template>

<style scoped>
.pg {
  display: flex;
  flex-direction: column;
  gap: 0.75rem;
  max-width: 1200px;
  margin: 0 auto;
  font-size: 14px;
}

/* rule chips */
.pg-rules-row {
  display: flex;
  align-items: center;
  flex-wrap: wrap;
  gap: 0.4rem;
  margin-bottom: 0.4rem;
}

.pg-chip {
  display: inline-flex;
  align-items: center;
  gap: 0.4rem;
  padding: 0.28rem 0.7rem;
  border: 1px solid var(--vp-c-divider);
  border-radius: 999px;
  background: transparent;
  color: var(--vp-c-text-1);
  font-family: var(--vp-font-family-mono);
  font-size: 0.72rem;
  cursor: pointer;
  transition: border-color 0.15s, color 0.15s, opacity 0.15s;
}

.pg-chip:hover {
  border-color: var(--vp-c-brand-1);
  color: var(--vp-c-brand-1);
}

.pg-chip.off {
  opacity: 0.45;
}

.pg-chip-dot {
  width: 7px;
  height: 7px;
  border-radius: 50%;
  background: var(--vp-c-brand-1);
}

.pg-chip.off .pg-chip-dot {
  background: var(--vp-c-text-3);
}

.pg-chip-count {
  padding: 0 6px;
  border-radius: 999px;
  background: var(--vp-c-brand-soft);
  color: var(--vp-c-brand-1);
  font-weight: 700;
}

.pg-len-label {
  display: inline-flex;
  align-items: center;
  gap: 0.35rem;
  padding: 0.28rem 0.7rem;
  border: 1px dashed var(--vp-c-divider);
  border-radius: 999px;
  color: var(--vp-c-text-2);
  font-family: var(--vp-font-family-mono);
  font-size: 0.72rem;
}

.pg-len-input {
  width: 64px;
  padding: 0.1rem 0.35rem;
  border: 1px solid var(--vp-c-divider);
  border-radius: 6px;
  background: var(--vp-c-bg-soft);
  color: var(--vp-c-text-1);
  font-family: inherit;
  font-size: 0.72rem;
}

.pg-spacer {
  flex: 1;
}

.pg-ghost-btn {
  padding: 0.28rem 0.7rem;
  border: 1px solid var(--vp-c-divider);
  border-radius: 8px;
  background: transparent;
  color: var(--vp-c-text-2);
  font-size: 0.78rem;
  cursor: pointer;
}

.pg-ghost-btn:hover {
  border-color: var(--vp-c-brand-1);
  color: var(--vp-c-brand-1);
}

/* layout */
.pg-grid {
  display: grid;
  grid-template-columns: minmax(0, 7fr) minmax(0, 5fr);
  gap: 0.75rem;
}

@media (max-width: 768px) {
  .pg-grid {
    grid-template-columns: 1fr;
  }
}

/* editor */
.pg-editor-wrap {
  min-width: 0;
}

.pg-cm-container {
  min-width: 0;
}

.pg-status {
  margin: 0.35rem 0 0;
  font-size: 11px;
  font-family: var(--vp-font-family-mono);
  color: var(--vp-c-text-3);
}

/* findings panel */
.pg-findings {
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
  min-width: 0;
}

.pg-findings-head {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  margin: 0;
  font-size: 13px;
  font-weight: 700;
  color: var(--vp-c-text-1);
}

.pg-findings-count {
  padding: 0 7px;
  border-radius: 999px;
  background: var(--vp-c-brand-soft);
  color: var(--vp-c-brand-1);
  font-size: 12px;
}

.pg-list {
  display: flex;
  flex-direction: column;
  gap: 0.4rem;
  margin: 0;
  padding: 0;
  max-height: 500px;
  overflow: auto;
  list-style: none;
}

.pg-finding {
  padding: 0.6rem 0.75rem;
  border: 1px solid var(--vp-c-divider);
  border-radius: 10px;
  background: var(--vp-c-bg-soft);
}

.pg-parse-error {
  border-color: #ef4444;
  color: #b91c1c;
}

.pg-finding-top {
  display: flex;
  align-items: center;
  flex-wrap: wrap;
  gap: 0.4rem;
}

.pg-code {
  padding: 0.05rem 0.4rem;
  border: 1px solid var(--vp-c-brand-soft);
  border-radius: 5px;
  background: var(--vp-c-brand-softer);
  color: var(--vp-c-brand-1);
  font-family: var(--vp-font-family-mono);
  font-size: 10.5px;
  letter-spacing: 0.04em;
}

.pg-loc {
  color: var(--vp-c-text-3);
  font-family: var(--vp-font-family-mono);
  font-size: 10.5px;
}

.pg-doc-link {
  color: var(--vp-c-text-3);
  font-size: 11px;
  text-decoration: none;
  padding: 0.1rem 0.35rem;
  border-radius: 4px;
  transition: color 0.15s;
}

.pg-doc-link:hover {
  color: var(--vp-c-brand-1);
}

.pg-fix-btn {
  margin-left: auto;
  padding: 0.15rem 0.5rem;
  border: 1px solid var(--vp-c-divider);
  border-radius: 6px;
  background: transparent;
  color: var(--vp-c-text-2);
  font-size: 11px;
  cursor: pointer;
}

.pg-fix-btn:hover {
  border-color: var(--vp-c-brand-1);
  color: var(--vp-c-brand-1);
}

.pg-fix-btn + .pg-fix-btn {
  margin-left: 0;
}

.pg-fix-primary {
  border-color: var(--vp-c-brand-1);
  color: var(--vp-c-brand-1);
  font-weight: 600;
}

.pg-msg {
  margin: 0.35rem 0 0;
  font-size: 12.5px;
  line-height: 1.5;
  color: var(--vp-c-text-2);
}

.pg-empty {
  padding: 1.5rem 1rem;
  border: 1px dashed var(--vp-c-divider);
  border-radius: 10px;
  color: var(--vp-c-text-2);
  text-align: center;
}

/* footer note */
.pg-note {
  margin: 0.2rem 0 0;
  font-size: 12px;
  line-height: 1.6;
  color: var(--vp-c-text-3);
}

.pg-note code {
  font-family: var(--vp-font-family-mono);
  font-size: 0.9em;
}

/* ABAP Syntax Highlighting - Light Mode */
:deep(.cm-abap-kw) {
  color: #7c3aed;
  font-weight: 600;
}
:deep(.cm-abap-typ) {
  color: #0284c7;
  font-weight: 500;
}
:deep(.cm-abap-atm) {
  color: #e11d48;
  font-weight: 600;
}
:deep(.cm-abap-op) {
  color: #0d9488;
}
:deep(.cm-abap-str) {
  color: #16a34a;
}
:deep(.cm-abap-num) {
  color: #d97706;
}
:deep(.cm-abap-com) {
  color: #64748b;
  font-style: italic;
}
:deep(.cm-abap-meta) {
  color: #ea580c;
  font-weight: 600;
}

/* ABAP Syntax Highlighting - Dark Mode */
:deep(html.dark .cm-abap-kw) {
  color: #c084fc;
  font-weight: 600;
}
:deep(html.dark .cm-abap-typ) {
  color: #38bdf8;
  font-weight: 500;
}
:deep(html.dark .cm-abap-atm) {
  color: #fb7185;
  font-weight: 600;
}
:deep(html.dark .cm-abap-op) {
  color: #2dd4bf;
}
:deep(html.dark .cm-abap-str) {
  color: #4ade80;
}
:deep(html.dark .cm-abap-num) {
  color: #facc15;
}
:deep(html.dark .cm-abap-com) {
  color: #94a3b8;
  font-style: italic;
}
:deep(html.dark .cm-abap-meta) {
  color: #fb923c;
  font-weight: 600;
}
</style>
