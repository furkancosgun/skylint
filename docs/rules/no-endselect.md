---
title: "Avoid SELECT ... ENDSELECT Row-by-Row Cursor Loops"
description: "Eliminate database cursor leaks and slow row-by-row fetching by replacing SELECT ... ENDSELECT with array fetches into internal tables."
keywords: "SELECT ENDSELECT ABAP, Database Cursor Leak SAP, Array Fetch OpenSQL, Clean ABAP Database Best Practices"
---

# Avoid SELECT ... ENDSELECT Row-by-Row Cursor Loops

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Performance & Database" />
  <Badge type="danger" text="#EC NO_ENDSELECT" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Avoid SELECT ... ENDSELECT Loops.

> **ATC Finding Message:** `Avoid SELECT ... ENDSELECT loop; use array fetch INTO TABLE`

## Rationale

The `SELECT ... ENDSELECT` construct establishes a persistent server-side database cursor and streams rows individually back to the application server one by one. This causes massive network chatter, holds open database transaction locks, and blocks database connection pool resources. If long-running logic or exception dumps occur inside the loop, the database cursor may leak.

**Best Practice:** Use package fetches or array array operations (`SELECT ... INTO TABLE`) to retrieve records in bulk, utilizing fast block-based network transfers.

### Non-Compliant

```abap
" Anti-pattern: Holds DB cursor open across every row iteration
SELECT order_id, order_date, status
  FROM zorders
  WHERE status = 'OPEN'
  INTO @DATA(ls_order).

  process_order( ls_order ).
ENDSELECT.
```

### Compliant

```abap
" Clean ABAP: Bulk array fetch into memory, cursor closed immediately
SELECT order_id, order_date, status
  FROM zorders
  WHERE status = 'OPEN'
  INTO TABLE @DATA(lt_orders).

LOOP AT lt_orders INTO DATA(ls_order).
  process_order( ls_order ).
ENDLOOP.
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC NO_ENDSELECT

" SAP CI_ prefix format:
... "#EC CI_NO_ENDSELECT
```

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_NO_ENDSELECT`
* **Implementation File:** [zcl_skylint_no_endselect.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_no_endselect.clas.abap)
