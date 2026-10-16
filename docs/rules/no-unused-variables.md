# `no-unused-variables`

> **Category:** [Anti-Patterns & Bad Practices](/rules/#anti-patterns) &nbsp;|&nbsp; **Severity:** `warning` &nbsp;|&nbsp; **Finding Code:** `UNUSED_VAR` &nbsp;|&nbsp; **QuickFix:** No

## Description

Detect unused local variables and field symbols.

## ❌ Non-Compliant Code

```abap
DATA lv_temp TYPE string. " Declared but never referenced
```

## ✅ Compliant Code

```abap
" Remove unused declarations or add ##NEEDED pragma if required by interface
```

## 🤫 Suppression & Pseudo-Comments

To suppress findings for this rule, append the pseudo-comment or pragma to the statement:

```abap
" Using pseudo-comment:
... "#EC NEEDED
" Or with SAP CI_ prefix:
... "#EC CI_NEEDED

" Using pragma:
... ##NEEDED.
" Or with SAP CI_ prefix:
... ##CI_NEEDED.
```

## Configuration (`skylint.yaml`)

```yaml
checks:
  no-unused-variables:
    enabled: true
    severity: warning
```

## ABAP Class Details

* **Native ATC Class:** `ZCL_SKYLINT_NO_UNUSED_VARS`
* **Implementation File:** [zcl_skylint_no_unused_vars.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_no_unused_vars.clas.abap)
