# `prefer-returning`

> **Category:** [Clean ABAP & Modern Syntax](/rules/#clean-abap) &nbsp;|&nbsp; **Severity:** `warning` &nbsp;|&nbsp; **Finding Code:** `PREFER_RET` &nbsp;|&nbsp; **QuickFix:** No

## Description

Prefer RETURNING over single EXPORTING.

## ❌ Non-Compliant Code

```abap
METHODS calculate
  EXPORTING ev_result TYPE i.
```

## ✅ Compliant Code

```abap
METHODS calculate
  RETURNING VALUE(rv_result) TYPE i.
```

## 🤫 Suppression & Pseudo-Comments

To suppress findings for this rule, append the pseudo-comment or pragma to the statement:

```abap
" Using pseudo-comment:
... "#EC RETURNING
" Or with SAP CI_ prefix:
... "#EC CI_RETURNING

" Using pragma:
... ##RETURNING.
" Or with SAP CI_ prefix:
... ##CI_RETURNING.
```

## Configuration (`skylint.yaml`)

```yaml
checks:
  prefer-returning:
    enabled: true
    severity: warning
```

## ABAP Class Details

* **Native ATC Class:** `ZCL_SKYLINT_PREF_RETURNING`
* **Implementation File:** [zcl_skylint_pref_returning.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_pref_returning.clas.abap)
