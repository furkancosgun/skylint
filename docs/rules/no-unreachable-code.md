# `no-unreachable-code`

> **Category:** [Anti-Patterns & Bad Practices](/rules/#anti-patterns) &nbsp;|&nbsp; **Severity:** `warning` &nbsp;|&nbsp; **Finding Code:** `UNREACHCD` &nbsp;|&nbsp; **QuickFix:** ⚡ Yes

## Description

Detect unreachable code following unconditional jump statements.

## ❌ Non-Compliant Code

```abap
RETURN.
lv_count = lv_count + 1. " Unreachable statement
```

## ✅ Compliant Code

```abap
lv_count = lv_count + 1.
RETURN.
```

## 🤫 Suppression & Pseudo-Comments

To suppress findings for this rule, append the pseudo-comment or pragma to the statement:

```abap
" Using pseudo-comment:
... "#EC UNREACHABLE
" Or with SAP CI_ prefix:
... "#EC CI_UNREACHABLE

" Using pragma:
... ##UNREACHABLE.
" Or with SAP CI_ prefix:
... ##CI_UNREACHABLE.
```

## Configuration (`skylint.yaml`)

```yaml
checks:
  no-unreachable-code:
    enabled: true
    severity: warning
```

## ABAP Class Details

* **Native ATC Class:** `ZCL_SKYLINT_NO_UNREACHABLE`
* **Implementation File:** [zcl_skylint_no_unreachable.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_no_unreachable.clas.abap)
