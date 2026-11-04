---
title: "Require Explicit ORDER BY for Deterministic SELECT Queries"
description: "Ensure deterministic query results on SAP S/4HANA by enforcing explicit ORDER BY clauses in ABAP queries that limit rows."
keywords: "ORDER BY ABAP, Deterministic SQL SAP HANA, UP TO 1 ROWS bug, Clean ABAP Sorting Guidelines"
category: "performance"
ruleId: "pref-order-by"
---

# Require Explicit ORDER BY for Deterministic SELECT Queries

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Performance & Database" />
  <Badge type="danger" text="#EC PREF_ORDER_BY" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

SELECT UP TO 1 ROWS requires ORDER BY.

> **ATC Finding Message:** `SELECT UP TO 1 ROWS requires an explicit ORDER BY clause for determinism`

## Rationale

In modern relational databases, particularly SAP HANA column store, rows in a table have no intrinsic physical order. Executing queries with `SELECT SINGLE` or `SELECT ... UP TO 1 ROWS` without an explicit `ORDER BY` clause leads to **non-deterministic results**: identical queries executed multiple times can return completely different records depending on parallel query execution, index fragmentation, or cache state.

**Best Practice:** Always provide an explicit `ORDER BY` clause specifying the primary key or unique business keys when picking subset records or singular values.

### Non-Compliant

```abap
" Anti-pattern: Non-deterministic - returns random record on parallel HANA partitions
SELECT SINGLE price
  FROM zprice_history
  WHERE product_id = @lv_product_id
  INTO @DATA(lv_price).
```

### Compliant

```abap
" Clean ABAP: Explicit sorting guarantees predictable, deterministic business result
SELECT price
  FROM zprice_history
  WHERE product_id = @lv_product_id
  ORDER BY valid_from DESCENDING
  INTO @DATA(lv_price)
  UP TO 1 ROWS.
ENDSELECT." (or SELECT SINGLE with primary key)
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC PREF_ORDER_BY

" SAP CI_ prefix format:
... "#EC CI_PREF_ORDER_BY
```


## Related Rules

* [Avoid SELECT * in OpenSQL Queries (Minimize Memory & Network Overhead)](/rules/no-select-star) — <code>#EC NO_SELECT_STAR</code>
* [Prevent Empty Driver Tables in FOR ALL ENTRIES (Full Table Scan Bug)](/rules/no-empty-fae) — <code>#EC NO_EMPTY_FAE</code>
* [Avoid SELECT ... ENDSELECT Row-by-Row Cursor Loops](/rules/no-endselect) — <code>#EC NO_ENDSELECT</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_PREF_ORDER_BY`
* **Implementation File:** [#skyl#cl_pref_order_by.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_pref_order_by.clas.abap)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_PREF_ORDER_BY&title=%5BBug%5D%3A%20Issue%20in%20pref-order-by)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20pref-order-by)**
