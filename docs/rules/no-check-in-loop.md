# `no-check-in-loop`

> **Category:** [Anti-Patterns & Bad Practices](/rules/#anti-patterns) &nbsp;|&nbsp; **Severity:** `warning` &nbsp;|&nbsp; **Finding Code:** `CHKINLOOP` &nbsp;|&nbsp; **QuickFix:** ⚡ Yes

## Description

Avoid CHECK in loop/iteration structures (prefer IF ... CONTINUE).

## ❌ Non-Compliant Code

```abap
DATA lv_flag TYPE abap_bool.
DATA lt_tab TYPE string_table.
DATA ls_row TYPE string.
LOOP AT lt_tab INTO ls_row.
  CHECK lv_flag = abap_true.
ENDLOOP.
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
... "#EC CHECK_IN_LOOP

" Using pragma:
... ##CHECK_IN_LOOP.
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
