# `no-sy-modify`

> **Category:** [Anti-Patterns & Bad Practices](/rules/#anti-patterns) &nbsp;|&nbsp; **Severity:** `warning` &nbsp;|&nbsp; **Finding Code:** `SYS_VAR_MD` &nbsp;|&nbsp; **QuickFix:** No

## Description

Avoid sy-* System Variable Modification.

## ❌ Non-Compliant Code

```abap
sy-subrc = 0.
sy-tabix = 1.
```

## ✅ Compliant Code

```abap
" Pass explicit return values or flags instead of modifying system variables (sy-*)
rv_success = abap_true.
```

## 🤫 Suppression & Pseudo-Comments

To suppress findings for this rule, append the pseudo-comment or pragma to the statement:

```abap
" Using pseudo-comment:
... "#EC SY_MODIFY
" Or with SAP CI_ prefix:
... "#EC CI_SY_MODIFY

" Using pragma:
... ##SY_MODIFY.
" Or with SAP CI_ prefix:
... ##CI_SY_MODIFY.
```

## Configuration (`skylint.yaml`)

```yaml
checks:
  no-sy-modify:
    enabled: true
    severity: warning
```

## ABAP Class Details

* **Native ATC Class:** `ZCL_SKYLINT_NO_SY_MODIFY`
* **Implementation File:** [zcl_skylint_no_sy_modify.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_no_sy_modify.clas.abap)
