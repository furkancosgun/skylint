---
title: "Avoid CROSS JOIN in ABAP SQL Queries"
description: "Avoid Cartesian products in SAP ABAP SQL by prohibiting CROSS JOIN queries."
keywords: "ABAP CROSS JOIN, Cartesian Product ABAP, SQL Join Optimization, Database Performance"
category: "performance"
ruleId: "no-cross-join"
---

# Avoid CROSS JOIN in ABAP SQL Queries

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Performance & Database" />
  <Badge type="danger" text="#EC NO_CROSS_JOIN" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Avoid CROSS JOIN in ABAP SQL queries.

> **ATC Finding Message:** `Avoid CROSS JOIN; cartesian products cause heavy database and memory load`

## Rationale

A `CROSS JOIN` produces the cartesian product of two tables (M * N records) without join conditions. On non-trivial tables, this leads to exponential row proliferation, database memory exhaustion, and query timeouts.

**Standard:** Always connect joined tables with explicit `ON` conditions using `INNER JOIN` or `LEFT OUTER JOIN`.

### Non-Compliant

```abap
" Cartesian product: M * N rows
SELECT FROM t000 CROSS JOIN t001 FIELDS t000~mandt INTO TABLE @DATA(lt_data).
```

### Compliant

```abap
" Explicit ON join condition
SELECT FROM t000
  INNER JOIN t001 ON t000~mandt = t001~mandt
  FIELDS t000~mandt
  INTO TABLE @DATA(lt_data).
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC NO_CROSS_JOIN

" SAP CI_ prefix format:
... "#EC CI_NO_CROSS_JOIN
```


## Related Rules

* [Avoid Unfiltered SELECT on Database Tables (Full Table Scan Prevention)](/rules/no-full-scan-sel) — <code>#EC NO_FULL_SCAN_SELECT</code>
* [Prefer an Explicit JOIN Type](/rules/pref-join-type) — <code>#EC PREF_JOIN_TYPE</code>
* [Prefer Strict SQL Host Variable Escaping](/rules/pref-strict-sql) — <code>#EC PREF_STRICT_SQL</code>

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_NO_CROSS_JOIN`
* **Implementation File:** [zcl_skylint_no_cross_join.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_no_cross_join.clas.abap)
