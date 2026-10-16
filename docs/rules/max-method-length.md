# `max-method-length`

> **Category:** [Metrics & Complexity Limits](/rules/#metrics) &nbsp;|&nbsp; **Severity:** `warning` &nbsp;|&nbsp; **Finding Code:** `METHOD_LEN` &nbsp;|&nbsp; **QuickFix:** No

## Description

Method Length Limit (excessive statement count).

## ❌ Non-Compliant Code

```abap
DATA lv_a TYPE i.
DATA lv_b TYPE i.
DATA lv_c TYPE i.
DATA lv_d TYPE i.
DATA lv_e TYPE i.
DATA lv_f TYPE i.
lv_a = 1.
lv_b = 2.
lv_c = 3.
lv_d = 4.
lv_e = 5.
lv_f = 6.
```

## ✅ Compliant Code

```abap
DATA lv_a TYPE i.
DATA lv_b TYPE i.
lv_a = 1.
lv_b = 2.
```

## 🤫 Suppression & Pseudo-Comments

To suppress findings for this rule, append the pseudo-comment or pragma to the statement:

```abap
" Using pseudo-comment:
... "#EC METHOD_LEN

" Using pragma:
... ##METHOD_LEN.
```

## Configuration (`skylint.yaml`)

```yaml
checks:
  max-method-length:
    enabled: true
    severity: warning
```

## ABAP Class Details

* **Native ATC Class:** `ZCL_SKYLINT_MAX_METHOD_LEN`
* **Implementation File:** [zcl_skylint_max_method_len.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_max_method_len.clas.abap)
