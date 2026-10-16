# `prefer-corresponding`

> **Category:** [Clean ABAP & Modern Syntax](/rules/#clean-abap) &nbsp;|&nbsp; **Severity:** `warning` &nbsp;|&nbsp; **Finding Code:** `PREFER_COR` &nbsp;|&nbsp; **QuickFix:** ⚡ Yes

## Description

Prefer CORRESPONDING Expression over MOVE-CORRESPONDING.

## ❌ Non-Compliant Code

```abap
MOVE-CORRESPONDING ls_source TO ls_target.
```

## ✅ Compliant Code

```abap
ls_target = CORRESPONDING #( ls_source ).
```

## 🤫 Suppression & Pseudo-Comments

To suppress findings for this rule, append the pseudo-comment or pragma to the statement:

```abap
" Using pseudo-comment:
... "#EC CORRESP
" Or with SAP CI_ prefix:
... "#EC CI_CORRESP

" Using pragma:
... ##CORRESP.
" Or with SAP CI_ prefix:
... ##CI_CORRESP.
```

## Configuration (`skylint.yaml`)

```yaml
checks:
  prefer-corresponding:
    enabled: true
    severity: warning
```

## ABAP Class Details

* **Native ATC Class:** `ZCL_SKYLINT_PREF_CORRESP`
* **Implementation File:** [zcl_skylint_pref_corresp.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_pref_corresp.clas.abap)
