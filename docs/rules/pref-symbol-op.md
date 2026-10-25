---
title: "Prefer Symbol Comparison Operators (=, <>, <, >)"
description: "Prefer Symbol Comparison Operators (=, <>, <, >) - Clean ABAP guidelines, modern SAP syntax rules, and automated ATC code inspection for SAP S/4HANA and ABAP Cloud."
keywords: "Clean ABAP, SAP ATC Check, ABAP Cloud, S/4HANA Readiness, pref-symbol-op, clean-abap"
category: "clean-abap"
ruleId: "pref-symbol-op"
---

# Prefer Symbol Comparison Operators (=, <>, <, >)

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="warning" text="QuickFix Ready" />
  <Badge type="danger" text="#EC PREF_SYMBOL_OP" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Prefer symbolic operators over textual EQ, NE, LT, GT.

> **ATC Finding Message:** `Prefer modern comparison operators (=, <>, <, >, <=, >=) over legacy keywords`

## Rationale

Text comparison operators such as EQ, NE, GT, LT, GE, and LE are legacy synonyms for the symbolic operators. Symbols are shorter, match mathematical notation, and are the Clean ABAP standard. Consistent symbols also make boolean expressions easier to scan in conditions and constructor expressions.

### Non-Compliant

```abap
IF lv_total GT 100 AND lv_status NE 'X'.
  process( ).
ENDIF.
```

### Compliant

```abap
IF lv_total > 100 AND lv_status <> 'X'.
  process( ).
ENDIF.
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
... "#EC PREF_SYMBOL_OP

" SAP CI_ prefix format:
... "#EC CI_PREF_SYMBOL_OP
```


## Related Rules

* [Prefer Calculation Assignment Operators (+=, -=, *=)](/rules/pref-calc-op) — <code>#EC PREF_CALC_OP</code>
* [Check Downport Compatibility (7.40+ Modern Constructs)](/rules/pref-downport) — <code>#EC PREF_DOWNPORT</code>
* [Prefer the Short System Field Alias SY over SYST](/rules/pref-sy) — <code>#EC PREF_SY</code>

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_PREF_SYMBOL_OP`
* **Implementation File:** [zcl_skylint_pref_symbol_op.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_pref_symbol_op.clas.abap)
