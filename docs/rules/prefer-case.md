---
description: "Use CASE instead of IF when checking multiple values"
---

# Prefer CASE over Multiple IF / ELSEIF on the Same Variable

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="danger" text="#EC PREF_CASE" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Use CASE instead of IF when checking multiple values.

> **ATC Finding Message:** `Multiple ELSEIF branches check the same variable; use CASE instead`

## Rationale

When branching on multiple values of a single variable, `CASE ... WHEN` is more readable, structured, and performant than a chain of `ELSEIF` statements.

### Non-Compliant

```abap
IF lv_type = 'A'.
  process_a( ).
ELSEIF lv_type = 'B'.
  process_b( ).
ELSEIF lv_type = 'C'.
  process_c( ).
ENDIF.
```

### Compliant

```abap
CASE lv_type.
  WHEN 'A'.
    process_a( ).
  WHEN 'B'.
    process_b( ).
  WHEN 'C'.
    process_c( ).
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
