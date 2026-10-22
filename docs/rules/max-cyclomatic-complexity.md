---
description: "Cyclomatic Complexity Threshold"
---

# Limit Cyclomatic Complexity

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Metrics & Complexity Limits" />
  <Badge type="danger" text="#EC CYCLO_COMP" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Cyclomatic Complexity Threshold.

> **ATC Finding Message:** `Procedure cyclomatic complexity exceeds threshold`

## Rationale

Cyclomatic complexity counts the independent decision paths through a method, so a high value means many branches need separate tests. Such methods are hard to understand and easy to break when one condition changes. Split the decisions into cohesive helper methods or strategy objects.

### Non-Compliant

```abap
METHOD check_order.
  IF is_blocked( ).
    RETURN.
  ENDIF.
  IF has_no_stock( ).
    RETURN.
  ENDIF.
  IF is_over_limit( ).
    RETURN.
  ENDIF.
  IF needs_approval( ).
    approve( ).
  ENDIF.
  IF is_priority( ).
    expedite( ).
  ENDIF.
  release( ).
ENDMETHOD.
```

### Compliant

```abap
METHOD check_order.
  validate_order( ).
  approve_order( ).
  release_order( ).
ENDMETHOD.
```

## Configuration & Thresholds

This check can be fine-tuned directly in the ATC Check Variant Editor (`CHKV`) in Eclipse ADT:

| Parameter Name | Data Type | Default Value |
|---|---|:---:|
| `MAX_COMPLEXITY` | `Integer` | <code>5</code> |

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC CYCLO_COMP

" SAP CI_ prefix format:
... "#EC CI_CYCLO_COMP
```

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_MAX_CYCLO_COMP`
* **Implementation File:** [zcl_skylint_max_cyclo_comp.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_max_cyclo_comp.clas.abap)
