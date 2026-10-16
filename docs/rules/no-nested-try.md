# `no-nested-try`

> **Category:** [Clean ABAP & Modern Syntax](/rules/#clean-abap) &nbsp;|&nbsp; **Severity:** `warning` &nbsp;|&nbsp; **Finding Code:** `NESTED_TRY` &nbsp;|&nbsp; **QuickFix:** No

## Description

Avoid nested TRY blocks; extract inner error handling to helper methods.

## ❌ Non-Compliant Code

```abap
TRY.
  TRY.
  CATCH cx_root.
  ENDTRY.
CATCH cx_root.
ENDTRY.
```

## ✅ Compliant Code

```abap
TRY.
CATCH cx_root.
ENDTRY.
```

## 🤫 Suppression & Pseudo-Comments

To suppress findings for this rule, append the pseudo-comment or pragma to the statement:

```abap
" Using pseudo-comment:
... "#EC NESTED_TRY

" Using pragma:
... ##NESTED_TRY.
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
