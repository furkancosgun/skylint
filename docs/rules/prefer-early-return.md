# `prefer-early-return`

> **Category:** [Clean ABAP & Modern Syntax](/rules/#clean-abap) &nbsp;|&nbsp; **Severity:** `warning` &nbsp;|&nbsp; **Finding Code:** `GUARD_METH` &nbsp;|&nbsp; **QuickFix:** No

## Description

Use early RETURN guard clause instead of wrapping method in IF block.

## ❌ Non-Compliant Code

```abap
DATA lv_flag TYPE abap_bool.
DATA ls_val TYPE i.
IF lv_flag = abap_true.
ls_val = 1.
ENDIF.
```

## ✅ Compliant Code

```abap
DATA lv_flag TYPE abap_bool.
DATA ls_val TYPE i.
IF lv_flag = abap_true.
ls_val = 1.
ELSE.
ls_val = 2.
ENDIF.
```

## 🤫 Suppression & Pseudo-Comments

To suppress findings for this rule, append the pseudo-comment or pragma to the statement:

```abap
" Using pseudo-comment:
... "#EC EARLY_RETURN

" Using pragma:
... ##EARLY_RETURN.
```

## Configuration (`skylint.yaml`)

```yaml
checks:
  prefer-early-return:
    enabled: true
    severity: warning
```

## ABAP Class Details

* **Native ATC Class:** `ZCL_SKYLINT_PREF_EARLY_RET`
* **Implementation File:** [zcl_skylint_pref_early_ret.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_pref_early_ret.clas.abap)
