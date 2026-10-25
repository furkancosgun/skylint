---
description: "Avoid string concatenation inside loops"
---

# Avoid String Concatenation Inside Loops

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Performance & Database" />
  <Badge type="danger" text="#EC NO_CONCAT_LOOP" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Avoid string concatenation inside loops.

> **ATC Finding Message:** `Accumulate parts in a table and concatenate once`

## Rationale

Repeatedly appending to the same string inside a loop copies the accumulated result on every iteration, which turns a linear operation into a quadratic one for large tables. Collect the parts in a string table and join them once, or use a suitable aggregation. Keep the concatenation outside the loop whenever possible.

### Non-Compliant

```abap
LOOP AT lt_names INTO lv_name.
  lv_result = lv_result && lv_name.
ENDLOOP.
```

### Compliant

```abap
LOOP AT lt_names INTO lv_name.
  APPEND lv_name TO lt_parts.
ENDLOOP.
lv_result = concat_lines_of( table = lt_parts ).
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC NO_CONCAT_LOOP

" SAP CI_ prefix format:
... "#EC CI_NO_CONCAT_LOOP
```

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_NO_CONCAT_LOOP`
* **Implementation File:** [zcl_skylint_no_concat_loop.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_no_concat_loop.clas.abap)
