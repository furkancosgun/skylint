# `prefer-early-continue`

> **Category:** [Clean ABAP & Modern Syntax](/rules/#clean-abap) &nbsp;|&nbsp; **Severity:** `warning` &nbsp;|&nbsp; **Finding Code:** `GUARD_LOOP` &nbsp;|&nbsp; **QuickFix:** No

## Description

Use early CONTINUE guard clause instead of wrapping loop in IF block.

## ❌ Non-Compliant Code

```abap
DATA lt_tab TYPE STANDARD TABLE OF ty_row WITH DEFAULT KEY.
DATA ls_row TYPE ty_row.
DATA ls_val TYPE i.
LOOP AT lt_tab INTO ls_row.
  IF ls_row-flag = abap_true.
    ls_val = 1.
  ENDIF.
ENDLOOP.
```

## ✅ Compliant Code

```abap
DATA lt_tab TYPE STANDARD TABLE OF ty_row WITH DEFAULT KEY.
DATA ls_row TYPE ty_row.
DATA ls_val TYPE i.
LOOP AT lt_tab INTO ls_row.
  ls_val = 1.
ENDLOOP.
```

## 🤫 Suppression & Pseudo-Comments

To suppress findings for this rule, append the pseudo-comment or pragma to the statement:

```abap
" Using pseudo-comment:
... "#EC EARLY_CONTINUE

" Using pragma:
... ##EARLY_CONTINUE.
```

## Configuration (`skylint.yaml`)

```yaml
checks:
  prefer-early-continue:
    enabled: true
    severity: warning
```

## ABAP Class Details

* **Native ATC Class:** `ZCL_SKYLINT_PREF_EARLY_CONT`
* **Implementation File:** [zcl_skylint_pref_early_cont.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_pref_early_cont.clas.abap)
