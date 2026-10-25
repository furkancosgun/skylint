---
title: "Prefer the Short System Field Alias SY over SYST"
description: "Prefer the Short System Field Alias SY over SYST - Clean ABAP guidelines, modern SAP syntax rules, and automated ATC code inspection for SAP S/4HANA and ABAP Cloud."
keywords: "Clean ABAP, SAP ATC Check, ABAP Cloud, S/4HANA Readiness, pref-sy, clean-abap"
category: "clean-abap"
ruleId: "pref-sy"
---

# Prefer the Short System Field Alias SY over SYST

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="warning" text="QuickFix Ready" />
  <Badge type="danger" text="#EC PREF_SY" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Prefer the short system field alias SY over SYST.

> **ATC Finding Message:** `Use sy- instead of syst- for system fields`

## Rationale

SYST and SY address the same system structure, so mixing both aliases makes code look inconsistent and complicates searching. SY is the conventional short form used throughout Clean ABAP. Use sy- consistently for system field access.

### Non-Compliant

```abap
lv_user = syst-uname.
```

### Compliant

```abap
lv_user = sy-uname.
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


## Related Rules

* [Avoid Directly Modifying System Fields (sy-subrc, sy-tabix)](/rules/no-sy-modify) — <code>#EC NO_SY_MODIFY</code>
* [Prefer Calculation Assignment Operators (+=, -=, *=)](/rules/pref-calc-op) — <code>#EC PREF_CALC_OP</code>
* [Prefer Symbol Comparison Operators (=, <>, <, >)](/rules/pref-symbol-op) — <code>#EC PREF_SYMBOL_OP</code>

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_PREF_SY`
* **Implementation File:** [zcl_skylint_pref_sy.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_pref_sy.clas.abap)
