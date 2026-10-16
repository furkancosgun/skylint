# `no-try-without-catch`

> **Category:** [Anti-Patterns & Bad Practices](/rules/#anti-patterns) &nbsp;|&nbsp; **Severity:** `warning` &nbsp;|&nbsp; **Finding Code:** `TRYWITHOUT` &nbsp;|&nbsp; **QuickFix:** No

## Description

Detect TRY without CATCH.

## ❌ Non-Compliant Code

```abap
TRY.
    do_work( ).
  CLEANUP.
    cleanup( ).
ENDTRY.
```

## ✅ Compliant Code

```abap
TRY.
    do_work( ).
  CATCH cx_failed INTO DATA(lx_err).
    handle( lx_err ).
  CLEANUP.
    cleanup( ).
ENDTRY.
```

## 🤫 Suppression & Pseudo-Comments

To suppress findings for this rule, append the pseudo-comment or pragma to the statement:

```abap
" Using pseudo-comment:
... "#EC TRY_NO_CATCH
" Or with SAP CI_ prefix:
... "#EC CI_TRY_NO_CATCH

" Using pragma:
... ##TRY_NO_CATCH.
" Or with SAP CI_ prefix:
... ##CI_TRY_NO_CATCH.
```

## Configuration (`skylint.yaml`)

```yaml
checks:
  no-try-without-catch:
    enabled: true
    severity: warning
```

## ABAP Class Details

* **Native ATC Class:** `ZCL_SKYLINT_NO_TRY_NO_CATCH`
* **Implementation File:** [zcl_skylint_no_try_no_catch.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_no_try_no_catch.clas.abap)
