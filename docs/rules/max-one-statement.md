# `max-one-statement`

> **Category:** [Clean ABAP & Modern Syntax](/rules/#clean-abap) &nbsp;|&nbsp; **Severity:** `warning` &nbsp;|&nbsp; **Finding Code:** `ONE_STMT` &nbsp;|&nbsp; **QuickFix:** No

## Description

Max One Statement Per Line.

## ❌ Non-Compliant Code

```abap
lv_a = 1. lv_b = 2.
```

## ✅ Compliant Code

```abap
lv_a = 1.
lv_b = 2.
```

## 🤫 Suppression & Pseudo-Comments

To suppress findings for this rule, append the pseudo-comment or pragma to the statement:

```abap
" Using pseudo-comment:
... "#EC ONE_STMT
" Or with SAP CI_ prefix:
... "#EC CI_ONE_STMT

" Using pragma:
... ##ONE_STMT.
" Or with SAP CI_ prefix:
... ##CI_ONE_STMT.
```

## Configuration (`skylint.yaml`)

```yaml
checks:
  max-one-statement:
    enabled: true
    severity: warning
```

## ABAP Class Details

* **Native ATC Class:** `ZCL_SKYLINT_MAX_ONE_STMT`
* **Implementation File:** [zcl_skylint_max_one_stmt.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_max_one_stmt.clas.abap)
