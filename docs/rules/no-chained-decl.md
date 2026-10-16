# `no-chained-decl`

> **Category:** [Anti-Patterns & Bad Practices](/rules/#anti-patterns) &nbsp;|&nbsp; **Severity:** `warning` &nbsp;|&nbsp; **Finding Code:** `CHAINDECL` &nbsp;|&nbsp; **QuickFix:** ⚡ Yes

## Description

Avoid chained declarations (DATA:, TYPES:, etc.).

## ❌ Non-Compliant Code

```abap
DATA: lv_id   TYPE string,
      lv_name TYPE string.
```

## ✅ Compliant Code

```abap
DATA lv_id   TYPE string.
DATA lv_name TYPE string.
```

## 🤫 Suppression & Pseudo-Comments

To suppress findings for this rule, append the pseudo-comment or pragma to the statement:

```abap
" Using pseudo-comment:
... "#EC CHAIN_DECL
" Or with SAP CI_ prefix:
... "#EC CI_CHAIN_DECL

" Using pragma:
... ##CHAIN_DECL.
" Or with SAP CI_ prefix:
... ##CI_CHAIN_DECL.
```

## Configuration (`skylint.yaml`)

```yaml
checks:
  no-chained-decl:
    enabled: true
    severity: warning
```

## ABAP Class Details

* **Native ATC Class:** `ZCL_SKYLINT_NO_CHAIN_DECL`
* **Implementation File:** [zcl_skylint_no_chain_decl.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_no_chain_decl.clas.abap)
