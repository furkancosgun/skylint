---
description: "Avoid mutating or sorting tables inside loops"
---

# Do Not Mutate the Internal Table Currently Being Looped

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Performance & Database" />
  <Badge type="danger" text="#EC LOOP_MODIFY" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Avoid mutating or sorting tables inside loops.

> **ATC Finding Messages:**
> - `Do not add, delete, sort, collect, or clear rows from the table currently being looped`
> - `Avoid sorting internal tables inside loops to prevent severe performance degradation`

## Rationale

Appending, inserting, modifying, or deleting rows of the table being looped can invalidate the loop cursor. The result may be skipped rows, duplicate processing, or an endless loop. Iterate over a snapshot or collect changes in a separate table and apply them after the loop.

### Non-Compliant

```abap
LOOP AT lt_orders INTO ls_order.
  INSERT ls_order INTO lt_orders.
ENDLOOP.
```

### Compliant

```abap
LOOP AT lt_orders INTO ls_order.
  INSERT ls_order INTO lt_processed_orders.
ENDLOOP.
```

## Configuration & Thresholds

This check can be fine-tuned directly in the ATC Check Variant Editor (`CHKV`) in Eclipse ADT:

| Parameter Name | Data Type | Default Value |
|---|---|:---:|
| `CHECK_APPEND` | `Boolean` | <code>true</code> |
| `CHECK_INSERT` | `Boolean` | <code>true</code> |
| `CHECK_MODIFY` | `Boolean` | <code>true</code> |
| `CHECK_DELETE` | `Boolean` | <code>true</code> |
| `CHECK_CLEAR` | `Boolean` | <code>true</code> |
| `CHECK_SORT` | `Boolean` | <code>true</code> |
| `CHECK_SORT_ANY` | `Boolean` | <code>true</code> |
| `CHECK_COLLECT` | `Boolean` | <code>true</code> |

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC LOOP_MODIFY

" SAP CI_ prefix format:
... "#EC CI_LOOP_MODIFY
```

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_NO_MOD_LOOP_TAB`
* **Implementation File:** [zcl_skylint_no_mod_loop_tab.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_no_mod_loop_tab.clas.abap)
