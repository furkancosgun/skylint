---
title: "Prefer Short System Field Structure Alias SY Over Legacy SYST"
description: "Standardize ABAP system variable access using the concise sy- prefix instead of legacy syst- in ABAP Cloud."
keywords: "pref-sy, sy-subrc, sy-uname, SYST, Clean ABAP"
category: "clean-abap"
ruleId: "pref-sy"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L3749"
---

# Prefer Short System Field Structure Alias SY Over Legacy SYST

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="warning" text="QuickFix Ready" />
  <Badge type="danger" text="#EC PREF_SY" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L3749" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Prefer the short system field alias SY over SYST.

> **ATC Finding Message:** `Use sy- instead of syst- for system fields`

## Rationale

The runtime structures SY and SYST refer to the exact same underlying ABAP system fields structure (SYST). Mixing both aliases introduces unnecessary variation, impairs automated search across codebases, and departs from modern ABAP conventions where sy- is universally preferred. Standardizing on sy- keeps system variable access concise and idiomatic. Skylint checks for references to the SYST structure and reports PREF_SY alongside the USE_SY quickfix.

### Non-Compliant

```abap
lv_current_user = syst-uname.
```

### Compliant

```abap
lv_current_user = sy-uname.
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
... "#EC PREF_SY

" SAP CI_ prefix format:
... "#EC CI_PREF_SY
```

## Detection and Quickfix Details

Statements containing tokens that resolve to compiler reference `\DA:SYST\*` (such as `syst-subrc`, `syst-uname`, `syst-datum`) are identified. The `USE_SY` quickfix substitutes `syst-` with `sy-` automatically.

Suppress findings using pseudo comment `"#EC PREF_SY`.


## Related Rules

* [Avoid Direct Modification of System Fields (sy-*)](/rules/no-sy-modify) — <code>#EC NO_SY_MODIFY</code>
* [Prefer Calculation Assignment Operators (+=, -=, *=, /=)](/rules/pref-calc-op) — <code>#EC PREF_CALC_OP</code>
* [Replace Textual Comparison Operators (EQ, NE, GT) with Symbols](/rules/pref-symbol-op) — <code>#EC PREF_SYMBOL_OP</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_PREF_SY`
* **ABAP Implementation:** [/skyl/cl_pref_sy.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_pref_sy.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 3749)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L3749)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_PREF_SY&title=%5BBug%5D%3A%20Issue%20in%20pref-sy)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20pref-sy)**
