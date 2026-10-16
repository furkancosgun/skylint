# `require-subrc-check`

> **Category:** [Security & Robustness](/rules/#security) &nbsp;|&nbsp; **Severity:** `warning` &nbsp;|&nbsp; **Finding Code:** `CHECKSUBRC` &nbsp;|&nbsp; **QuickFix:** No

## Description

Check sy-subrc after DB, table and string operations.

## ❌ Non-Compliant Code

```abap
SELECT SINGLE * FROM /dmo/customer WHERE customer_id = @lv_id INTO @ls_customer.
process_customer( ls_customer ). " sy-subrc is never checked
```

## ✅ Compliant Code

```abap
SELECT SINGLE * FROM /dmo/customer WHERE customer_id = @lv_id INTO @ls_customer.
IF sy-subrc = 0.
  process_customer( ls_customer ).
ENDIF.
```

## 🤫 Suppression & Pseudo-Comments

To suppress findings for this rule, append the pseudo-comment or pragma to the statement:

```abap
" Using pseudo-comment:
... "#EC CHECK_SUBRC
" Or with SAP CI_ prefix:
... "#EC CI_CHECK_SUBRC

" Using pragma:
... ##CHECK_SUBRC.
" Or with SAP CI_ prefix:
... ##CI_CHECK_SUBRC.
```

## Configuration (`skylint.yaml`)

```yaml
checks:
  require-subrc-check:
    enabled: true
    severity: warning
```

## ABAP Class Details

* **Native ATC Class:** `ZCL_SKYLINT_CHECK_SUBRC`
* **Implementation File:** [zcl_skylint_check_subrc.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_check_subrc.clas.abap)
