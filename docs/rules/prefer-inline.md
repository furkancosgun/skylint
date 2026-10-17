# `prefer-inline`

> **Category:** [Clean ABAP & Modern Syntax](/rules/#clean-abap) &nbsp;|&nbsp; **Severity:** `warning` &nbsp;|&nbsp; **Finding Code:** `PREF_INL` &nbsp;|&nbsp; **QuickFix:** No

## Description

Prefer Inline Declarations.

## ❌ Non-Compliant Code

```abap
DATA lv_count TYPE i.
lv_count = 10.
```

## ✅ Compliant Code

```abap
DATA(lv_count) = 10.
```

## 🤫 Suppression & Pseudo-Comments

To suppress findings for this rule, append the pseudo-comment or pragma to the statement:

```abap
" Using pseudo-comment:
... "#EC PREFER_INLINE
" Or with SAP CI_ prefix:
... "#EC CI_PREFER_INLINE

" Using pragma:
... ##PREFER_INLINE.
" Or with SAP CI_ prefix:
... ##CI_PREFER_INLINE.
```

## Configuration (`skylint.yaml`)

```yaml
checks:
  prefer-inline:
    enabled: true
    severity: warning
```

## ABAP Class Details

* **Native ATC Class:** `ZCL_SKYLINT_PREF_INLINE`
* **Implementation File:** [zcl_skylint_pref_inline.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_pref_inline.clas.abap)
