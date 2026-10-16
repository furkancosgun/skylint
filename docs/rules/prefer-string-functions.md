# `prefer-string-functions`

> **Category:** [Clean ABAP & Modern Syntax](/rules/#clean-abap) &nbsp;|&nbsp; **Severity:** `warning` &nbsp;|&nbsp; **Finding Code:** `CONDENSE_S` &nbsp;|&nbsp; **QuickFix:** ⚡ Yes

## Description

Detect obsolete string statements; prefer built-in functions.

## ❌ Non-Compliant Code

```abap
IF lv_str CS 'ABAP'.
  process( ).
ENDIF.
```

## ✅ Compliant Code

```abap
IF contains( val = lv_str sub = 'ABAP' ).
  process( ).
ENDIF.
```

## 🤫 Suppression & Pseudo-Comments

To suppress findings for this rule, append the pseudo-comment or pragma to the statement:

```abap
" Using pseudo-comment:
... "#EC STR_FUNC
" Or with SAP CI_ prefix:
... "#EC CI_STR_FUNC

" Using pragma:
... ##STR_FUNC.
" Or with SAP CI_ prefix:
... ##CI_STR_FUNC.
```

## Configuration (`skylint.yaml`)

```yaml
checks:
  prefer-string-functions:
    enabled: true
    severity: warning
```

## ABAP Class Details

* **Native ATC Class:** `ZCL_SKYLINT_PREF_STR_FUNC`
* **Implementation File:** [zcl_skylint_pref_str_func.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_pref_str_func.clas.abap)
