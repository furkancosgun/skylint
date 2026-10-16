# `no-boolean-comparison`

> **Category:** [Anti-Patterns & Bad Practices](/rules/#anti-patterns) &nbsp;|&nbsp; **Severity:** `warning` &nbsp;|&nbsp; **Finding Code:** `BOOLCOMP` &nbsp;|&nbsp; **QuickFix:** ⚡ Yes

## Description

Avoid comparing boolean method calls to boolean literals.

## ❌ Non-Compliant Code

```abap
DATA lo_validator TYPE REF TO zcl_skylint_test_010.
IF lo_validator->is_valid( ) = abap_true.
ENDIF.
```

## ✅ Compliant Code

```abap
DATA lo_validator TYPE REF TO zcl_skylint_test_010.
DATA lv_flag TYPE abap_bool.
IF lo_validator->is_valid( ).
ENDIF.
IF lv_flag = abap_true.
ENDIF.
```

## 🤫 Suppression & Pseudo-Comments

To suppress findings for this rule, append the pseudo-comment or pragma to the statement:

```abap
" Using pseudo-comment:
... "#EC BOOL_COMPARE

" Using pragma:
... ##BOOL_COMPARE.
```

## Configuration (`skylint.yaml`)

```yaml
checks:
  no-boolean-comparison:
    enabled: true
    severity: warning
```

## ABAP Class Details

* **Native ATC Class:** `ZCL_SKYLINT_NO_BOOL_COMPARE`
* **Implementation File:** [zcl_skylint_no_bool_compare.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_no_bool_compare.clas.abap)
