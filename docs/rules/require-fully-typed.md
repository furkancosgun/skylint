# `require-fully-typed`

> **Category:** [Clean ABAP & Modern Syntax](/rules/#clean-abap) &nbsp;|&nbsp; **Severity:** `warning` &nbsp;|&nbsp; **Finding Code:** `FULLYTYPED` &nbsp;|&nbsp; **QuickFix:** No

## Description

Enforce fully typed constant declarations.

## ❌ Non-Compliant Code

```abap
CONSTANTS lc_val VALUE 'X'.
```

## ✅ Compliant Code

```abap
CONSTANTS lc_val TYPE string VALUE 'X'.
```

## 🤫 Suppression & Pseudo-Comments

To suppress findings for this rule, append the pseudo-comment or pragma to the statement:

```abap
" Using pseudo-comment:
... "#EC FULL_TYPED

" Using pragma:
... ##FULL_TYPED.
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
