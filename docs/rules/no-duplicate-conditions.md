# `no-duplicate-conditions`

> **Category:** [Anti-Patterns & Bad Practices](/rules/#anti-patterns) &nbsp;|&nbsp; **Severity:** `warning` &nbsp;|&nbsp; **Finding Code:** `DUPCOND` &nbsp;|&nbsp; **QuickFix:** No

## Description

Detect identical branch conditions in IF/ELSEIF and CASE/WHEN.

## ❌ Non-Compliant Code

```abap
IF lv_type = 'A' OR lv_type = 'A'.
  process( ).
ENDIF.
```

## ✅ Compliant Code

```abap
IF lv_type = 'A'.
  process( ).
ENDIF.
```

## 🤫 Suppression & Pseudo-Comments

To suppress findings for this rule, append the pseudo-comment or pragma to the statement:

```abap
" Using pseudo-comment:
... "#EC DUP_COND
" Or with SAP CI_ prefix:
... "#EC CI_DUP_COND

" Using pragma:
... ##DUP_COND.
" Or with SAP CI_ prefix:
... ##CI_DUP_COND.
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
