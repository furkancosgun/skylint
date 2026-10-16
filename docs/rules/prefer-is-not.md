# `prefer-is-not`

> **Category:** [Clean ABAP & Modern Syntax](/rules/#clean-abap) &nbsp;|&nbsp; **Severity:** `warning` &nbsp;|&nbsp; **Finding Code:** `PREFERISNT` &nbsp;|&nbsp; **QuickFix:** ⚡ Yes

## Description

Prefer IS NOT over NOT ... IS.

## ❌ Non-Compliant Code

```abap
IF NOT lo_instance IS BOUND.
  RETURN.
ENDIF.
```

## ✅ Compliant Code

```abap
IF lo_instance IS NOT BOUND.
  RETURN.
ENDIF.
```

## 🤫 Suppression & Pseudo-Comments

To suppress findings for this rule, append the pseudo-comment or pragma to the statement:

```abap
" Using pseudo-comment:
... "#EC IS_NOT
" Or with SAP CI_ prefix:
... "#EC CI_IS_NOT

" Using pragma:
... ##IS_NOT.
" Or with SAP CI_ prefix:
... ##CI_IS_NOT.
```

## Configuration (`skylint.yaml`)

```yaml
checks:
  prefer-is-not:
    enabled: true
    severity: warning
```

## ABAP Class Details

* **Native ATC Class:** `ZCL_SKYLINT_PREF_IS_NOT`
* **Implementation File:** [zcl_skylint_pref_is_not.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_pref_is_not.clas.abap)
