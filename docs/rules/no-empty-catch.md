# `no-empty-catch`

> **Category:** [Anti-Patterns & Bad Practices](/rules/#anti-patterns) &nbsp;|&nbsp; **Severity:** `warning` &nbsp;|&nbsp; **Finding Code:** `EMPTYCATCH` &nbsp;|&nbsp; **QuickFix:** No

## Description

Detect empty CATCH blocks swallowing exceptions.

## ❌ Non-Compliant Code

```abap
TRY.
    lo_calc->compute( ).
  CATCH cx_sy_zerodivide.
    " Silently ignored exception
ENDTRY.
```

## ✅ Compliant Code

```abap
TRY.
    lo_calc->compute( ).
  CATCH cx_sy_zerodivide INTO DATA(lx_error).
    logger->record( lx_error ).
ENDTRY.
```

## 🤫 Suppression & Pseudo-Comments

To suppress findings for this rule, append the pseudo-comment or pragma to the statement:

```abap
" Using pseudo-comment:
... "#EC NO_HANDLER
" Or with SAP CI_ prefix:
... "#EC CI_NO_HANDLER

" Using pragma:
... ##NO_HANDLER.
" Or with SAP CI_ prefix:
... ##CI_NO_HANDLER.
```

## Configuration (`skylint.yaml`)

```yaml
checks:
  no-empty-catch:
    enabled: true
    severity: warning
```

## ABAP Class Details

* **Native ATC Class:** `ZCL_SKYLINT_NO_EMPTY_CATCH`
* **Implementation File:** [zcl_skylint_no_empty_catch.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_no_empty_catch.clas.abap)
