# `no-unreachable-code`

> **Category:** [Anti-Patterns & Bad Practices](/rules/#anti-patterns) &nbsp;|&nbsp; **Severity:** `warning` &nbsp;|&nbsp; **Finding Code:** `UNREACHCD` &nbsp;|&nbsp; **QuickFix:** ⚡ Yes

## Description

Detect unreachable code following unconditional jump statements.

## ❌ Non-Compliant Code

```abap
DATA lv_x TYPE i.
RETURN.
lv_x = 1.
```

## ✅ Compliant Code

```abap
DATA lv_x TYPE i.
lv_x = 1.
RETURN.
```

## 🤫 Suppression & Pseudo-Comments

To suppress findings for this rule, append the pseudo-comment or pragma to the statement:

```abap
" Using pseudo-comment:
... "#EC UNREACHABLE

" Using pragma:
... ##UNREACHABLE.
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
