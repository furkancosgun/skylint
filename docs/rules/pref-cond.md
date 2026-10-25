---
title: "Prefer COND #( ) Expression over IF/ELSEIF/ELSE"
description: "Prefer COND #( ) Expression over IF/ELSEIF/ELSE - Clean ABAP guidelines, modern SAP syntax rules, and automated ATC code inspection for SAP S/4HANA and ABAP Cloud."
keywords: "Clean ABAP, SAP ATC Check, ABAP Cloud, S/4HANA Readiness, pref-cond, clean-abap"
---

# Prefer COND #( ) Expression over IF/ELSEIF/ELSE

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="warning" text="QuickFix Ready" />
  <Badge type="danger" text="#EC PREF_COND" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Prefer COND #( ) expression over IF/ELSEIF/ELSE statement.

> **ATC Finding Message:** `Prefer COND #( ) constructor expression over IF/ELSEIF`

## Rationale

An IF/ELSEIF chain that only assigns different values to the same variable duplicates the assignment target and spreads one decision over many lines. COND #( ) turns the whole mapping into a single expression, so the target is assigned exactly once and cannot be left uninitialized. It also composes with assignments and method calls. Keep IF when branches perform multiple statements or side effects.

### Non-Compliant

```abap
IF lv_score >= 90.
  lv_grade = 'A'.
ELSEIF lv_score >= 80.
  lv_grade = 'B'.
ELSE.
  lv_grade = 'C'.
ENDIF.
```

### Compliant

```abap
lv_grade = COND string(
  WHEN lv_score >= 90 THEN 'A'
  WHEN lv_score >= 80 THEN 'B'
  ELSE 'C' ).
```

## Automated QuickFix

This rule provides an **automated QuickFix** directly in Eclipse ABAP Development Tools (ADT):
1. Position the cursor on the flagged statement.
2. Press <kbd>Ctrl</kbd> + <kbd>1</kbd> (Quick Assist).
3. Select the automated refactoring to apply the clean syntax immediately.

## Configuration & Thresholds

This check can be fine-tuned directly in the ATC Check Variant Editor (`CHKV`) in Eclipse ADT:

| Parameter Name | Data Type | Default Value | Description & Guidance |
|---|---|:---:|---|
| `REQUIRE_ELSE` | `Boolean` | <code>false</code> | Require explicit ELSE branch in COND #( ... ) to guarantee total coverage |

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC PREF_COND

" SAP CI_ prefix format:
... "#EC CI_PREF_COND
```

## References & Standards

* [Official SAP Clean ABAP Style Guide](https://github.com/SAP/styleguides/blob/main/clean-abap/CleanABAP.md)
* [SAP ABAP Keyword Documentation](https://help.sap.com/doc/abapdocu_cp_index_htm/CLOUD/en-US/index.htm)

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_PREF_COND`
* **Implementation File:** [zcl_skylint_pref_cond.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_pref_cond.clas.abap)
