---
title: "Avoid Database Queries Inside Loops (N+1 Query Antipattern)"
description: "Eliminate N+1 database queries in SAP ABAP and ABAP Cloud. Prevent latency spikes and database contention by pre-fetching data in bulk before loops."
keywords: "no-db-in-loop, N+1 query ABAP, Open SQL in loop, Clean ABAP database, SAP ATC performance"
category: "performance"
ruleId: "no-db-in-loop"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L1441"
---

# Avoid Database Queries Inside Loops (N+1 Query Antipattern)

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Performance & Database" />
  <Badge type="danger" text="#EC NO_DB_IN_LOOP" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L1441" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Avoid database access inside loop iterations.

> **ATC Finding Message:** `Database access inside loop iteration; consider bulk operation or JOIN`

## Rationale

Executing Open SQL queries (SELECT, INSERT, UPDATE, DELETE, or MODIFY) inside loops creates the notorious N+1 query antipattern. Every iteration forces an independent network round trip between the ABAP application server and the database engine, incurring severe latency, thread contention, and connection pool saturation. In high-throughput S/4HANA systems and ABAP Cloud environments, this degrades transaction throughput exponentially. Clean ABAP mandates pre-fetching data in bulk before entering the loop using FOR ALL ENTRIES or SQL JOINs, indexing records in hashed or sorted internal tables, and querying them in memory.

### Non-Compliant

```abap
LOOP AT lt_sales_orders INTO DATA(ls_order).
  SELECT SINGLE customer_name, country
    FROM zcustomers
    WHERE customer_id = @ls_order-customer_id
    INTO (@DATA(lv_customer_name), @DATA(lv_country)).
ENDLOOP.
```

### Compliant

```abap
IF lt_sales_orders IS NOT INITIAL.
  SELECT customer_id, customer_name, country
    FROM zcustomers
    FOR ALL ENTRIES IN @lt_sales_orders
    WHERE customer_id = @lt_sales_orders-customer_id
    INTO TABLE @DATA(lt_customers).

  SORT lt_customers BY customer_id.

  LOOP AT lt_sales_orders INTO DATA(ls_order).
    READ TABLE lt_customers INTO DATA(ls_customer)
      WITH KEY customer_id = ls_order-customer_id BINARY SEARCH.
    IF sy-subrc = 0.
      " Process customer data in memory
    ENDIF.
  ENDLOOP.
ENDIF.
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC NO_DB_IN_LOOP

" SAP CI_ prefix format:
... "#EC CI_NO_DB_IN_LOOP
```

### Detection Details

The check tracks nesting depth across `LOOP`, `DO`, and `WHILE` control blocks. Any Open SQL statement (`SELECT`, `INSERT`, `UPDATE`, `DELETE`, `MODIFY`, or `OPEN CURSOR`) detected inside an active loop body is reported with finding code `NO_DB_LOOP`.

### Optimization Strategies

- **Bulk Retrieval:** Extract all required lookup values beforehand using `SELECT ... FOR ALL ENTRIES IN @lt_keys` or an explicit SQL `JOIN`.
- **In-Memory Buffering:** Store retrieved records in a `HASHED TABLE` with a unique key ($O(1)$ lookup) or a `SORTED TABLE` with `BINARY SEARCH` ($O(\log N)$ lookup).
- **Bulk DML:** Replace individual row writes with array modifications such as `INSERT dbtab FROM TABLE @lt_records` or `MODIFY dbtab FROM TABLE @lt_records`.

Suppress legitimate single-record reads with the pseudo comment `"#EC NO_DB_IN_LOOP`.


## Related Rules

* [Avoid SELECT * and Project Columns Explicitly](/rules/no-select-star) — <code>#EC NO_SELECT_STAR</code>
* [Enforce WHERE Conditions on Database UPDATE and DELETE Statements](/rules/no-unfilt-dml) — <code>#EC NO_UNFILT_DML</code>
* [Guard FOR ALL ENTRIES Against Empty Driving Tables](/rules/no-empty-fae) — <code>#EC NO_EMPTY_FAE</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_NO_DB_IN_LOOP`
* **ABAP Implementation:** [/skyl/cl_no_db_in_loop.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_no_db_in_loop.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 1441)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L1441)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_NO_DB_IN_LOOP&title=%5BBug%5D%3A%20Issue%20in%20no-db-in-loop)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20no-db-in-loop)**
