# `dangerous-statement`

> **Category:** [Security & Robustness](/rules/#security) &nbsp;|&nbsp; **Severity:** `warning` &nbsp;|&nbsp; **Finding Code:** `DANGER_STM` &nbsp;|&nbsp; **QuickFix:** No

## Description

Dangerous Statements (abaplint dangerous_statement).

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
... "#EC DANGEROUS_STMT
" Or with SAP CI_ prefix:
... "#EC CI_DANGEROUS_STMT

" Using pragma:
... ##DANGEROUS_STMT.
" Or with SAP CI_ prefix:
... ##CI_DANGEROUS_STMT.
```

## Configuration (`skylint.yaml`)

```yaml
checks:
  dangerous-statement:
    enabled: true
    severity: warning
```

## ABAP Class Details

* **Native ATC Class:** `ZCL_SKYLINT_NO_DANGEROUS_STMT`
* **Implementation File:** [zcl_skylint_no_dangerous_stmt.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_no_dangerous_stmt.clas.abap)
