---
description: "Avoid database access inside loop iterations"
---

# Avoid Database Access Inside Loops

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Performance & Database" />
  <Badge type="danger" text="#EC DB_IN_LOOP" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Avoid database access inside loop iterations.

> **ATC Finding Message:** `Database access inside loop iteration; consider bulk operation or JOIN`

## Rationale

A database call inside a loop executes once per row, creating the N+1 query problem and multiplying network round trips. Performance degrades quickly as the table grows and can exhaust database resources. Select the required data in bulk before the loop with FOR ALL ENTRIES or a JOIN, then process it in memory.

### Non-Compliant

```abap
LOOP AT lt_orders INTO ls_order.
  SELECT SINGLE customer_id FROM /dmo/customer
    WHERE customer_id = @ls_order-customer_id
    INTO @lv_customer_id.
ENDLOOP.
```

### Compliant

```abap
IF lt_orders IS NOT INITIAL.
  SELECT customer_id FROM /dmo/customer
    FOR ALL ENTRIES IN @lt_orders
    WHERE customer_id = @lt_orders-customer_id
    INTO TABLE @lt_customer_ids.
ENDIF.
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
