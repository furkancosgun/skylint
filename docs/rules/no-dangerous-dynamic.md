# `no-dangerous-dynamic`

> **Category:** [Security & Robustness](/rules/#security) &nbsp;|&nbsp; **Severity:** `warning` &nbsp;|&nbsp; **Finding Code:** `DANGER_STM` &nbsp;|&nbsp; **QuickFix:** No

## Description

Dangerous / Unmanaged Dynamic Statements.

## ❌ Non-Compliant Code

```abap
DATA lv_msg TYPE string.
DATA lv_lin TYPE i.
DATA lv_wrd TYPE string.
DATA lt_prog TYPE string_table.
SYNTAX-CHECK FOR lt_prog MESSAGE lv_msg LINE lv_lin WORD lv_wrd.
```

## ✅ Compliant Code

```abap
DATA lv_flag TYPE abap_bool.
CHECK lv_flag = abap_true.
```

## 🤫 Suppression & Pseudo-Comments

To suppress findings for this rule, append the pseudo-comment or pragma to the statement:

```abap
" Using pseudo-comment:
... "#EC DYNAMIC_STMT

" Using pragma:
... ##DYNAMIC_STMT.
```

## Configuration (`skylint.yaml`)

```yaml
checks:
  no-dangerous-dynamic:
    enabled: true
    severity: warning
```

## ABAP Class Details

* **Native ATC Class:** `ZCL_SKYLINT_NO_DYNAMIC_STMT`
* **Implementation File:** [zcl_skylint_no_dynamic_stmt.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_no_dynamic_stmt.clas.abap)
