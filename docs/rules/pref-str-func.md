---
title: "Prefer Built-in String Functions over SEARCH/SHIFT"
description: "Prefer Built-in String Functions over SEARCH/SHIFT - Clean ABAP guidelines, modern SAP syntax rules, and automated ATC code inspection for SAP S/4HANA and ABAP Cloud."
keywords: "Clean ABAP, SAP ATC Check, ABAP Cloud, S/4HANA Readiness, pref-str-func, clean-abap"
---

# Prefer Built-in String Functions over SEARCH/SHIFT

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="warning" text="QuickFix Ready" />
  <Badge type="danger" text="#EC PREF_STR_FUNC" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Detect obsolete string statements; prefer built-in functions.

> **ATC Finding Messages:**
> - `Use modern built-in string function condense( ... ) instead`
> - `Use modern string functions to_upper() or to_lower() instead`
> - `Use modern string function shift_left( ) or shift_right( ) instead`
> - `SEARCH statement is obsolete; prefer find( ) or contains( )`
> - `OVERLAY statement is obsolete; prefer string functions or templates`
> - `Obsolete REPLACE statement; prefer replace( ) function`
> - `Use strlen( ... ) instead of DESCRIBE FIELD ... LENGTH`

## Rationale

Statements such as CONDENSE, TRANSLATE, SHIFT, and SEARCH mutate a variable and cannot be used inside expressions. Built-in functions return values, compose cleanly, and make the intended transformation explicit. Use functions such as to_upper, to_lower, find, substring, and shift_left instead.

### Non-Compliant

```abap
SHIFT lv_code LEFT BY 2 PLACES.
TRANSLATE lv_country TO UPPER CASE.
```

### Compliant

```abap
lv_code = shift_left( val = lv_code places = 2 ).
lv_country = to_upper( lv_country ).
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
| `CHECK_CONDENSE` | `Boolean` | <code>true</code> | Suggest condense( ) function over CONDENSE statement |
| `CHECK_TRANSLATE` | `Boolean` | <code>true</code> | Suggest to_upper( ) / to_lower( ) over TRANSLATE statement |
| `CHECK_SHIFT` | `Boolean` | <code>true</code> | Suggest substring / shift functions over SHIFT statement |
| `CHECK_SEARCH` | `Boolean` | <code>true</code> | Suggest find( ) function over SEARCH statement |
| `CHECK_OVERLAY` | `Boolean` | <code>true</code> | Suggest string templates over OVERLAY statement |
| `CHECK_REPLACE` | `Boolean` | <code>true</code> | Suggest replace( ) function over REPLACE statement |
| `CHECK_DESCRIBE` | `Boolean` | <code>true</code> | Suggest describe_by_data( ) over DESCRIBE FIELD |

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC PREF_STR_FUNC

" SAP CI_ prefix format:
... "#EC CI_PREF_STR_FUNC
```

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_PREF_STR_FUNC`
* **Implementation File:** [zcl_skylint_pref_str_func.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_pref_str_func.clas.abap)
