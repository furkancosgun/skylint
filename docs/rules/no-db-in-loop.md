---
title: "Avoid Database Access Inside Loops (N+1 Query Antipattern)"
description: "Eliminate N+1 database queries in SAP ABAP. Optimize performance by pre-fetching data in bulk with FOR ALL ENTRIES or SQL Joins before processing in loops."
keywords: "ABAP Performance, N+1 Query SAP, SELECT in LOOP, Clean ABAP Database, S/4HANA SQL Optimization, ATC Check Database"
---

# Avoid Database Access Inside Loops (N+1 Query Antipattern)

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Performance & Database" />
  <Badge type="danger" text="#EC NO_DB_IN_LOOP" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Avoid database access inside loop iterations.

> **ATC Finding Message:** `Database access inside loop iteration; consider bulk operation or JOIN`

## Rationale

Executing OpenSQL queries (SELECT, INSERT, UPDATE, DELETE) inside loops causes the notorious **N+1 query antipattern**. Every iteration incurs network latency, context switches between application server and database, and query compilation overhead. In high-volume production systems, this degrades transaction throughput by orders of magnitude and causes database connection pool saturation.

**Best Practice:** Pre-fetch all necessary records in bulk before entering the loop using `FOR ALL ENTRIES` or SQL `JOIN`. Index the retrieved records in a hashed or sorted internal table and access them inside the loop in memory in $O(1)$ or $O(\log N)$ time.

### Non-Compliant

```abap
" Anti-pattern: N+1 Network roundtrips to database
LOOP AT lt_sales_orders ASSIGNING FIELD-SYMBOL(<ls_order>).
  SELECT SINGLE customer_name, country
    FROM zcustomers
    WHERE customer_id = @<ls_order>-customer_id
    INTO @DATA(ls_customer).

  <ls_order>-customer_name = ls_customer-customer_name.
ENDLOOP.
```

### Compliant

```abap
" Clean ABAP: Bulk read outside loop with in-memory lookup
IF lt_sales_orders IS NOT INITIAL.
  SELECT customer_id, customer_name, country
    FROM zcustomers
    FOR ALL ENTRIES IN @lt_sales_orders
    WHERE customer_id = @lt_sales_orders-customer_id
    INTO TABLE @DATA(lt_customers).

  SORT lt_customers BY customer_id.

  LOOP AT lt_sales_orders ASSIGNING FIELD-SYMBOL(<ls_order>).
    IF line_exists( lt_customers[ customer_id = <ls_order>-customer_id ] ).
      <ls_order>-customer_name = lt_customers[ customer_id = <ls_order>-customer_id ]-customer_name.
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

## References & Standards

* [Clean ABAP: Prefer Bulk Reads Over Reads in Loop](https://github.com/SAP/styleguides/blob/main/clean-abap/CleanABAP.md#prefer-bulk-reads-over-reads-in-loop)
* [SAP Help: Open SQL Performance Considerations](https://help.sap.com/doc/abapdocu_cp_index_htm/CLOUD/en-US/index.htm)

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_NO_DB_IN_LOOP`
* **Implementation File:** [zcl_skylint_no_db_in_loop.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_no_db_in_loop.clas.abap)
