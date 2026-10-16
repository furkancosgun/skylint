# `no-yoda-conditions`

> **Category:** [Anti-Patterns & Bad Practices](/rules/#anti-patterns) &nbsp;|&nbsp; **Severity:** `warning` &nbsp;|&nbsp; **Finding Code:** `YODACOND` &nbsp;|&nbsp; **QuickFix:** ⚡ Yes

## Description

Avoid Yoda conditions in comparison expressions.

## ❌ Non-Compliant Code

```abap
IF 0 = lv_count.
  process( ).
ENDIF.
```

## ✅ Compliant Code

```abap
IF lv_count = 0.
  process( ).
ENDIF.
```

## 🤫 Suppression & Pseudo-Comments

To suppress findings for this rule, append the pseudo-comment or pragma to the statement:

```abap
" Using pseudo-comment:
... "#EC YODA_COND
" Or with SAP CI_ prefix:
... "#EC CI_YODA_COND

" Using pragma:
... ##YODA_COND.
" Or with SAP CI_ prefix:
... ##CI_YODA_COND.
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
