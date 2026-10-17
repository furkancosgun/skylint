# `no-default-key`

> **Category:** [Anti-Patterns & Bad Practices](/rules/#anti-patterns) &nbsp;|&nbsp; **Severity:** `warning` &nbsp;|&nbsp; **Finding Code:** `DEFAULTKEY` &nbsp;|&nbsp; **QuickFix:** ⚡ Yes

## Description

Avoid WITH DEFAULT KEY; prefer EMPTY KEY or explicit keys.

## ❌ Non-Compliant Code

```abap
DATA lt_customers TYPE STANDARD TABLE OF ty_customer WITH DEFAULT KEY.
```

## ✅ Compliant Code

```abap
DATA lt_customers TYPE STANDARD TABLE OF ty_customer WITH EMPTY KEY.
```

## 🤫 Suppression & Pseudo-Comments

To suppress findings for this rule, append the pseudo-comment or pragma to the statement:

```abap
" Using pseudo-comment:
... "#EC DEFAULT_KEY
" Or with SAP CI_ prefix:
... "#EC CI_DEFAULT_KEY

" Using pragma:
... ##DEFAULT_KEY.
" Or with SAP CI_ prefix:
... ##CI_DEFAULT_KEY.
```

## Configuration (`skylint.yaml`)

```yaml
checks:
  no-default-key:
    enabled: true
    severity: warning
```

## ABAP Class Details

* **Native ATC Class:** `ZCL_SKYLINT_NO_DEFAULT_KEY`
* **Implementation File:** [zcl_skylint_no_default_key.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_no_default_key.clas.abap)
