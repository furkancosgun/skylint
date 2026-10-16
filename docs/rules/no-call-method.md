# `no-call-method`

> **Category:** [Anti-Patterns & Bad Practices](/rules/#anti-patterns) &nbsp;|&nbsp; **Severity:** `warning` &nbsp;|&nbsp; **Finding Code:** `CALLMETHOD` &nbsp;|&nbsp; **QuickFix:** ⚡ Yes

## Description

Avoid static CALL METHOD statements.

## ❌ Non-Compliant Code

```abap
DATA lo_obj TYPE REF TO zcl_skylint_test_002.
CALL METHOD lo_obj->run.
```

## ✅ Compliant Code

```abap
DATA lo_obj TYPE REF TO zcl_skylint_test_002.
lo_obj->run( ).
```

## 🤫 Suppression & Pseudo-Comments

To suppress findings for this rule, append the pseudo-comment or pragma to the statement:

```abap
" Using pseudo-comment:
... "#EC CALL_METH

" Using pragma:
... ##CALL_METH.
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
