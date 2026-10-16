# `no-message-raising`

> **Category:** [Anti-Patterns & Bad Practices](/rules/#anti-patterns) &nbsp;|&nbsp; **Severity:** `warning` &nbsp;|&nbsp; **Finding Code:** `MSG_RAISE` &nbsp;|&nbsp; **QuickFix:** No

## Description

Avoid obsolete MESSAGE ... RAISING; use class-based exceptions.

## ❌ Non-Compliant Code

```abap
MESSAGE e001(zmsg) RAISING not_found.
```

## ✅ Compliant Code

```abap
RAISE EXCEPTION NEW cx_not_found( textid = cx_not_found=>c_item_missing ).
```

## 🤫 Suppression & Pseudo-Comments

To suppress findings for this rule, append the pseudo-comment or pragma to the statement:

```abap
" Using pseudo-comment:
... "#EC MSG_RAISING
" Or with SAP CI_ prefix:
... "#EC CI_MSG_RAISING

" Using pragma:
... ##MSG_RAISING.
" Or with SAP CI_ prefix:
... ##CI_MSG_RAISING.
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
