# `no-production-assert`

> **Category:** [Security & Robustness](/rules/#security) &nbsp;|&nbsp; **Severity:** `warning` &nbsp;|&nbsp; **Finding Code:** `PROD_ASSRT` &nbsp;|&nbsp; **QuickFix:** No

## Description

Detect native ASSERT in production code; use exceptions instead.

## ❌ Non-Compliant Code

```abap
ASSERT lv_amount >= 0. " Triggers runtime shortdump in production if false
```

## ✅ Compliant Code

```abap
IF lv_amount < 0.
  RAISE EXCEPTION NEW cx_invalid_amount( ).
ENDIF.
```

## 🤫 Suppression & Pseudo-Comments

To suppress findings for this rule, append the pseudo-comment or pragma to the statement:

```abap
" Using pseudo-comment:
... "#EC PROD_ASSERT
" Or with SAP CI_ prefix:
... "#EC CI_PROD_ASSERT

" Using pragma:
... ##PROD_ASSERT.
" Or with SAP CI_ prefix:
... ##CI_PROD_ASSERT.
```

## Configuration (`skylint.yaml`)

```yaml
checks:
  no-production-assert:
    enabled: true
    severity: warning
```

## ABAP Class Details

* **Native ATC Class:** `ZCL_SKYLINT_NO_PROD_ASSERT`
* **Implementation File:** [zcl_skylint_no_prod_assert.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_no_prod_assert.clas.abap)
