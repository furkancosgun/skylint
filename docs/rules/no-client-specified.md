# `no-client-specified`

> **Category:** [Security & Robustness](/rules/#security) &nbsp;|&nbsp; **Severity:** `warning` &nbsp;|&nbsp; **Finding Code:** `CLIENT_SPE` &nbsp;|&nbsp; **QuickFix:** ⚡ Yes

## Description

Avoid USING CLIENT or CLIENT SPECIFIED in ABAP SQL.

## ❌ Non-Compliant Code

```abap
SELECT * FROM /dmo/customer CLIENT SPECIFIED INTO TABLE @lt_customers.
```

## ✅ Compliant Code

```abap
SELECT * FROM /dmo/customer INTO TABLE @lt_customers.
```

## 🤫 Suppression & Pseudo-Comments

To suppress findings for this rule, append the pseudo-comment or pragma to the statement:

```abap
" Using pseudo-comment:
... "#EC CLIENT_SPEC
" Or with SAP CI_ prefix:
... "#EC CI_CLIENT_SPEC

" Using pragma:
... ##CLIENT_SPEC.
" Or with SAP CI_ prefix:
... ##CI_CLIENT_SPEC.
```

## Configuration (`skylint.yaml`)

```yaml
checks:
  no-client-specified:
    enabled: true
    severity: warning
```

## ABAP Class Details

* **Native ATC Class:** `ZCL_SKYLINT_NO_CLIENT_SPEC`
* **Implementation File:** [zcl_skylint_no_client_spec.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_no_client_spec.clas.abap)
