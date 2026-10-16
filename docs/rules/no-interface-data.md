# `no-interface-data`

> **Category:** [Anti-Patterns & Bad Practices](/rules/#anti-patterns) &nbsp;|&nbsp; **Severity:** `warning` &nbsp;|&nbsp; **Finding Code:** `INTF_DATA` &nbsp;|&nbsp; **QuickFix:** No

## Description

Avoid mutable DATA declarations in interfaces; allow only CONSTANTS.

## ❌ Non-Compliant Code

```abap
INTERFACE if_customer.
  DATA mv_id TYPE string.
ENDINTERFACE.
```

## ✅ Compliant Code

```abap
INTERFACE if_customer.
  METHODS get_id RETURNING VALUE(rv_id) TYPE string.
ENDINTERFACE.
```

## 🤫 Suppression & Pseudo-Comments

To suppress findings for this rule, append the pseudo-comment or pragma to the statement:

```abap
" Using pseudo-comment:
... "#EC INTF_DATA
" Or with SAP CI_ prefix:
... "#EC CI_INTF_DATA

" Using pragma:
... ##INTF_DATA.
" Or with SAP CI_ prefix:
... ##CI_INTF_DATA.
```

## Configuration (`skylint.yaml`)

```yaml
checks:
  no-interface-data:
    enabled: true
    severity: warning
```

## ABAP Class Details

* **Native ATC Class:** `ZCL_SKYLINT_NO_INTF_DATA`
* **Implementation File:** [zcl_skylint_no_intf_data.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_no_intf_data.clas.abap)
