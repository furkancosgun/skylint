# `no-catch-cx-root`

> **Category:** [Security & Robustness](/rules/#security) &nbsp;|&nbsp; **Severity:** `warning` &nbsp;|&nbsp; **Finding Code:** `CATCH_ROOT` &nbsp;|&nbsp; **QuickFix:** No

## Description

Avoid generic CATCH cx_root; catch specific exception classes.

## ❌ Non-Compliant Code

```abap
TRY.
CATCH cx_root.
ENDTRY.
```

## ✅ Compliant Code

```abap
TRY.
CATCH cx_static_check.
ENDTRY.
```

## 🤫 Suppression & Pseudo-Comments

To suppress findings for this rule, append the pseudo-comment or pragma to the statement:

```abap
" Using pseudo-comment:
... "#EC CATCH_ROOT

" Using pragma:
... ##CATCH_ROOT.
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
