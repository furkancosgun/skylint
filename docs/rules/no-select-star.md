# `no-select-star`

> **Category:** [Performance & Database](/rules/#performance) &nbsp;|&nbsp; **Severity:** `warning` &nbsp;|&nbsp; **Finding Code:** `SELECTSTAR` &nbsp;|&nbsp; **QuickFix:** No

## Description

Select performance (Avoid SELECT * and SELECT ... ENDSELECT).

## ❌ Non-Compliant Code

```abap
SELECT * FROM /dmo/customer INTO TABLE @lt_customers.
```

## ✅ Compliant Code

```abap
SELECT customer_id, first_name, last_name
  FROM /dmo/customer
  INTO TABLE @lt_customers.
```

## 🤫 Suppression & Pseudo-Comments

To suppress findings for this rule, append the pseudo-comment or pragma to the statement:

```abap
" Using pseudo-comment:
... "#EC SELECT_STAR
" Or with SAP CI_ prefix:
... "#EC CI_SELECT_STAR

" Using pragma:
... ##SELECT_STAR.
" Or with SAP CI_ prefix:
... ##CI_SELECT_STAR.
```

## Configuration (`skylint.yaml`)

```yaml
checks:
  no-select-star:
    enabled: true
    severity: warning
```

## ABAP Class Details

* **Native ATC Class:** `ZCL_SKYLINT_NO_SELECT_STAR`
* **Implementation File:** [zcl_skylint_no_select_star.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_no_select_star.clas.abap)
