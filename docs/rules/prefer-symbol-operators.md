# `prefer-symbol-operators`

> **Category:** [Clean ABAP & Modern Syntax](/rules/#clean-abap) &nbsp;|&nbsp; **Severity:** `warning` &nbsp;|&nbsp; **Finding Code:** `PREFEROP` &nbsp;|&nbsp; **QuickFix:** ⚡ Yes

## Description

Prefer comparison operators (=, <>, <, >, <=, >=) over legacy textual keywords.

## ❌ Non-Compliant Code

```abap
DATA lv_a TYPE i.
DATA lv_b TYPE i.
IF lv_a EQ lv_b.
ENDIF.
```

## ✅ Compliant Code

```abap
DATA lv_a TYPE i.
DATA lv_b TYPE i.
IF lv_a = lv_b.
ENDIF.
```

## 🤫 Suppression & Pseudo-Comments

To suppress findings for this rule, append the pseudo-comment or pragma to the statement:

```abap
" Using pseudo-comment:
... "#EC SYMBOL_OP

" Using pragma:
... ##SYMBOL_OP.
```

## Configuration (`skylint.yaml`)

```yaml
checks:
  prefer-symbol-operators:
    enabled: true
    severity: warning
```

## ABAP Class Details

* **Native ATC Class:** `ZCL_SKYLINT_PREF_SYMBOL_OP`
* **Implementation File:** [zcl_skylint_pref_symbol_op.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_pref_symbol_op.clas.abap)
