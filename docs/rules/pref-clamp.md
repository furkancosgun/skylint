---
title: "Prefer nmin/nmax or clamp Expressions over Manual IF Clamping"
description: "Prefer built-in nmin, nmax, or clamp functions over manual range checking IF statements in ABAP."
keywords: "ABAP clamp, nmin nmax ABAP, manual clamp, Clean ABAP expressions"
category: "clean-abap"
ruleId: "pref-clamp"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L5428"
---

# Prefer nmin/nmax or clamp Expressions over Manual IF Clamping

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="warning" text="QuickFix Ready" />
  <Badge type="danger" text="#EC PREF_CLAMP" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L5428" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Prefer nmin/nmax over manual IF clamp.

> **ATC Finding Message:** `Manual range clamping detected; consider using nmin( ) and nmax( )`

## Rationale

Manually clamping a variable between lower and upper bounds using IF/ELSEIF statements is verbose and imperative. Modern ABAP provides built-in functions like nmin( ) and nmax( ) or clamp( ) that express range containment concisely and without branch complexity.

### Non-Compliant

```abap
IF lv < lo.
  lv = lo.
ELSEIF lv > hi.
  lv = hi.
ENDIF.
```

### Compliant

```abap
lv = nmin( val1 = hi
           val2 = nmax( val1 = lo
                        val2 = lv ) ).
```

## Automated QuickFix

This rule provides an **automated QuickFix** directly in Eclipse ABAP Development Tools (ADT):
1. Position the cursor on the flagged statement.
2. Press <kbd>Ctrl</kbd> + <kbd>1</kbd> (Quick Assist).
3. Select the automated refactoring to apply the clean syntax immediately.

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC PREF_CLAMP

" SAP CI_ prefix format:
... "#EC CI_PREF_CLAMP
```


## Related Rules

* [Prefer BETWEEN for Inclusive Range Checks](/rules/pref-between) — <code>#EC PREF_BETWEEN</code>
* [Prefer COND #( ) Expression over IF/ELSEIF/ELSE](/rules/pref-cond) — <code>#EC PREF_COND</code>
* [Prefer SWITCH #( ) Expression over CASE Statement](/rules/pref-switch) — <code>#EC PREF_SWITCH</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_PREF_CLAMP`
* **ABAP Implementation:** [/skyl/cl_pref_clamp.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_pref_clamp.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 5428)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L5428)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_PREF_CLAMP&title=%5BBug%5D%3A%20Issue%20in%20pref-clamp)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20pref-clamp)**
