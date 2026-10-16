# `no-check-in-loop`

> **Category:** [Anti-Patterns & Bad Practices](/rules/#anti-patterns) &nbsp;|&nbsp; **Severity:** `warning` &nbsp;|&nbsp; **Finding Code:** `CHKINLOOP` &nbsp;|&nbsp; **QuickFix:** ⚡ Yes

## Description

Avoid CHECK in loop/iteration structures (prefer IF ... CONTINUE).

## ❌ Non-Compliant Code

```abap
LOOP AT lt_items INTO ls_item.
  CHECK ls_item-status = 'ACTIVE'.
  process( ls_item ).
ENDLOOP.
```

## ✅ Compliant Code

```abap
LOOP AT lt_items INTO ls_item.
  IF ls_item-status <> 'ACTIVE'.
    CONTINUE.
  ENDIF.
  process( ls_item ).
ENDLOOP.
```

## 🤫 Suppression & Pseudo-Comments

To suppress findings for this rule, append the pseudo-comment or pragma to the statement:

```abap
" Using pseudo-comment:
... "#EC CHECK_IN_LOOP
" Or with SAP CI_ prefix:
... "#EC CI_CHECK_IN_LOOP

" Using pragma:
... ##CHECK_IN_LOOP.
" Or with SAP CI_ prefix:
... ##CI_CHECK_IN_LOOP.
```

## Configuration (`skylint.yaml`)

```yaml
checks:
  no-check-in-loop:
    enabled: true
    severity: warning
```

## ABAP Class Details

* **Native ATC Class:** `ZCL_SKYLINT_NO_CHECK_IN_LOOP`
* **Implementation File:** [zcl_skylint_no_check_in_loop.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_no_check_in_loop.clas.abap)
