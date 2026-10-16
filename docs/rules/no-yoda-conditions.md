# `no-yoda-conditions`

> **Category:** [Anti-Patterns & Bad Practices](/rules/#anti-patterns) &nbsp;|&nbsp; **Severity:** `warning` &nbsp;|&nbsp; **Finding Code:** `YODACOND` &nbsp;|&nbsp; **QuickFix:** ⚡ Yes

## Description

Avoid Yoda conditions in comparison expressions.

## ❌ Non-Compliant Code

```abap
DATA lv_code TYPE c LENGTH 1.
IF 'X' = lv_code.
ENDIF.
```

## ✅ Compliant Code

```abap
DATA lv_code TYPE c LENGTH 1.
IF lv_code = 'X'.
ENDIF.
```

## 🤫 Suppression & Pseudo-Comments

To suppress findings for this rule, append the pseudo-comment or pragma to the statement:

```abap
" Using pseudo-comment:
... "#EC YODA_COND

" Using pragma:
... ##YODA_COND.
```

## Configuration (`skylint.yaml`)

```yaml
checks:
  no-yoda-conditions:
    enabled: true
    severity: warning
```

## ABAP Class Details

* **Native ATC Class:** `ZCL_SKYLINT_NO_YODA_COND`
* **Implementation File:** [zcl_skylint_no_yoda_cond.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_no_yoda_cond.clas.abap)
