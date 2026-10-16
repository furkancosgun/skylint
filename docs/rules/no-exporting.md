# `no-exporting`

> **Category:** [Anti-Patterns & Bad Practices](/rules/#anti-patterns) &nbsp;|&nbsp; **Severity:** `warning` &nbsp;|&nbsp; **Finding Code:** `OMITEXPORT` &nbsp;|&nbsp; **QuickFix:** ⚡ Yes

## Description

Omit explicit EXPORTING in method calls.

## ❌ Non-Compliant Code

```abap
DATA lo_obj TYPE REF TO zcl_skylint_test_006.
DATA lv_x TYPE i.
lo_obj->run( EXPORTING iv_in = lv_x ).
```

## ✅ Compliant Code

```abap
DATA lo_obj TYPE REF TO zcl_skylint_test_006.
DATA lv_x TYPE i.
lo_obj->run( iv_in = lv_x ).
```

## 🤫 Suppression & Pseudo-Comments

To suppress findings for this rule, append the pseudo-comment or pragma to the statement:

```abap
" Using pseudo-comment:
... "#EC EXPORTING

" Using pragma:
... ##EXPORTING.
```

## Configuration (`skylint.yaml`)

```yaml
checks:
  no-exporting:
    enabled: true
    severity: warning
```

## ABAP Class Details

* **Native ATC Class:** `ZCL_SKYLINT_NO_EXPORTING`
* **Implementation File:** [zcl_skylint_no_exporting.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_no_exporting.clas.abap)
