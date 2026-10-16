# `no-chained-assignment`

> **Category:** [Anti-Patterns & Bad Practices](/rules/#anti-patterns) &nbsp;|&nbsp; **Severity:** `warning` &nbsp;|&nbsp; **Finding Code:** `ASSIGNCHN` &nbsp;|&nbsp; **QuickFix:** ⚡ Yes

## Description

Avoid assignment chaining (a = b = c).

## ❌ Non-Compliant Code

```abap
lv_a = lv_b = lv_c = 0.
```

## ✅ Compliant Code

```abap
lv_a = 0.
lv_b = 0.
lv_c = 0.
```

## 🤫 Suppression & Pseudo-Comments

To suppress findings for this rule, append the pseudo-comment or pragma to the statement:

```abap
" Using pseudo-comment:
... "#EC CHAIN_ASSIGN
" Or with SAP CI_ prefix:
... "#EC CI_CHAIN_ASSIGN

" Using pragma:
... ##CHAIN_ASSIGN.
" Or with SAP CI_ prefix:
... ##CI_CHAIN_ASSIGN.
```

## Configuration (`skylint.yaml`)

```yaml
checks:
  no-chained-assignment:
    enabled: true
    severity: warning
```

## ABAP Class Details

* **Native ATC Class:** `ZCL_SKYLINT_NO_CHAIN_ASSIGN`
* **Implementation File:** [zcl_skylint_no_chain_assign.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_no_chain_assign.clas.abap)
