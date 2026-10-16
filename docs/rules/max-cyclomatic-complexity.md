# `max-cyclomatic-complexity`

> **Category:** [Metrics & Complexity Limits](/rules/#metrics) &nbsp;|&nbsp; **Severity:** `warning` &nbsp;|&nbsp; **Finding Code:** `CYCLO_COMP` &nbsp;|&nbsp; **QuickFix:** No

## Description

Cyclomatic Complexity Threshold.

## ❌ Non-Compliant Code

```abap
DATA lv_a TYPE i.
DATA lv_b TYPE i.
DATA lv_c TYPE i.
DATA lv_d TYPE i.
DATA lv_e TYPE i.
IF lv_a = 1.
ENDIF.
IF lv_b = 2.
ENDIF.
IF lv_c = 3.
ENDIF.
IF lv_d = 4.
ENDIF.
IF lv_e = 5.
ENDIF.
```

## ✅ Compliant Code

```abap
DATA lv_a TYPE i.
IF lv_a = 1.
ENDIF.
```

## 🤫 Suppression & Pseudo-Comments

To suppress findings for this rule, append the pseudo-comment or pragma to the statement:

```abap
" Using pseudo-comment:
... "#EC CYCLO_COMP

" Using pragma:
... ##CYCLO_COMP.
```

## Configuration (`skylint.yaml`)

```yaml
checks:
  max-cyclomatic-complexity:
    enabled: true
    severity: warning
```

## ABAP Class Details

* **Native ATC Class:** `ZCL_SKYLINT_MAX_CYCLO_COMP`
* **Implementation File:** [zcl_skylint_max_cyclo_comp.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_max_cyclo_comp.clas.abap)
