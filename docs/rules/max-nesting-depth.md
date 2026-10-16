# `max-nesting-depth`

> **Category:** [Metrics & Complexity Limits](/rules/#metrics) &nbsp;|&nbsp; **Severity:** `warning` &nbsp;|&nbsp; **Finding Code:** `NESTING_DP` &nbsp;|&nbsp; **QuickFix:** No

## Description

Nesting Depth Limit (excessive control block nesting).

## ❌ Non-Compliant Code

```abap
DATA lv_a TYPE i.
DATA lv_b TYPE i.
DATA lv_c TYPE i.
DATA lv_d TYPE i.
IF lv_a = 1.
IF lv_b = 2.
IF lv_c = 3.
IF lv_d = 4.
ENDIF.
ENDIF.
ENDIF.
ENDIF.
```

## ✅ Compliant Code

```abap
DATA lv_a TYPE i.
DATA lv_b TYPE i.
IF lv_a = 1.
IF lv_b = 2.
ENDIF.
ENDIF.
```

## 🤫 Suppression & Pseudo-Comments

To suppress findings for this rule, append the pseudo-comment or pragma to the statement:

```abap
" Using pseudo-comment:
... "#EC NESTING

" Using pragma:
... ##NESTING.
```

## Configuration (`skylint.yaml`)

```yaml
checks:
  max-nesting-depth:
    enabled: true
    severity: warning
```

## ABAP Class Details

* **Native ATC Class:** `ZCL_SKYLINT_MAX_NESTING`
* **Implementation File:** [zcl_skylint_max_nesting.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_max_nesting.clas.abap)
