# `prefer-case`

> **Category:** [Clean ABAP & Modern Syntax](/rules/#clean-abap) &nbsp;|&nbsp; **Severity:** `warning` &nbsp;|&nbsp; **Finding Code:** `USE_CASE` &nbsp;|&nbsp; **QuickFix:** No

## Description

Change IF to CASE when checking the same variable against multiple values.

## ❌ Non-Compliant Code

```abap
IF lv_type = 'A'.
  process_a( ).
ELSEIF lv_type = 'B'.
  process_b( ).
ELSEIF lv_type = 'C'.
  process_c( ).
ENDIF.
```

## ✅ Compliant Code

```abap
CASE lv_type.
  WHEN 'A'.
    process_a( ).
  WHEN 'B'.
    process_b( ).
  WHEN 'C'.
    process_c( ).
ENDCASE.
```

## 🤫 Suppression & Pseudo-Comments

To suppress findings for this rule, append the pseudo-comment or pragma to the statement:

```abap
" Using pseudo-comment:
... "#EC PREF_CASE
" Or with SAP CI_ prefix:
... "#EC CI_PREF_CASE

" Using pragma:
... ##PREF_CASE.
" Or with SAP CI_ prefix:
... ##CI_PREF_CASE.
```

## Configuration (`skylint.yaml`)

```yaml
checks:
  prefer-case:
    enabled: true
    severity: warning
```

## ABAP Class Details

* **Native ATC Class:** `ZCL_SKYLINT_PREF_CASE`
* **Implementation File:** [zcl_skylint_pref_case.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_pref_case.clas.abap)
