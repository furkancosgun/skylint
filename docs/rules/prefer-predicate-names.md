# `prefer-predicate-names`

> **Category:** [Clean ABAP & Modern Syntax](/rules/#clean-abap) &nbsp;|&nbsp; **Severity:** `warning` &nbsp;|&nbsp; **Finding Code:** `BOOL_NAME` &nbsp;|&nbsp; **QuickFix:** No

## Description

Enforce predicate naming (IS_, HAS_, CAN_) on boolean methods.

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
... "#EC PRED_NAME

" Using pragma:
... ##PRED_NAME.
```

## Configuration (`skylint.yaml`)

```yaml
checks:
  prefer-predicate-names:
    enabled: true
    severity: warning
```

## ABAP Class Details

* **Native ATC Class:** `ZCL_SKYLINT_PREF_PRED_NAME`
* **Implementation File:** [zcl_skylint_pref_pred_name.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_pref_pred_name.clas.abap)
