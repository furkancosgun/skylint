---
title: "Do Not Mutate the Internal Table Currently Being Looped (Iterator Invalidation)"
description: "Prevent internal table iterator corruption in ABAP by avoiding APPEND, INSERT, DELETE, or SORT on tables currently being traversed."
keywords: "MODIFY in LOOP ABAP, SORT in LOOP Bug, Iterator Invalidation SAP, Clean ABAP Loop Integrity"
---

# Do Not Mutate the Internal Table Currently Being Looped (Iterator Invalidation)

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Performance & Database" />
  <Badge type="danger" text="#EC NO_MOD_LOOP_TAB" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Avoid mutating or sorting tables inside loops.

> **ATC Finding Messages:**
> - `Do not add, delete, sort, collect, or clear rows from the table currently being looped`
> - `Avoid sorting internal tables inside loops to prevent severe performance degradation`

## Rationale

Modifying, deleting, inserting, or sorting the internal table currently being traversed inside a `LOOP AT itab` block invalidates the loop iterator. Sorting during a loop breaks binary search indexes and causes infinite loops or skipped rows. Deleting rows alters `sy-tabix` dynamically, leading to silent data corruption.

**Best Practice:** To update row values, use field-symbols (`ASSIGNING FIELD-SYMBOL(<row>)`) which mutates memory directly in-place without altering table layout. For filtering or structural reshaping, use modern constructor expressions (`FILTER #( ... )`) or build a new secondary table.

### Non-Compliant

```abap
" Anti-pattern: Modifying and sorting inside loop invalidates table indexes
LOOP AT lt_items INTO ls_item.
  ls_item-price = ls_item-price * 1.1.
  MODIFY lt_items FROM ls_item.
  SORT lt_items BY item_id.
ENDLOOP.
```

### Compliant

```abap
" Clean ABAP: Direct in-place mutation via field symbol without table re-indexing
LOOP AT lt_items ASSIGNING FIELD-SYMBOL(<ls_item>).
  <ls_item>-price = <ls_item>-price * 1.1.
ENDLOOP.
```

## Configuration & Thresholds

This check can be fine-tuned directly in the ATC Check Variant Editor (`CHKV`) in Eclipse ADT:

| Parameter Name | Data Type | Default Value | Description & Guidance |
|---|---|:---:|---|
| `CHECK_APPEND` | `Boolean` | <code>true</code> | Detect APPEND statements targeting the loop table |
| `CHECK_INSERT` | `Boolean` | <code>true</code> | Detect INSERT statements targeting the loop table |
| `CHECK_MODIFY` | `Boolean` | <code>true</code> | Detect MODIFY statements targeting the loop table |
| `CHECK_DELETE` | `Boolean` | <code>true</code> | Detect DELETE statements targeting the loop table |
| `CHECK_CLEAR` | `Boolean` | <code>true</code> | Detect CLEAR or FREE statements targeting the loop table |
| `CHECK_SORT` | `Boolean` | <code>true</code> | Detect SORT statements targeting the loop table |
| `CHECK_SORT_ANY` | `Boolean` | <code>true</code> | Detect SORT statements on any table inside a loop |
| `CHECK_COLLECT` | `Boolean` | <code>true</code> | Detect COLLECT statements targeting the loop table |

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC NO_MOD_LOOP_TAB

" SAP CI_ prefix format:
... "#EC CI_NO_MOD_LOOP_TAB
```

## References & Standards

* [Clean ABAP: Do Not Change the Table You Are Looping](https://github.com/SAP/styleguides/blob/main/clean-abap/CleanABAP.md#do-not-change-the-table-you-are-looping)

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_NO_MOD_LOOP_TAB`
* **Implementation File:** [zcl_skylint_no_mod_loop_tab.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_no_mod_loop_tab.clas.abap)
