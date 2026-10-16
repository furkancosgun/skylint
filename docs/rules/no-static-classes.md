# `no-static-classes`

> **Category:** [Clean ABAP & Modern Syntax](/rules/#clean-abap) &nbsp;|&nbsp; **Severity:** `warning` &nbsp;|&nbsp; **Finding Code:** `STAT_CLASS` &nbsp;|&nbsp; **QuickFix:** No

## Description

Avoid static-only classes; prefer instantiable interface-based design.

## ❌ Non-Compliant Code

```abap
CLASS cl_math_util DEFINITION PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    CLASS-METHODS add IMPORTING a TYPE i b TYPE i RETURNING VALUE(r) TYPE i.
    CLASS-METHODS sub IMPORTING a TYPE i b TYPE i RETURNING VALUE(r) TYPE i.
ENDCLASS.
```

## ✅ Compliant Code

```abap
CLASS cl_math_util DEFINITION PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    INTERFACES if_math_util.
    METHODS add IMPORTING a TYPE i b TYPE i RETURNING VALUE(r) TYPE i.
ENDCLASS.
```

## 🤫 Suppression & Pseudo-Comments

To suppress findings for this rule, append the pseudo-comment or pragma to the statement:

```abap
" Using pseudo-comment:
... "#EC STATIC_CLS
" Or with SAP CI_ prefix:
... "#EC CI_STATIC_CLS

" Using pragma:
... ##STATIC_CLS.
" Or with SAP CI_ prefix:
... ##CI_STATIC_CLS.
```

## Configuration (`skylint.yaml`)

```yaml
checks:
  no-static-classes:
    enabled: true
    severity: warning
```

## ABAP Class Details

* **Native ATC Class:** `ZCL_SKYLINT_NO_STATIC_CLS`
* **Implementation File:** [zcl_skylint_no_static_cls.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_no_static_cls.clas.abap)
