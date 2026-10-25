---
title: "Prefer Calculation Assignment Operators (+=, -=, *=)"
description: "Prefer Calculation Assignment Operators (+=, -=, *=) - Clean ABAP guidelines, modern SAP syntax rules, and automated ATC code inspection for SAP S/4HANA and ABAP Cloud."
keywords: "Clean ABAP, SAP ATC Check, ABAP Cloud, S/4HANA Readiness, pref-calc-op, clean-abap"
category: "clean-abap"
ruleId: "pref-calc-op"
---

# Prefer Calculation Assignment Operators (+=, -=, *=)

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="warning" text="QuickFix Ready" />
  <Badge type="danger" text="#EC PREF_CALC_OP" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Prefer calculation assignment operators (+=, -=, *=, /=).

> **ATC Finding Message:** `Use calculation assignment operator (+=, -=) or ADD statement replacement`

## Rationale

Assignments such as lv_total = lv_total + 1 repeat the target variable and make the update harder to scan. Compound operators +=, -=, and *= express the change directly and avoid duplicating the left-hand side. Use them for simple arithmetic updates where the target is both source and result.

### Non-Compliant

```abap
lv_stock = lv_stock - 1.
lv_price = lv_price * 1.19.
```

### Compliant

```abap
lv_stock -= 1.
lv_price *= 1.19.
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
... "#EC PREF_CALC_OP

" SAP CI_ prefix format:
... "#EC CI_PREF_CALC_OP
```


## Related Rules

* [Prefer Symbol Comparison Operators (=, <>, <, >)](/rules/pref-symbol-op) — <code>#EC PREF_SYMBOL_OP</code>
* [Avoid Obsolete Arithmetic and Assignment Statements](/rules/no-obs-arith) — <code>#EC NO_OBS_ARITH</code>
* [Check Downport Compatibility (7.40+ Modern Constructs)](/rules/pref-downport) — <code>#EC PREF_DOWNPORT</code>

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_PREF_CALC_OP`
* **Implementation File:** [zcl_skylint_pref_calc_op.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_pref_calc_op.clas.abap)
