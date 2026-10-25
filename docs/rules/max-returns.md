---
description: "Limit number of RETURN statements (PLR0911)"
---

# Limit Number of RETURN Statements in Method

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Metrics & Complexity Limits" />
  <Badge type="danger" text="#EC MAX_RETURNS" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Limit number of RETURN statements (PLR0911).

> **ATC Finding Message:** `Method has too many RETURN statements; consider refactoring`

## Rationale

Methods with many return statements are difficult to understand, trace, and test comprehensively. Functions should have a small number of exit points; split complex conditional returns into helper methods or simplify control flow.

### Non-Compliant

```abap
METHOD process.
  IF a = 1. RETURN. ENDIF.
  IF b = 2. RETURN. ENDIF.
  " ... 5 more returns ...
ENDMETHOD.
```

### Compliant

```abap
METHOD process.
  IF is_invalid_input( ).
    RETURN.
  ENDIF.
  execute_logic( ).
ENDMETHOD.
```

## Configuration & Thresholds

This check can be fine-tuned directly in the ATC Check Variant Editor (`CHKV`) in Eclipse ADT:

| Parameter Name | Data Type | Default Value |
|---|---|:---:|
| `MAX_RETURNS` | `Integer` | <code>6</code> |

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC MAX_RETURNS

" SAP CI_ prefix format:
... "#EC CI_MAX_RETURNS
```

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_MAX_RETURNS`
* **Implementation File:** [zcl_skylint_max_returns.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_max_returns.clas.abap)
