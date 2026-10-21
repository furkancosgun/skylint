---
description: "Avoid database access inside loop iterations"
---

# Avoid Database Access Inside Loops

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="tip" text="Performance & Database" />
  <Badge type="danger" text="#EC DB_IN_LOOP" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Avoid database access inside loop iterations.

> **ATC Finding Message:** `Database access inside loop iteration; consider bulk operation or JOIN`

## Rationale

Executing SQL queries (`SELECT`, `UPDATE`, `DELETE`) inside a `LOOP` generates an N+1 query performance anti-pattern. Fetch data in bulk using `FOR ALL ENTRIES` or SQL Joins outside the loop.

### Non-Compliant

```abap
LOOP AT lt_orders INTO ls_order.
  SELECT SINGLE * FROM /dmo/customer
    WHERE customer_id = @ls_order-customer_id
    INTO @ls_customer.
ENDLOOP.
```

### Compliant

```abap
SELECT * FROM /dmo/customer
  FOR ALL ENTRIES IN @lt_orders
  WHERE customer_id = @lt_orders-customer_id
  INTO TABLE @lt_customers.
```

## Transformation

```diff
- LOOP AT lt_orders INTO ls_order.
-   SELECT SINGLE * FROM /dmo/customer
-     WHERE customer_id = @ls_order-customer_id
-     INTO @ls_customer.
- ENDLOOP.
+ SELECT * FROM /dmo/customer
+   FOR ALL ENTRIES IN @lt_orders
+   WHERE customer_id = @lt_orders-customer_id
+   INTO TABLE @lt_customers.
```

## CLI & CI/CD Configuration

```yaml
checks:
  no-db-in-loop:
    enabled: true
    severity: warning
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC DB_IN_LOOP

" SAP CI_ prefix format:
... "#EC CI_DB_IN_LOOP
```

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_NO_DB_IN_LOOP`
* **Implementation File:** [zcl_skylint_no_db_in_loop.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_no_db_in_loop.clas.abap)
