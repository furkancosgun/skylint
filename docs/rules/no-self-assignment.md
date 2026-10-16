# `no-self-assignment`

> **Category:** [Anti-Patterns & Bad Practices](/rules/#anti-patterns) &nbsp;|&nbsp; **Severity:** `warning` &nbsp;|&nbsp; **Finding Code:** `IDENTMOVE` &nbsp;|&nbsp; **QuickFix:** ⚡ Yes

## Description

Detect Identical Self Assignments.

## ❌ Non-Compliant Code

```abap
lv_name = lv_name.
```

## ✅ Compliant Code

```abap
lv_name = iv_new_name.
```

## 🤫 Suppression & Pseudo-Comments

To suppress findings for this rule, append the pseudo-comment or pragma to the statement:

```abap
" Using pseudo-comment:
... "#EC SELF_ASSIGN
" Or with SAP CI_ prefix:
... "#EC CI_SELF_ASSIGN

" Using pragma:
... ##SELF_ASSIGN.
" Or with SAP CI_ prefix:
... ##CI_SELF_ASSIGN.
```

## Configuration (`skylint.yaml`)

```yaml
checks:
  no-self-assignment:
    enabled: true
    severity: warning
```

## ABAP Class Details

* **Native ATC Class:** `ZCL_SKYLINT_NO_SELF_ASSIGN`
* **Implementation File:** [zcl_skylint_no_self_assign.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_no_self_assign.clas.abap)
