<script setup>
import { ref, computed, onMounted, onUnmounted } from 'vue';
import { EditorView, basicSetup } from 'codemirror';
import { EditorState } from '@codemirror/state';
import { lintGutter, setDiagnostics } from '@codemirror/lint';
import { abapSupport } from './cm-abap.mjs';
import { analyze, applyFix, RULE_DEFS } from './playground-rules.mjs';
import fixturesData from './playground-fixtures.json';

const props = defineProps({
  ruleId: { type: String, required: true },
});

const source = ref('');
const findings = ref([]);
const activeLine = ref(0);

const editorContainer = ref(null);
let cmView = null;

// Compact CodeMirror theme for inline rule page embed
const compactTheme = EditorView.theme({
  '&': {
    height: '280px',
    fontSize: '12.5px',
    fontFamily: 'var(--vp-font-family-mono)',
    backgroundColor: 'var(--vp-c-bg)',
    color: 'var(--vp-c-text-1)',
    borderRadius: '8px',
    border: '1px solid var(--vp-c-divider)',
    overflow: 'hidden',
  },
  '.cm-scroller': {
    overflow: 'auto',
    fontFamily: 'var(--vp-font-family-mono)',
  },
  '.cm-content': {
    padding: '8px 0',
    caretColor: 'var(--vp-c-brand-1)',
  },
  '.cm-line': {
    padding: '0 10px',
    lineHeight: '1.55',
  },
  '&.cm-focused': {
    outline: 'none',
  },
  '.cm-gutters': {
    backgroundColor: 'var(--vp-c-bg-soft)',
    color: 'var(--vp-c-text-3)',
    borderRight: '1px solid var(--vp-c-divider)',
    fontFamily: 'var(--vp-font-family-mono)',
    fontSize: '11px',
    minWidth: '38px',
  },
  '.cm-lineNumbers .cm-gutterElement': {
    padding: '0 6px',
  },
  '.cm-activeLine': {
    backgroundColor: 'var(--vp-c-default-soft)',
  },
  '.cm-activeLineGutter': {
    backgroundColor: 'transparent',
    color: 'var(--vp-c-brand-1)',
    fontWeight: 'bold',
  },
  '.cm-cursor': {
    borderLeftColor: 'var(--vp-c-brand-1)',
  },
  '.cm-tooltip': {
    backgroundColor: 'var(--vp-c-bg)',
    border: '1px solid var(--vp-c-divider)',
    borderRadius: '6px',
    padding: '4px 8px',
    fontSize: '11px',
  },
  '.cm-lintRange-warning': {
    backgroundImage: 'none',
    borderBottom: '2px wavy #f59e0b',
  },
});

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

function runAnalysis() {
  const state = {};
  for (const rule of RULE_DEFS) {
    state[rule.id] = { enabled: rule.id === props.ruleId, maxLen: 120 };
  }
  findings.value = analyze(source.value, state).findings;
  updateDiagnostics();
}

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

onMounted(() => {
  source.value = fixturesData[props.ruleId] || '';

  if (editorContainer.value) {
    const updateListener = EditorView.updateListener.of((update) => {
      if (update.docChanged) {
        source.value = update.state.doc.toString();
        runAnalysis();
      }
    });

    const state = EditorState.create({
      doc: source.value,
      extensions: [
        basicSetup,
        lintGutter(),
        abapSupport,
        compactTheme,
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
});

onUnmounted(() => {
  if (cmView) {
    cmView.destroy();
    cmView = null;
  }
});
</script>

<template>
  <div class="rpg">
    <p class="rpg-head">
      The Skylint rule engine mirrors this check 1:1 in your browser — edit the code,
      inspect the findings, and apply QuickFixes inline.
    </p>
    <div class="rpg-grid">
      <div class="rpg-editor">
        <div ref="editorContainer" class="rpg-cm-container"></div>
      </div>
      <div class="rpg-panel">
        <ul v-if="findings.length" class="rpg-list">
          <li
            v-for="(f, i) in findings"
            :key="i"
            class="rpg-finding"
            @mouseenter="activeLine = f.line"
            @mouseleave="activeLine = 0"
          >
            <div class="rpg-finding-top">
              <code class="rpg-code">{{ f.code }}</code>
              <span class="rpg-loc">Ln {{ f.line }}</span>
              <span v-if="f.fix" class="rpg-loc" style="margin-left: auto"><button type="button" class="rpg-fix" @click="fixFinding(f)">Apply fix</button></span>
              <span v-else class="rpg-loc" style="margin-left: auto"><button type="button" class="rpg-fix" @click="showFinding(f)">Go ⇥</button></span>
            </div>
            <p class="rpg-msg">{{ f.message }}</p>
          </li>
        </ul>
        <div v-else class="rpg-empty">
          No findings — clean code. 🎉
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped>
.rpg {
  border: 1px solid var(--vp-c-divider);
  border-radius: 12px;
  padding: 0.9rem;
  background: var(--vp-c-bg-soft);
  margin: 1rem 0 1.5rem;
}

.rpg-head {
  margin: 0 0 0.6rem;
  font-size: 13px;
  color: var(--vp-c-text-2);
}

.rpg-grid {
  display: grid;
  grid-template-columns: minmax(0, 7fr) minmax(0, 5fr);
  gap: 0.75rem;
}

@media (max-width: 768px) {
  .rpg-grid {
    grid-template-columns: 1fr;
  }
}

.rpg-editor {
  min-width: 0;
}

.rpg-cm-container {
  min-width: 0;
}

.rpg-panel {
  display: flex;
  flex-direction: column;
  min-width: 0;
}

.rpg-list {
  display: flex;
  flex-direction: column;
  gap: 0.4rem;
  margin: 0;
  padding: 0;
  max-height: 280px;
  overflow: auto;
  list-style: none;
}

.rpg-finding {
  padding: 0.5rem 0.65rem;
  border: 1px solid var(--vp-c-divider);
  border-radius: 8px;
  background: var(--vp-c-bg);
}

.rpg-finding-top {
  display: flex;
  align-items: center;
  gap: 0.4rem;
}

.rpg-code {
  padding: 0.05rem 0.35rem;
  border-radius: 4px;
  background: var(--vp-c-brand-soft);
  color: var(--vp-c-brand-1);
  font-family: var(--vp-font-family-mono);
  font-size: 10px;
  font-weight: 700;
}

.rpg-loc {
  color: var(--vp-c-text-3);
  font-family: var(--vp-font-family-mono);
  font-size: 10.5px;
}

.rpg-fix {
  padding: 0.15rem 0.45rem;
  border: 1px solid var(--vp-c-brand-1);
  border-radius: 5px;
  background: transparent;
  color: var(--vp-c-brand-1);
  font-size: 10.5px;
  font-weight: 600;
  cursor: pointer;
}

.rpg-fix:hover {
  background: var(--vp-c-brand-1);
  color: #fff;
}

.rpg-msg {
  margin: 0.25rem 0 0;
  font-size: 11.5px;
  line-height: 1.45;
  color: var(--vp-c-text-2);
}

.rpg-empty {
  padding: 2rem 1rem;
  border: 1px dashed var(--vp-c-divider);
  border-radius: 8px;
  color: var(--vp-c-text-2);
  text-align: center;
  font-size: 13px;
}

/* Syntax Highlighting */
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

:deep(html.dark .cm-abap-kw) {
  color: #c084fc;
}
:deep(html.dark .cm-abap-typ) {
  color: #38bdf8;
}
:deep(html.dark .cm-abap-atm) {
  color: #fb7185;
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
}
:deep(html.dark .cm-abap-meta) {
  color: #fb923c;
}
</style>
