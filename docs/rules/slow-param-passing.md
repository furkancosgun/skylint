# `slow-param-passing`

> **Category:** [Performance & Database](/rules/#performance) &nbsp;|&nbsp; **Severity:** `warning` &nbsp;|&nbsp; **Finding Code:** `SLOW_PASS` &nbsp;|&nbsp; **QuickFix:** No

## Description

Slow Parameter Passing.

## ❌ Non-Compliant Code

```abap
METHODS process IMPORTING VALUE(iv_text) TYPE string.
```

## ✅ Compliant Code

```abap
METHODS process IMPORTING iv_text TYPE string.
```

## 🤫 Suppression & Pseudo-Comments

To suppress findings for this rule, append the pseudo-comment or pragma to the statement:

```abap
" Using pseudo-comment:
... "#EC SLOW_PARAM
" Or with SAP CI_ prefix:
... "#EC CI_SLOW_PARAM

" Using pragma:
... ##SLOW_PARAM.
" Or with SAP CI_ prefix:
... ##CI_SLOW_PARAM.
```

## Configuration (`skylint.yaml`)

```yaml
checks:
  slow-param-passing:
    enabled: true
    severity: warning
```

## ABAP Class Details

* **Native ATC Class:** `ZCL_SKYLINT_SLOW_PARAM_PASS`
* **Implementation File:** [zcl_skylint_slow_param_pass.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_slow_param_pass.clas.abap)
