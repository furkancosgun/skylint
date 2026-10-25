---
title: "Avoid String Concatenation Inside Loops (Quadratic Memory Allocation)"
description: "Prevent quadratic memory allocation in ABAP string loops by collecting fragments in string tables and using concat_lines_of."
keywords: "String concatenation in loop ABAP, Quadratic Memory Allocation SAP, concat_lines_of Clean ABAP, String Buffer Performance"
---

# Avoid String Concatenation Inside Loops (Quadratic Memory Allocation)

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

Performing string concatenation (`lv_result = lv_result && lv_chunk` or `CONCATENATE`) inside a loop causes **quadratic memory allocation ($O(N^2)$)**. In each iteration, ABAP allocates a new heap memory buffer, copies the entire existing accumulator plus the new chunk, and marks the old buffer for garbage collection. As the iteration count increases, execution time and memory usage skyrocket.

**Best Practice:** Collect string fragments into an internal table of strings (`string_table`) and join them in a single native operation using `concat_lines_of( it_strings, sep )`.

### Non-Compliant

```abap
" Anti-pattern: Re-allocates and copies full string buffer on every iteration (O(N^2))
DATA lv_csv TYPE string.
LOOP AT lt_records INTO ls_record.
  lv_csv = lv_csv && ls_record-id && ',' && ls_record-name && cl_abap_char_utilities=>newline.
ENDLOOP.
```

### Compliant

```abap
" Clean ABAP: Collect lines and join in a single lightning-fast operation (O(N))
DATA lt_lines TYPE string_table.
LOOP AT lt_records INTO ls_record.
  INSERT |{ ls_record-id },{ ls_record-name }| INTO TABLE lt_lines.
ENDLOOP.

DATA(lv_csv) = concat_lines_of( table = lt_lines sep = cl_abap_char_utilities=>newline ).
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
