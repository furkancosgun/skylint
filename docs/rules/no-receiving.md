# `no-receiving`

> **Category:** [Anti-Patterns & Bad Practices](/rules/#anti-patterns) &nbsp;|&nbsp; **Severity:** `warning` &nbsp;|&nbsp; **Finding Code:** `OMITRECEIV` &nbsp;|&nbsp; **QuickFix:** ⚡ Yes

## Description

Omit RECEIVING in method calls.

## ❌ Non-Compliant Code

```abap
DATA lo_obj TYPE REF TO zcl_skylint_test_025.
DATA lv_x TYPE i.
lo_obj->run( RECEIVING rv_val = lv_x ).
```

## ✅ Compliant Code

```abap
DATA lo_obj TYPE REF TO zcl_skylint_test_025.
DATA lv_x TYPE i.
CALL METHOD lo_obj->run RECEIVING rv_val = lv_x.
```

## 🤫 Suppression & Pseudo-Comments

To suppress findings for this rule, append the pseudo-comment or pragma to the statement:

```abap
" Using pseudo-comment:
... "#EC RECEIVING

" Using pragma:
... ##RECEIVING.
```

## Configuration (`skylint.yaml`)

```yaml
checks:
  no-receiving:
    enabled: true
    severity: warning
```

## ABAP Class Details

* **Native ATC Class:** `ZCL_SKYLINT_NO_RECEIVING`
* **Implementation File:** [zcl_skylint_no_receiving.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_no_receiving.clas.abap)
