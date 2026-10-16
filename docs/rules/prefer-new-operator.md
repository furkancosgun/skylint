# `prefer-new-operator`

> **Category:** [Clean ABAP & Modern Syntax](/rules/#clean-abap) &nbsp;|&nbsp; **Severity:** `warning` &nbsp;|&nbsp; **Finding Code:** `PREFERNEW` &nbsp;|&nbsp; **QuickFix:** ⚡ Yes

## Description

Prefer NEW #( ) constructor expression over legacy CREATE OBJECT.

## ❌ Non-Compliant Code

```abap
DATA lo_obj TYPE REF TO zcl_skylint_test_022.
CREATE OBJECT lo_obj.
```

## ✅ Compliant Code

```abap
DATA lo_obj TYPE REF TO zcl_skylint_test_022.
DATA lv_cls TYPE string.
CREATE OBJECT lo_obj TYPE (lv_cls).
```

## 🤫 Suppression & Pseudo-Comments

To suppress findings for this rule, append the pseudo-comment or pragma to the statement:

```abap
" Using pseudo-comment:
... "#EC NEW_OP

" Using pragma:
... ##NEW_OP.
```

## Configuration (`skylint.yaml`)

```yaml
checks:
  prefer-new-operator:
    enabled: true
    severity: warning
```

## ABAP Class Details

* **Native ATC Class:** `ZCL_SKYLINT_PREF_NEW_OP`
* **Implementation File:** [zcl_skylint_pref_new_op.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_pref_new_op.clas.abap)
