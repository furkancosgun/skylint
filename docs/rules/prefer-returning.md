# `prefer-returning`

> **Category:** [Clean ABAP & Modern Syntax](/rules/#clean-abap) &nbsp;|&nbsp; **Severity:** `warning` &nbsp;|&nbsp; **Finding Code:** `PREFER_RET` &nbsp;|&nbsp; **QuickFix:** No

## Description

Prefer RETURNING over single EXPORTING.

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
... "#EC RETURNING

" Using pragma:
... ##RETURNING.
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
