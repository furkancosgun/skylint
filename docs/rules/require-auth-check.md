# `require-auth-check`

> **Category:** [Security & Robustness](/rules/#security) &nbsp;|&nbsp; **Severity:** `warning` &nbsp;|&nbsp; **Finding Code:** `AUTH_CHECK` &nbsp;|&nbsp; **QuickFix:** ⚡ Yes

## Description

Call Transaction Authority Check.

## ❌ Non-Compliant Code

```abap
SELECT * FROM /dmo/customer WHERE customer_id = @iv_id INTO TABLE @lt_customers.
```

## ✅ Compliant Code

```abap
AUTHORITY-CHECK OBJECT 'S_CUSTOMER' ID 'ACTVT' FIELD '03'.
IF sy-subrc = 0.
  SELECT * FROM /dmo/customer WHERE customer_id = @iv_id INTO TABLE @lt_customers.
ENDIF.
```

## 🤫 Suppression & Pseudo-Comments

To suppress findings for this rule, append the pseudo-comment or pragma to the statement:

```abap
" Using pseudo-comment:
... "#EC AUTH_CHECK
" Or with SAP CI_ prefix:
... "#EC CI_AUTH_CHECK

" Using pragma:
... ##AUTH_CHECK.
" Or with SAP CI_ prefix:
... ##CI_AUTH_CHECK.
```

## Configuration (`skylint.yaml`)

```yaml
checks:
  require-auth-check:
    enabled: true
    severity: warning
```

## ABAP Class Details

* **Native ATC Class:** `ZCL_SKYLINT_PREF_AUTH_CHECK`
* **Implementation File:** [zcl_skylint_pref_auth_check.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_pref_auth_check.clas.abap)
