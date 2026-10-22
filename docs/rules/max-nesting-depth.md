---
description: "Nesting Depth Limit (excessive control block nesting)"
---

# Limit Control Flow Nesting Depth

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Metrics & Complexity Limits" />
  <Badge type="danger" text="#EC NESTING" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Nesting Depth Limit (excessive control block nesting).

> **ATC Finding Message:** `Control block nesting depth exceeds`

## Rationale

Every nested IF, LOOP, or TRY level adds a condition that the reader must hold in mind, producing the arrow anti-pattern. Deep nesting also increases cyclomatic complexity and makes branch coverage expensive. Flatten the code with guard clauses, early returns, and extracted methods.

### Non-Compliant

```abap
IF is_authorized( ).
  IF is_valid( ).
    IF has_stock( ).
      IF is_released( ).
        execute( ).
      ENDIF.
    ENDIF.
  ENDIF.
ENDIF.
```

### Compliant

```abap
IF NOT is_authorized( ) OR NOT is_valid( )
   OR NOT has_stock( ) OR NOT is_released( ).
  RETURN.
ENDIF.
execute( ).
```

## Configuration & Thresholds

This check can be fine-tuned directly in the ATC Check Variant Editor (`CHKV`) in Eclipse ADT:

| Parameter Name | Data Type | Default Value |
|---|---|:---:|
| `MAX_DEPTH` | `Integer` | <code>3</code> |

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC NESTING

" SAP CI_ prefix format:
... "#EC CI_NESTING
```

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_MAX_NESTING`
* **Implementation File:** [zcl_skylint_max_nesting.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_max_nesting.clas.abap)
