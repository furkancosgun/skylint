# `prefer-corresponding`

> **Category:** [Clean ABAP & Modern Syntax](/rules/#clean-abap) &nbsp;|&nbsp; **Severity:** `warning` &nbsp;|&nbsp; **Finding Code:** `PREFER_COR` &nbsp;|&nbsp; **QuickFix:** ⚡ Yes

## Description

Prefer CORRESPONDING Expression over MOVE-CORRESPONDING.

## ❌ Non-Compliant Code

```abap
DATA: BEGIN OF ls_src, a TYPE i, END OF ls_src.
DATA: BEGIN OF ls_dst, a TYPE i, END OF ls_dst.
MOVE-CORRESPONDING ls_src TO ls_dst.
```

## ✅ Compliant Code

```abap
DATA: BEGIN OF ls_src, a TYPE i, END OF ls_src.
DATA: BEGIN OF ls_dst, a TYPE i, END OF ls_dst.
ls_dst = CORRESPONDING #( ls_src ).
```

## 🤫 Suppression & Pseudo-Comments

To suppress findings for this rule, append the pseudo-comment or pragma to the statement:

```abap
" Using pseudo-comment:
... "#EC CORRESP

" Using pragma:
... ##CORRESP.
```

## Configuration (`skylint.yaml`)

```yaml
checks:
  prefer-corresponding:
    enabled: true
    severity: warning
```

## ABAP Class Details

* **Native ATC Class:** `ZCL_SKYLINT_PREF_CORRESP`
* **Implementation File:** [zcl_skylint_pref_corresp.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_pref_corresp.clas.abap)
