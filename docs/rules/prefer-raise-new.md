# `prefer-raise-new`

> **Category:** [Clean ABAP & Modern Syntax](/rules/#clean-abap) &nbsp;|&nbsp; **Severity:** `warning` &nbsp;|&nbsp; **Finding Code:** `RAISEEXCNE` &nbsp;|&nbsp; **QuickFix:** ⚡ Yes

## Description

Prefer RAISE EXCEPTION NEW over RAISE EXCEPTION TYPE.

## ❌ Non-Compliant Code

```abap
RAISE EXCEPTION TYPE cx_failed.
```

## ✅ Compliant Code

```abap
RAISE EXCEPTION NEW cx_failed( ).
```

## 🤫 Suppression & Pseudo-Comments

To suppress findings for this rule, append the pseudo-comment or pragma to the statement:

```abap
" Using pseudo-comment:
... "#EC RAISE_NEW
" Or with SAP CI_ prefix:
... "#EC CI_RAISE_NEW

" Using pragma:
... ##RAISE_NEW.
" Or with SAP CI_ prefix:
... ##CI_RAISE_NEW.
```

## Configuration (`skylint.yaml`)

```yaml
checks:
  prefer-raise-new:
    enabled: true
    severity: warning
```

## ABAP Class Details

* **Native ATC Class:** `ZCL_SKYLINT_PREF_RAISE_NEW`
* **Implementation File:** [zcl_skylint_pref_raise_new.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_pref_raise_new.clas.abap)
