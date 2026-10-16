# `no-static-via-instance`

> **Category:** [Anti-Patterns & Bad Practices](/rules/#anti-patterns) &nbsp;|&nbsp; **Severity:** `warning` &nbsp;|&nbsp; **Finding Code:** `STATICVIAI` &nbsp;|&nbsp; **QuickFix:** ⚡ Yes

## Description

Avoid calling static methods via instance arrow (->).

## ❌ Non-Compliant Code

```abap
DATA lo_instance TYPE REF TO cl_helper.
lo_instance->static_method( ).
```

## ✅ Compliant Code

```abap
cl_helper=>static_method( ).
```

## 🤫 Suppression & Pseudo-Comments

To suppress findings for this rule, append the pseudo-comment or pragma to the statement:

```abap
" Using pseudo-comment:
... "#EC STATIC_ARROW
" Or with SAP CI_ prefix:
... "#EC CI_STATIC_ARROW

" Using pragma:
... ##STATIC_ARROW.
" Or with SAP CI_ prefix:
... ##CI_STATIC_ARROW.
```

## Configuration (`skylint.yaml`)

```yaml
checks:
  no-static-via-instance:
    enabled: true
    severity: warning
```

## ABAP Class Details

* **Native ATC Class:** `ZCL_SKYLINT_NO_STATIC_ARROW`
* **Implementation File:** [zcl_skylint_no_static_arrow.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_no_static_arrow.clas.abap)
