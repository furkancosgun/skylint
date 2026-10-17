# `modify-own-tables`

> **Category:** [Security & Robustness](/rules/#security) &nbsp;|&nbsp; **Severity:** `warning` &nbsp;|&nbsp; **Finding Code:** `NOT_OWN_TB` &nbsp;|&nbsp; **QuickFix:** No

## Description

Modify Only Own Database Tables.

## ❌ Non-Compliant Code

```abap
DELETE FROM mara WHERE matnr = '100'.
```

## ✅ Compliant Code

```abap
DELETE FROM zmara WHERE matnr = '100'.
```

## 🤫 Suppression & Pseudo-Comments

To suppress findings for this rule, append the pseudo-comment or pragma to the statement:

```abap
" Using pseudo-comment:
... "#EC OWN_TABLES
" Or with SAP CI_ prefix:
... "#EC CI_OWN_TABLES

" Using pragma:
... ##OWN_TABLES.
" Or with SAP CI_ prefix:
... ##CI_OWN_TABLES.
```

## Configuration (`skylint.yaml`)

```yaml
checks:
  modify-own-tables:
    enabled: true
    severity: warning
```

## ABAP Class Details

* **Native ATC Class:** `ZCL_SKYLINT_MODIFY_OWN_TAB`
* **Implementation File:** [zcl_skylint_modify_own_tab.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_modify_own_tab.clas.abap)
