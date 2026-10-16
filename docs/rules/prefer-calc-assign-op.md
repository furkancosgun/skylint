# `prefer-calc-assign-op`

> **Category:** [Clean ABAP & Modern Syntax](/rules/#clean-abap) &nbsp;|&nbsp; **Severity:** `warning` &nbsp;|&nbsp; **Finding Code:** `CALC_ASSGN` &nbsp;|&nbsp; **QuickFix:** ⚡ Yes

## Description

Prefer calculation assignment operators (+=, -=, *=, /=) over var = var + 1.

## ❌ Non-Compliant Code

```abap
DATA lv_x TYPE i.
lv_x = lv_x + 1.
```

## ✅ Compliant Code

```abap
DATA lv_x TYPE i.
lv_x = 10.
```

## 🤫 Suppression & Pseudo-Comments

To suppress findings for this rule, append the pseudo-comment or pragma to the statement:

```abap
" Using pseudo-comment:
... "#EC CALC_ASSIGN

" Using pragma:
... ##CALC_ASSIGN.
```

## Configuration (`skylint.yaml`)

```yaml
checks:
  prefer-calc-assign-op:
    enabled: true
    severity: warning
```

## ABAP Class Details

* **Native ATC Class:** `ZCL_SKYLINT_PREF_CALC_OP`
* **Implementation File:** [zcl_skylint_pref_calc_op.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_pref_calc_op.clas.abap)
