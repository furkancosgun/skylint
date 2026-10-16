# `no-receiving`

> **Category:** [Anti-Patterns & Bad Practices](/rules/#anti-patterns) &nbsp;|&nbsp; **Severity:** `warning` &nbsp;|&nbsp; **Finding Code:** `OMITRECEIV` &nbsp;|&nbsp; **QuickFix:** ⚡ Yes

## Description

Omit RECEIVING in method calls.

## ❌ Non-Compliant Code

```abap
lo_calc->compute( RECEIVING rv_result = lv_result ).
```

## ✅ Compliant Code

```abap
lv_result = lo_calc->compute( ).
```

## 🤫 Suppression & Pseudo-Comments

To suppress findings for this rule, append the pseudo-comment or pragma to the statement:

```abap
" Using pseudo-comment:
... "#EC RECEIVING
" Or with SAP CI_ prefix:
... "#EC CI_RECEIVING

" Using pragma:
... ##RECEIVING.
" Or with SAP CI_ prefix:
... ##CI_RECEIVING.
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
