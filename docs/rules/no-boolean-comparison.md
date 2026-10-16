# `no-boolean-comparison`

> **Category:** [Anti-Patterns & Bad Practices](/rules/#anti-patterns) &nbsp;|&nbsp; **Severity:** `warning` &nbsp;|&nbsp; **Finding Code:** `BOOLCOMP` &nbsp;|&nbsp; **QuickFix:** ⚡ Yes

## Description

Avoid comparing boolean method calls to boolean literals.

## ❌ Non-Compliant Code

```abap
IF is_valid( ) = abap_true.
  execute( ).
ENDIF.
```

## ✅ Compliant Code

```abap
IF is_valid( ).
  execute( ).
ENDIF.
```

## 🤫 Suppression & Pseudo-Comments

To suppress findings for this rule, append the pseudo-comment or pragma to the statement:

```abap
" Using pseudo-comment:
... "#EC BOOL_COMPARE
" Or with SAP CI_ prefix:
... "#EC CI_BOOL_COMPARE

" Using pragma:
... ##BOOL_COMPARE.
" Or with SAP CI_ prefix:
... ##CI_BOOL_COMPARE.
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
