---
description: "Prefer early return or continue over nested IF blocks"
---

# Prefer Early Return to Reduce Nesting (Guard Clauses)

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="danger" text="#EC EARLY_RETURN" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Prefer early return or continue over nested IF blocks.

> **ATC Finding Messages:**
> - `Invert IF condition and use RETURN to reduce nesting in method`
> - `Invert IF condition and use CONTINUE to reduce nesting in loop`

## Rationale

Wrapping the whole method body in IF is_valid( ) creates unnecessary nesting and pushes the happy path to the right. Guard clauses reject invalid input at the top and leave the main logic flat and easy to read. Return early for preconditions and error cases instead of indenting the successful path.

### Non-Compliant

```abap
METHOD process_order.
  IF is_valid( ).
    execute_order( ).
    log_order( ).
  ENDIF.
ENDMETHOD.
```

### Compliant

```abap
METHOD process_order.
  IF NOT is_valid( ).
    RETURN.
  ENDIF.
  execute_order( ).
  log_order( ).
ENDMETHOD.
```

## Configuration & Thresholds

This check can be fine-tuned directly in the ATC Check Variant Editor (`CHKV`) in Eclipse ADT:

| Parameter Name | Data Type | Default Value |
|---|---|:---:|
| `CHECK_METHOD_RETURN` | `Boolean` | <code>true</code> |
| `CHECK_LOOP_CONTINUE` | `Boolean` | <code>true</code> |

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC EARLY_RETURN

" SAP CI_ prefix format:
... "#EC CI_EARLY_RETURN
```

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_PREF_EARLY_RET`
* **Implementation File:** [zcl_skylint_pref_early_ret.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_pref_early_ret.clas.abap)
