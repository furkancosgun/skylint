# `prefer-final-method`

> **Category:** [Clean ABAP & Modern Syntax](/rules/#clean-abap) &nbsp;|&nbsp; **Severity:** `warning` &nbsp;|&nbsp; **Finding Code:** `PREF_FINAL` &nbsp;|&nbsp; **QuickFix:** ⚡ Yes

## Description

Prefer marking non-overridden methods as FINAL.

## ❌ Non-Compliant Code

```abap
CLASS cl_service DEFINITION PUBLIC.
  PUBLIC SECTION.
    METHODS process. " In class not intended for polymorphic overriding
ENDCLASS.
```

## ✅ Compliant Code

```abap
CLASS cl_service DEFINITION PUBLIC.
  PUBLIC SECTION.
    METHODS process FINAL.
ENDCLASS.
```

## 🤫 Suppression & Pseudo-Comments

To suppress findings for this rule, append the pseudo-comment or pragma to the statement:

```abap
" Using pseudo-comment:
... "#EC FINAL_METHOD
" Or with SAP CI_ prefix:
... "#EC CI_FINAL_METHOD

" Using pragma:
... ##FINAL_METHOD.
" Or with SAP CI_ prefix:
... ##CI_FINAL_METHOD.
```

## Configuration (`skylint.yaml`)

```yaml
checks:
  prefer-final-method:
    enabled: true
    severity: warning
```

## ABAP Class Details

* **Native ATC Class:** `ZCL_SKYLINT_PREF_FINAL_METH`
* **Implementation File:** [zcl_skylint_pref_final_meth.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_pref_final_meth.clas.abap)
