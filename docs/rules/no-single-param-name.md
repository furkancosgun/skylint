# `no-single-param-name`

> **Category:** [Anti-Patterns & Bad Practices](/rules/#anti-patterns) &nbsp;|&nbsp; **Severity:** `warning` &nbsp;|&nbsp; **Finding Code:** `OMITPARM` &nbsp;|&nbsp; **QuickFix:** ⚡ Yes

## Description

Omit parameter name in single parameter method call.

## ❌ Non-Compliant Code

```abap
DATA lo_obj TYPE REF TO zcl_skylint_test_036.
DATA lv_val TYPE i.
lo_obj->run( iv_param = lv_val ).
```

## ✅ Compliant Code

```abap
DATA lo_obj TYPE REF TO zcl_skylint_test_036.
DATA lv_val TYPE i.
lo_obj->run( lv_val ).
```

## 🤫 Suppression & Pseudo-Comments

To suppress findings for this rule, append the pseudo-comment or pragma to the statement:

```abap
" Using pseudo-comment:
... "#EC PARAM_NAME

" Using pragma:
... ##PARAM_NAME.
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
