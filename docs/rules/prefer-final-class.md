# `prefer-final-class`

> **Category:** [Clean ABAP & Modern Syntax](/rules/#clean-abap) &nbsp;|&nbsp; **Severity:** `warning` &nbsp;|&nbsp; **Finding Code:** `NOT_FINAL` &nbsp;|&nbsp; **QuickFix:** ⚡ Yes

## Description

Prefer FINAL classes and methods by default.

## ❌ Non-Compliant Code

```abap
CLASS cl_customer_service DEFINITION PUBLIC CREATE PUBLIC.
  " Class not intended for inheritance
ENDCLASS.
```

## ✅ Compliant Code

```abap
CLASS cl_customer_service DEFINITION PUBLIC FINAL CREATE PUBLIC.
ENDCLASS.
```

## 🤫 Suppression & Pseudo-Comments

To suppress findings for this rule, append the pseudo-comment or pragma to the statement:

```abap
" Using pseudo-comment:
... "#EC FINAL_CLS
" Or with SAP CI_ prefix:
... "#EC CI_FINAL_CLS

" Using pragma:
... ##FINAL_CLS.
" Or with SAP CI_ prefix:
... ##CI_FINAL_CLS.
```

## Configuration (`skylint.yaml`)

```yaml
checks:
  prefer-final-class:
    enabled: true
    severity: warning
```

## ABAP Class Details

* **Native ATC Class:** `ZCL_SKYLINT_PREF_FINAL_CLS`
* **Implementation File:** [zcl_skylint_pref_final_cls.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_pref_final_cls.clas.abap)
