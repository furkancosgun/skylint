# `prefer-class-exceptions`

> **Category:** [Clean ABAP & Modern Syntax](/rules/#clean-abap) &nbsp;|&nbsp; **Severity:** `warning` &nbsp;|&nbsp; **Finding Code:** `CLASS_EXC` &nbsp;|&nbsp; **QuickFix:** No

## Description

Prefer Class-Based Exceptions over Classic EXCEPTIONS.

## ❌ Non-Compliant Code

```abap
METHODS execute EXCEPTIONS not_found failed.
```

## ✅ Compliant Code

```abap
METHODS execute RAISING cx_not_found cx_failed.
```

## 🤫 Suppression & Pseudo-Comments

To suppress findings for this rule, append the pseudo-comment or pragma to the statement:

```abap
" Using pseudo-comment:
... "#EC CLASS_EXC
" Or with SAP CI_ prefix:
... "#EC CI_CLASS_EXC

" Using pragma:
... ##CLASS_EXC.
" Or with SAP CI_ prefix:
... ##CI_CLASS_EXC.
```

## Configuration (`skylint.yaml`)

```yaml
checks:
  prefer-class-exceptions:
    enabled: true
    severity: warning
```

## ABAP Class Details

* **Native ATC Class:** `ZCL_SKYLINT_PREF_CLASS_EXC`
* **Implementation File:** [zcl_skylint_pref_class_exc.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_pref_class_exc.clas.abap)
