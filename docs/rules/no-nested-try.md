# `no-nested-try`

> **Category:** [Clean ABAP & Modern Syntax](/rules/#clean-abap) &nbsp;|&nbsp; **Severity:** `warning` &nbsp;|&nbsp; **Finding Code:** `NESTED_TRY` &nbsp;|&nbsp; **QuickFix:** No

## Description

Avoid nested TRY blocks; extract inner error handling to helper methods.

## ❌ Non-Compliant Code

```abap
TRY.
    step1( ).
    TRY.
        step2( ).
      CATCH cx_step2_err.
        handle_step2( ).
    ENDTRY.
  CATCH cx_step1_err.
    handle_step1( ).
ENDTRY.
```

## ✅ Compliant Code

```abap
" Extract inner operations into focused helper methods
TRY.
    step1( ).
    execute_step2( ).
  CATCH cx_step1_err.
    handle_step1( ).
ENDTRY.
```

## 🤫 Suppression & Pseudo-Comments

To suppress findings for this rule, append the pseudo-comment or pragma to the statement:

```abap
" Using pseudo-comment:
... "#EC NESTED_TRY
" Or with SAP CI_ prefix:
... "#EC CI_NESTED_TRY

" Using pragma:
... ##NESTED_TRY.
" Or with SAP CI_ prefix:
... ##CI_NESTED_TRY.
```

## Configuration (`skylint.yaml`)

```yaml
checks:
  no-nested-try:
    enabled: true
    severity: warning
```

## ABAP Class Details

* **Native ATC Class:** `ZCL_SKYLINT_NO_NESTED_TRY`
* **Implementation File:** [zcl_skylint_no_nested_try.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_no_nested_try.clas.abap)
