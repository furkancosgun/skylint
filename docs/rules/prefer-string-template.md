# `prefer-string-template`

> **Category:** [Clean ABAP & Modern Syntax](/rules/#clean-abap) &nbsp;|&nbsp; **Severity:** `warning` &nbsp;|&nbsp; **Finding Code:** `CONCATSTR` &nbsp;|&nbsp; **QuickFix:** ⚡ Yes

## Description

Prefer string templates over CONCATENATE.

## ❌ Non-Compliant Code

```abap
DATA lv_a TYPE string.
DATA lv_b TYPE string.
DATA lv_c TYPE string.
CONCATENATE lv_a lv_b INTO lv_c.
```

## ✅ Compliant Code

```abap
DATA lv_a TYPE string.
DATA lv_b TYPE string.
DATA lv_c TYPE string.
lv_c = |{ lv_a }{ lv_b }|.
```

## 🤫 Suppression & Pseudo-Comments

To suppress findings for this rule, append the pseudo-comment or pragma to the statement:

```abap
" Using pseudo-comment:
... "#EC STR_TMPL

" Using pragma:
... ##STR_TMPL.
```

## Configuration (`skylint.yaml`)

```yaml
checks:
  prefer-string-template:
    enabled: true
    severity: warning
```

## ABAP Class Details

* **Native ATC Class:** `ZCL_SKYLINT_PREF_STR_TMPL`
* **Implementation File:** [zcl_skylint_pref_str_tmpl.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_pref_str_tmpl.clas.abap)
