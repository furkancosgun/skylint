# `require-order-by`

> **Category:** [Performance & Database](/rules/#performance) &nbsp;|&nbsp; **Severity:** `warning` &nbsp;|&nbsp; **Finding Code:** `SELECT_UP` &nbsp;|&nbsp; **QuickFix:** No

## Description

SELECT UP TO 1 ROWS requires ORDER BY.

## ❌ Non-Compliant Code

```abap
SELECT * FROM /dmo/customer UP TO 1 ROWS INTO @ls_customer.
```

## ✅ Compliant Code

```abap
SELECT * FROM /dmo/customer ORDER BY customer_id UP TO 1 ROWS INTO @ls_customer.
```

## 🤫 Suppression & Pseudo-Comments

To suppress findings for this rule, append the pseudo-comment or pragma to the statement:

```abap
" Using pseudo-comment:
... "#EC ORDER_BY
" Or with SAP CI_ prefix:
... "#EC CI_ORDER_BY

" Using pragma:
... ##ORDER_BY.
" Or with SAP CI_ prefix:
... ##CI_ORDER_BY.
```

## Configuration (`skylint.yaml`)

```yaml
checks:
  require-order-by:
    enabled: true
    severity: warning
```

## ABAP Class Details

* **Native ATC Class:** `ZCL_SKYLINT_PREF_ORDER_BY`
* **Implementation File:** [zcl_skylint_pref_order_by.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_pref_order_by.clas.abap)
