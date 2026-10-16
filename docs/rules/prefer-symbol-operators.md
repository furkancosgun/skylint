# `prefer-symbol-operators`

> **Category:** [Clean ABAP & Modern Syntax](/rules/#clean-abap) &nbsp;|&nbsp; **Severity:** `warning` &nbsp;|&nbsp; **Finding Code:** `PREFEROP` &nbsp;|&nbsp; **QuickFix:** ⚡ Yes

## Description

Prefer comparison operators (=, <>, <, >, <=, >=) over legacy textual keywords.

## ❌ Non-Compliant Code

```abap
IF lv_a EQ lv_b AND lv_c NE lv_d.
  process( ).
ENDIF.
```

## ✅ Compliant Code

```abap
IF lv_a = lv_b AND lv_c <> lv_d.
  process( ).
ENDIF.
```

## 🤫 Suppression & Pseudo-Comments

To suppress findings for this rule, append the pseudo-comment or pragma to the statement:

```abap
" Using pseudo-comment:
... "#EC SYMBOL_OP
" Or with SAP CI_ prefix:
... "#EC CI_SYMBOL_OP

" Using pragma:
... ##SYMBOL_OP.
" Or with SAP CI_ prefix:
... ##CI_SYMBOL_OP.
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
