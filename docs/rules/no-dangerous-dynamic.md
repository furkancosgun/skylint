# `no-dangerous-dynamic`

> **Category:** [Security & Robustness](/rules/#security) &nbsp;|&nbsp; **Severity:** `warning` &nbsp;|&nbsp; **Finding Code:** `DANGER_STM` &nbsp;|&nbsp; **QuickFix:** No

## Description

Dangerous / Unmanaged Dynamic Statements.

## ❌ Non-Compliant Code

```abap
EXEC SQL.
  SELECT * FROM /dmo/customer INTO :wa
ENDEXEC.
```

## ✅ Compliant Code

```abap
SELECT * FROM /dmo/customer INTO TABLE @lt_customers.
```

## 🤫 Suppression & Pseudo-Comments

To suppress findings for this rule, append the pseudo-comment or pragma to the statement:

```abap
" Using pseudo-comment:
... "#EC DYNAMIC_STMT
" Or with SAP CI_ prefix:
... "#EC CI_DYNAMIC_STMT

" Using pragma:
... ##DYNAMIC_STMT.
" Or with SAP CI_ prefix:
... ##CI_DYNAMIC_STMT.
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
