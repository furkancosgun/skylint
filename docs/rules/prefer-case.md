---
description: "Use CASE instead of IF when checking multiple values"
---

# Prefer CASE over Multiple IF / ELSEIF on the Same Variable

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="danger" text="#EC PREF_CASE" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Use CASE instead of IF when checking multiple values.

> **ATC Finding Message:** `Multiple ELSEIF branches check the same variable; use CASE instead`

## Rationale

A chain of ELSEIF statements that compares the same variable to different values is harder to scan than a CASE statement. CASE groups all alternatives under one subject and makes a missing OTHERS branch visible. Use CASE for multi-value dispatch on a single expression.

### Non-Compliant

```abap
IF lv_payment_method = 'CARD'.
  process_card( ).
ELSEIF lv_payment_method = 'CASH'.
  process_cash( ).
ELSEIF lv_payment_method = 'TRANSFER'.
  process_transfer( ).
ENDIF.
```

### Compliant

```abap
CASE lv_payment_method.
  WHEN 'CARD'.
    process_card( ).
  WHEN 'CASH'.
    process_cash( ).
  WHEN 'TRANSFER'.
    process_transfer( ).
ENDCASE.
```

## Configuration & Thresholds

This check can be fine-tuned directly in the ATC Check Variant Editor (`CHKV`) in Eclipse ADT:

| Parameter Name | Data Type | Default Value |
|---|---|:---:|
| `MIN_BRANCHES` | `Integer` | <code>3</code> |

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC PREF_CASE

" SAP CI_ prefix format:
... "#EC CI_PREF_CASE
```

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_PREF_CASE`
* **Implementation File:** [zcl_skylint_pref_case.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_pref_case.clas.abap)
