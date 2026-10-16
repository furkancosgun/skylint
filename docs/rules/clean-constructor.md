# `clean-constructor`

> **Category:** [Clean ABAP & Modern Syntax](/rules/#clean-abap) &nbsp;|&nbsp; **Severity:** `warning` &nbsp;|&nbsp; **Finding Code:** `CTOR_LOGIC` &nbsp;|&nbsp; **QuickFix:** No

## Description

Keep constructors clean; avoid heavy business logic/loops/DB access.

## ✅ Compliant Code

```abap
RETURN.
```

## 🤫 Suppression & Pseudo-Comments

To suppress findings for this rule, append the pseudo-comment or pragma to the statement:

```abap
" Using pseudo-comment:
... "#EC CLEAN_CTOR

" Using pragma:
... ##CLEAN_CTOR.
```

## Configuration (`skylint.yaml`)

```yaml
checks:
  clean-constructor:
    enabled: true
    severity: warning
```

## ABAP Class Details

* **Native ATC Class:** `ZCL_SKYLINT_CLEAN_CTOR`
* **Implementation File:** [zcl_skylint_clean_ctor.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_clean_ctor.clas.abap)
