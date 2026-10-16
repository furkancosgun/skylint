# `no-message-raising`

> **Category:** [Anti-Patterns & Bad Practices](/rules/#anti-patterns) &nbsp;|&nbsp; **Severity:** `warning` &nbsp;|&nbsp; **Finding Code:** `MSG_RAISE` &nbsp;|&nbsp; **QuickFix:** No

## Description

Avoid obsolete MESSAGE ... RAISING; use class-based exceptions.

## ❌ Non-Compliant Code

```abap
MESSAGE e001(00) WITH 'test' RAISING error.
```

## ✅ Compliant Code

```abap
MESSAGE 'clean' TYPE 'I'.
```

## 🤫 Suppression & Pseudo-Comments

To suppress findings for this rule, append the pseudo-comment or pragma to the statement:

```abap
" Using pseudo-comment:
... "#EC MSG_RAISING

" Using pragma:
... ##MSG_RAISING.
```

## Configuration (`skylint.yaml`)

```yaml
checks:
  no-message-raising:
    enabled: true
    severity: warning
```

## ABAP Class Details

* **Native ATC Class:** `ZCL_SKYLINT_NO_MSG_RAISING`
* **Implementation File:** [zcl_skylint_no_msg_raising.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_no_msg_raising.clas.abap)
