# `require-order-by`

> **Category:** [Performance & Database](/rules/#performance) &nbsp;|&nbsp; **Severity:** `warning` &nbsp;|&nbsp; **Finding Code:** `SELECT_UP` &nbsp;|&nbsp; **QuickFix:** No

## Description

SELECT UP TO 1 ROWS requires ORDER BY.

## ❌ Non-Compliant Code

```abap
DATA lt_tab TYPE STANDARD TABLE OF zskylint_dummy WITH DEFAULT KEY.
SELECT * FROM zskylint_dummy UP TO 1 ROWS INTO TABLE @lt_tab.
```

## ✅ Compliant Code

```abap
DATA lt_tab TYPE STANDARD TABLE OF zskylint_dummy WITH DEFAULT KEY.
SELECT * FROM zskylint_dummy UP TO 1 ROWS INTO TABLE @lt_tab ORDER BY field1.
```

## 🤫 Suppression & Pseudo-Comments

To suppress findings for this rule, append the pseudo-comment or pragma to the statement:

```abap
" Using pseudo-comment:
... "#EC ORDER_BY

" Using pragma:
... ##ORDER_BY.
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
