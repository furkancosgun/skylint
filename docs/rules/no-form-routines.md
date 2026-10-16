# `no-form-routines`

> **Category:** [Anti-Patterns & Bad Practices](/rules/#anti-patterns) &nbsp;|&nbsp; **Severity:** `warning` &nbsp;|&nbsp; **Finding Code:** `AVOID_FORM` &nbsp;|&nbsp; **QuickFix:** No

## Description

Avoid obsolete FORM routines; use modern methods in ABAP Cloud.

## ❌ Non-Compliant Code

```abap
PERFORM my_form IN PROGRAM (sy-repid) IF FOUND.
```

## ✅ Compliant Code

```abap
DATA lo_obj TYPE REF TO zcl_skylint_test_065.
lo_obj->test_002( ).
```

## 🤫 Suppression & Pseudo-Comments

To suppress findings for this rule, append the pseudo-comment or pragma to the statement:

```abap
" Using pseudo-comment:
... "#EC NO_FORM

" Using pragma:
... ##NO_FORM.
```

## Configuration (`skylint.yaml`)

```yaml
checks:
  no-form-routines:
    enabled: true
    severity: warning
```

## ABAP Class Details

* **Native ATC Class:** `ZCL_SKYLINT_NO_FORM`
* **Implementation File:** [zcl_skylint_no_form.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_no_form.clas.abap)
