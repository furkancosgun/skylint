# `no-call-method`

> **Category:** [Anti-Patterns & Bad Practices](/rules/#anti-patterns) &nbsp;|&nbsp; **Severity:** `warning` &nbsp;|&nbsp; **Finding Code:** `CALLMETHOD` &nbsp;|&nbsp; **QuickFix:** ⚡ Yes

## Description

Avoid static CALL METHOD statements.

## ❌ Non-Compliant Code

```abap
CALL METHOD lo_service->calculate_tax(
  EXPORTING
    iv_amount = lv_amount ).
```

## ✅ Compliant Code

```abap
lo_service->calculate_tax( iv_amount = lv_amount ).
```

## 🤫 Suppression & Pseudo-Comments

To suppress findings for this rule, append the pseudo-comment or pragma to the statement:

```abap
" Using pseudo-comment:
... "#EC CALL_METH
" Or with SAP CI_ prefix:
... "#EC CI_CALL_METH

" Using pragma:
... ##CALL_METH.
" Or with SAP CI_ prefix:
... ##CI_CALL_METH.
```

## Configuration (`skylint.yaml`)

```yaml
checks:
  no-call-method:
    enabled: true
    severity: warning
```

## ABAP Class Details

* **Native ATC Class:** `ZCL_SKYLINT_NO_CALL_METHOD`
* **Implementation File:** [zcl_skylint_no_call_method.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_no_call_method.clas.abap)
