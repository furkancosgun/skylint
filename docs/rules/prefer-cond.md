---
description: "Prefer COND #( ) expression over IF/ELSEIF/ELSE statement"
---

# Prefer COND #( ) Expression over IF/ELSEIF/ELSE

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="warning" text="⚡ QuickFix Ready" />
  <Badge type="danger" text="#EC PREF_COND" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Prefer COND #( ) expression over IF/ELSEIF/ELSE statement.

> **ATC Finding Message:** `Prefer COND #( ) constructor expression over IF/ELSEIF`

## Rationale

IF/ELSEIF/ELSE statements that merely assign values to a single variable based on conditional checks can be written much more concisely and expressively using modern ABAP COND #( ) constructor expressions.

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
lv_grade = COND #( 
  WHEN lv_score >= 90 THEN 'A'
  WHEN lv_score >= 80 THEN 'B'
  ELSE 'C' ).
```

## Transformation

```diff
- IF lv_score >= 90.
-   lv_grade = 'A'.
- ELSEIF lv_score >= 80.
-   lv_grade = 'B'.
- ELSE.
-   lv_grade = 'C'.
- ENDIF.
+ lv_grade = COND #( 
+   WHEN lv_score >= 90 THEN 'A'
+   WHEN lv_score >= 80 THEN 'B'
+   ELSE 'C' ).
```

## Automated QuickFix

This rule provides an **automated QuickFix** directly in Eclipse ABAP Development Tools (ADT):
1. Position the cursor on the flagged statement.
2. Press <kbd>Ctrl</kbd> + <kbd>1</kbd> (Quick Assist).
3. Select the automated refactoring to apply the clean syntax immediately.

## Configuration & Thresholds

This check can be fine-tuned directly in the ATC Check Variant Editor (`CHKV`) in Eclipse ADT:

| Parameter Name | Data Type | Default Value |
|---|---|:---:|
| `REQUIRE_ELSE` | `Boolean` | <code>false</code> |

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC PREF_COND

" SAP CI_ prefix format:
... "#EC CI_PREF_COND
```

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_PREF_COND`
* **Implementation File:** [zcl_skylint_pref_cond.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_pref_cond.clas.abap)
