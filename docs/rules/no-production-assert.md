# `no-production-assert`

> **Category:** [Security & Robustness](/rules/#security) &nbsp;|&nbsp; **Severity:** `warning` &nbsp;|&nbsp; **Finding Code:** `PROD_ASSRT` &nbsp;|&nbsp; **QuickFix:** No

## Description

Detect native ASSERT in production code; use exceptions instead.

## ❌ Non-Compliant Code

```abap
DATA lv_x TYPE i.
ASSERT lv_x > 0.
```

## ✅ Compliant Code

```abap
DATA lv_x TYPE i.
IF lv_x IS INITIAL.
ENDIF.
```

## 🤫 Suppression & Pseudo-Comments

To suppress findings for this rule, append the pseudo-comment or pragma to the statement:

```abap
" Using pseudo-comment:
... "#EC PROD_ASSERT

" Using pragma:
... ##PROD_ASSERT.
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
