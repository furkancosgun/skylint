# `no-catch-cx-root`

> **Category:** [Security & Robustness](/rules/#security) &nbsp;|&nbsp; **Severity:** `warning` &nbsp;|&nbsp; **Finding Code:** `CATCH_ROOT` &nbsp;|&nbsp; **QuickFix:** No

## Description

Avoid generic CATCH cx_root; catch specific exception classes.

## ❌ Non-Compliant Code

```abap
TRY.
    process_order( ).
  CATCH cx_root.
    " Indiscriminately catches all exceptions, masking unexpected bugs
ENDTRY.
```

## ✅ Compliant Code

```abap
TRY.
    process_order( ).
  CATCH cx_order_failed INTO DATA(lx_order).
    logger->record( lx_order ).
ENDTRY.
```

## 🤫 Suppression & Pseudo-Comments

To suppress findings for this rule, append the pseudo-comment or pragma to the statement:

```abap
" Using pseudo-comment:
... "#EC CATCH_ROOT
" Or with SAP CI_ prefix:
... "#EC CI_CATCH_ROOT

" Using pragma:
... ##CATCH_ROOT.
" Or with SAP CI_ prefix:
... ##CI_CATCH_ROOT.
```

## Configuration (`skylint.yaml`)

```yaml
checks:
  no-catch-cx-root:
    enabled: true
    severity: warning
```

## ABAP Class Details

* **Native ATC Class:** `ZCL_SKYLINT_NO_CATCH_ROOT`
* **Implementation File:** [zcl_skylint_no_catch_root.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_no_catch_root.clas.abap)
