# `no-static-classes`

> **Category:** [Clean ABAP & Modern Syntax](/rules/#clean-abap) &nbsp;|&nbsp; **Severity:** `warning` &nbsp;|&nbsp; **Finding Code:** `STAT_CLASS` &nbsp;|&nbsp; **QuickFix:** No

## Description

Avoid static-only classes; prefer instantiable interface-based design.

## ❌ Non-Compliant Code

```abap
RETURN.
```

## ✅ Compliant Code

```abap
RETURN.
```

## 🤫 Suppression & Pseudo-Comments

To suppress findings for this rule, append the pseudo-comment or pragma to the statement:

```abap
" Using pseudo-comment:
... "#EC STATIC_CLS

" Using pragma:
... ##STATIC_CLS.
```

## Configuration (`skylint.yaml`)

```yaml
checks:
  no-static-classes:
    enabled: true
    severity: warning
```

## ABAP Class Details

* **Native ATC Class:** `ZCL_SKYLINT_NO_STATIC_CLS`
* **Implementation File:** [zcl_skylint_no_static_cls.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_no_static_cls.clas.abap)
