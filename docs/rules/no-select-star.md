---
title: "Avoid SELECT * in OpenSQL Queries (Minimize Memory & Network Overhead)"
description: "Optimize SAP HANA column store performance in ABAP by avoiding SELECT * and explicitly declaring required columns in OpenSQL queries."
keywords: "Avoid SELECT star ABAP, SAP HANA Column Store Optimization, Clean ABAP Query Guidelines, Memory Footprint Reduction SAP"
category: "performance"
ruleId: "no-select-star"
---

# Avoid SELECT * in OpenSQL Queries (Minimize Memory & Network Overhead)

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Performance & Database" />
  <Badge type="danger" text="#EC NO_SELECT_STAR" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Avoid SELECT * (specify columns explicitly).

> **ATC Finding Message:** `Avoid SELECT *; specify required columns explicitly`

## Rationale

Using `SELECT *` forces the SAP database interface and database engine to retrieve and transfer every single column defined on the database table, including heavy text fields, binary blobs, and irrelevant business attributes. In modern columnar databases like SAP HANA, fetching unneeded columns defeats column-store compression, inflates application server heap usage, and causes unnecessary memory allocations.

**Best Practice:** Explicitly project only the exact fields required by your business process into a typed structure or inline table expression.

### Non-Compliant

```abap
" Anti-pattern: Pulls all 80+ fields of MARA including binary blobs and administrative logs
SELECT *
  FROM mara
  WHERE matnr = @lv_matnr
  INTO @DATA(ls_material).
```

### Compliant

```abap
" Clean ABAP: Project only required business fields
SELECT matnr, mtart, meins
  FROM mara
  WHERE matnr = @lv_matnr
  INTO @DATA(ls_material).
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC NO_SELECT_STAR

" SAP CI_ prefix format:
... "#EC CI_NO_SELECT_STAR
```


## Related Rules

* [Avoid Database Access Inside Loops (N+1 Query Antipattern)](/rules/no-db-in-loop) — <code>#EC NO_DB_IN_LOOP</code>
* [Avoid SELECT ... ENDSELECT Row-by-Row Cursor Loops](/rules/no-endselect) — <code>#EC NO_ENDSELECT</code>
* [Require Explicit ORDER BY for Deterministic SELECT Queries](/rules/pref-order-by) — <code>#EC PREF_ORDER_BY</code>

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_NO_SELECT_STAR`
* **Implementation File:** [zcl_skylint_no_select_star.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_no_select_star.clas.abap)
