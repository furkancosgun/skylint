# `prefer-final-method`

> **Category:** [Clean ABAP & Modern Syntax](/rules/#clean-abap) &nbsp;|&nbsp; **Severity:** `warning` &nbsp;|&nbsp; **Finding Code:** `PREF_FINAL` &nbsp;|&nbsp; **QuickFix:** ⚡ Yes

## Description

Prefer marking non-overridden methods as FINAL.

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
... "#EC FINAL_METHOD

" Using pragma:
... ##FINAL_METHOD.
```

## Configuration (`skylint.yaml`)

```yaml
checks:
  prefer-final-method:
    enabled: true
    severity: warning
```

## ABAP Class Details

* **Native ATC Class:** `ZCL_SKYLINT_PREF_FINAL_METH`
* **Implementation File:** [zcl_skylint_pref_final_meth.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_pref_final_meth.clas.abap)
