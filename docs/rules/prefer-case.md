# `prefer-case`

> **Category:** [Clean ABAP & Modern Syntax](/rules/#clean-abap) &nbsp;|&nbsp; **Severity:** `warning` &nbsp;|&nbsp; **Finding Code:** `USE_CASE` &nbsp;|&nbsp; **QuickFix:** No

## Description

Change IF to CASE when checking the same variable against multiple values.

## ❌ Non-Compliant Code

```abap
DATA lv_val TYPE i.
IF lv_val = 1.
  lv_val = 10.
ELSEIF lv_val = 2.
  lv_val = 20.
ELSEIF lv_val = 3.
  lv_val = 30.
ENDIF.
```

## ✅ Compliant Code

```abap
DATA lv_a TYPE i.
DATA lv_b TYPE i.
IF lv_a = 1.
  lv_a = 10.
ELSEIF lv_b = 2.
  lv_b = 20.
ENDIF.
```

## 🤫 Suppression & Pseudo-Comments

To suppress findings for this rule, append the pseudo-comment or pragma to the statement:

```abap
" Using pseudo-comment:
... "#EC PREF_CASE

" Using pragma:
... ##PREF_CASE.
```

## Configuration (`skylint.yaml`)

```yaml
checks:
  prefer-case:
    enabled: true
    severity: warning
```

## ABAP Class Details

* **Native ATC Class:** `ZCL_SKYLINT_PREF_CASE`
* **Implementation File:** [zcl_skylint_pref_case.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_pref_case.clas.abap)
