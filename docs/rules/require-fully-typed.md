# `require-fully-typed`

> **Category:** [Clean ABAP & Modern Syntax](/rules/#clean-abap) &nbsp;|&nbsp; **Severity:** `warning` &nbsp;|&nbsp; **Finding Code:** `FULLYTYPED` &nbsp;|&nbsp; **QuickFix:** No

## Description

Enforce fully typed constant declarations.

## ❌ Non-Compliant Code

```abap
CONSTANTS c_status VALUE 'A'. " TYPE is omitted; implicitly typed as c length 1
```

## ✅ Compliant Code

```abap
CONSTANTS c_status TYPE c LENGTH 1 VALUE 'A'.
```

## 🤫 Suppression & Pseudo-Comments

To suppress findings for this rule, append the pseudo-comment or pragma to the statement:

```abap
" Using pseudo-comment:
... "#EC FULL_TYPED
" Or with SAP CI_ prefix:
... "#EC CI_FULL_TYPED

" Using pragma:
... ##FULL_TYPED.
" Or with SAP CI_ prefix:
... ##CI_FULL_TYPED.
```

## Configuration (`skylint.yaml`)

```yaml
checks:
  require-fully-typed:
    enabled: true
    severity: warning
```

## ABAP Class Details

* **Native ATC Class:** `ZCL_SKYLINT_PREF_FULL_TYPED`
* **Implementation File:** [zcl_skylint_pref_full_typed.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_pref_full_typed.clas.abap)
