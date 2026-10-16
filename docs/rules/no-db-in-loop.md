# `no-db-in-loop`

> **Category:** [Performance & Database](/rules/#performance) &nbsp;|&nbsp; **Severity:** `warning` &nbsp;|&nbsp; **Finding Code:** `DBINLOOP` &nbsp;|&nbsp; **QuickFix:** No

## Description

Avoid database access inside loop iterations.

## ❌ Non-Compliant Code

```abap
LOOP AT lt_orders INTO ls_order.
  SELECT SINGLE * FROM /dmo/customer
    WHERE customer_id = @ls_order-customer_id
    INTO @ls_customer.
ENDLOOP.
```

## ✅ Compliant Code

```abap
SELECT * FROM /dmo/customer
  FOR ALL ENTRIES IN @lt_orders
  WHERE customer_id = @lt_orders-customer_id
  INTO TABLE @lt_customers.
```

## 🤫 Suppression & Pseudo-Comments

To suppress findings for this rule, append the pseudo-comment or pragma to the statement:

```abap
" Using pseudo-comment:
... "#EC DB_IN_LOOP
" Or with SAP CI_ prefix:
... "#EC CI_DB_IN_LOOP

" Using pragma:
... ##DB_IN_LOOP.
" Or with SAP CI_ prefix:
... ##CI_DB_IN_LOOP.
```

## Configuration (`skylint.yaml`)

```yaml
checks:
  no-db-in-loop:
    enabled: true
    severity: warning
```

## ABAP Class Details

* **Native ATC Class:** `ZCL_SKYLINT_NO_DB_IN_LOOP`
* **Implementation File:** [zcl_skylint_no_db_in_loop.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_no_db_in_loop.clas.abap)
