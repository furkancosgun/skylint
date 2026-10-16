# `no-single-param-name`

> **Category:** [Anti-Patterns & Bad Practices](/rules/#anti-patterns) &nbsp;|&nbsp; **Severity:** `warning` &nbsp;|&nbsp; **Finding Code:** `OMITPARM` &nbsp;|&nbsp; **QuickFix:** ⚡ Yes

## Description

Omit parameter name in single parameter method call.

## ❌ Non-Compliant Code

```abap
cl_helper=>execute( iv_data = lv_data ).
```

## ✅ Compliant Code

```abap
cl_helper=>execute( lv_data ).
```

## 🤫 Suppression & Pseudo-Comments

To suppress findings for this rule, append the pseudo-comment or pragma to the statement:

```abap
" Using pseudo-comment:
... "#EC PARAM_NAME
" Or with SAP CI_ prefix:
... "#EC CI_PARAM_NAME

" Using pragma:
... ##PARAM_NAME.
" Or with SAP CI_ prefix:
... ##CI_PARAM_NAME.
```

## Configuration (`skylint.yaml`)

```yaml
checks:
  no-single-param-name:
    enabled: true
    severity: warning
```

## ABAP Class Details

* **Native ATC Class:** `ZCL_SKYLINT_NO_PARAM_NAME`
* **Implementation File:** [zcl_skylint_no_param_name.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_no_param_name.clas.abap)
