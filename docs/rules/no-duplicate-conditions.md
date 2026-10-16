# `no-duplicate-conditions`

> **Category:** [Anti-Patterns & Bad Practices](/rules/#anti-patterns) &nbsp;|&nbsp; **Severity:** `warning` &nbsp;|&nbsp; **Finding Code:** `DUPCOND` &nbsp;|&nbsp; **QuickFix:** No

## Description

Detect identical branch conditions in IF/ELSEIF and CASE/WHEN.

## ❌ Non-Compliant Code

```abap
DATA lv_a TYPE i.
DATA lv_b TYPE i.
DATA lv_c TYPE i.
IF lv_a = 1.
lv_b = 2.
ELSEIF lv_a = 1.
lv_c = 3.
ENDIF.
```

## ✅ Compliant Code

```abap
DATA lv_a TYPE i.
DATA lv_b TYPE i.
DATA lv_c TYPE i.
IF lv_a = 1.
lv_b = 2.
ELSEIF lv_a = 2.
lv_c = 3.
ENDIF.
```

## 🤫 Suppression & Pseudo-Comments

To suppress findings for this rule, append the pseudo-comment or pragma to the statement:

```abap
" Using pseudo-comment:
... "#EC DUP_COND

" Using pragma:
... ##DUP_COND.
```

## Configuration (`skylint.yaml`)

```yaml
checks:
  no-duplicate-conditions:
    enabled: true
    severity: warning
```

## ABAP Class Details

* **Native ATC Class:** `ZCL_SKYLINT_NO_DUP_COND`
* **Implementation File:** [zcl_skylint_no_dup_cond.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_no_dup_cond.clas.abap)
