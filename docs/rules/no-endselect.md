---
description: "Avoid SELECT ... ENDSELECT Loops"
---

# Avoid SELECT ... ENDSELECT Row-by-Row Cursor Loops

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Performance & Database" />
  <Badge type="danger" text="#EC ENDSELECT" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Avoid SELECT ... ENDSELECT Loops.

> **ATC Finding Message:** `Avoid SELECT ... ENDSELECT loop; use array fetch INTO TABLE`

## Rationale

A SELECT ... ENDSELECT loop streams individual rows across the network and holds a database cursor open, multiplying round-trips and degrading database throughput. Fetch rows into an internal table with INTO TABLE in an array fetch, unless explicitly using PACKAGE SIZE for bounded memory chunking.

### Non-Compliant

```abap
SELECT customer_id FROM /dmo/customer INTO @DATA(lv_id).
  process( lv_id ).
ENDSELECT.
```

### Compliant

```abap
SELECT customer_id FROM /dmo/customer INTO TABLE @DATA(lt_ids).
LOOP AT lt_ids INTO DATA(lv_id).
  process( lv_id ).
ENDLOOP.
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC ENDSELECT

" SAP CI_ prefix format:
... "#EC CI_ENDSELECT
```

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_NO_ENDSELECT`
* **Implementation File:** [zcl_skylint_no_endselect.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_no_endselect.clas.abap)
