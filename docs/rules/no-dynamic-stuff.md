# `no-dynamic-stuff`

> **Category:** [Security & Robustness](/rules/#security) &nbsp;|&nbsp; **Severity:** `warning` &nbsp;|&nbsp; **Finding Code:** `DYN_STUFF` &nbsp;|&nbsp; **QuickFix:** No

## Description

No Dynamic Constructs (CALL, ASSIGN, CREATE, etc.).

## ❌ Non-Compliant Code

```abap
CALL FUNCTION lv_func_name.
```

## ✅ Compliant Code

```abap
CALL FUNCTION 'BAPI_USER_GET_DETAIL'.
```

## 🤫 Suppression & Pseudo-Comments

To suppress findings for this rule, append the pseudo-comment or pragma to the statement:

```abap
" Using pseudo-comment:
... "#EC NO_DYNAMIC
" Or with SAP CI_ prefix:
... "#EC CI_NO_DYNAMIC

" Using pragma:
... ##NO_DYNAMIC.
" Or with SAP CI_ prefix:
... ##CI_NO_DYNAMIC.
```

## Configuration (`skylint.yaml`)

```yaml
checks:
  no-dynamic-stuff:
    enabled: true
    severity: warning
```

## ABAP Class Details

* **Native ATC Class:** `ZCL_SKYLINT_NO_DYNAMIC_STMT`
* **Implementation File:** [zcl_skylint_no_dynamic_stmt.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_no_dynamic_stmt.clas.abap)
