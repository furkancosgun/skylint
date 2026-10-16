# `require-decl-order`

> **Category:** [Clean ABAP & Modern Syntax](/rules/#clean-abap) &nbsp;|&nbsp; **Severity:** `warning` &nbsp;|&nbsp; **Finding Code:** `DECL_ORDER` &nbsp;|&nbsp; **QuickFix:** No

## Description

Enforce local declaration order (TYPES -> CONSTANTS -> DATA -> FIELD-SYMBOLS).

## ❌ Non-Compliant Code

```abap
METHOD execute.
  DATA lv_count TYPE i.
  TYPES ty_status TYPE c LENGTH 1. " TYPES declared after DATA
  CONSTANTS c_init TYPE ty_status VALUE 'I'.
ENDMETHOD.
```

## ✅ Compliant Code

```abap
METHOD execute.
  TYPES ty_status TYPE c LENGTH 1.
  CONSTANTS c_init TYPE ty_status VALUE 'I'.
  DATA lv_count TYPE i.
ENDMETHOD.
```

## 🤫 Suppression & Pseudo-Comments

To suppress findings for this rule, append the pseudo-comment or pragma to the statement:

```abap
" Using pseudo-comment:
... "#EC DECL_ORDER
" Or with SAP CI_ prefix:
... "#EC CI_DECL_ORDER

" Using pragma:
... ##DECL_ORDER.
" Or with SAP CI_ prefix:
... ##CI_DECL_ORDER.
```

## Configuration (`skylint.yaml`)

```yaml
checks:
  require-decl-order:
    enabled: true
    severity: warning
```

## ABAP Class Details

* **Native ATC Class:** `ZCL_SKYLINT_PREF_DECL_ORDER`
* **Implementation File:** [zcl_skylint_pref_decl_order.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_pref_decl_order.clas.abap)
