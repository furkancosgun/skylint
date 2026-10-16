# `no-empty-block`

> **Category:** [Anti-Patterns & Bad Practices](/rules/#anti-patterns) &nbsp;|&nbsp; **Severity:** `warning` &nbsp;|&nbsp; **Finding Code:** `EMPTYCTRL` &nbsp;|&nbsp; **QuickFix:** No

## Description

Detect empty control blocks (IF, CASE, LOOP, TRY, etc.).

## ❌ Non-Compliant Code

```abap
DATA lv_x TYPE i.
IF lv_x = 1.
ENDIF.
```

## ✅ Compliant Code

```abap
DATA lv_x TYPE i.
IF lv_x = 1.
lv_x = 2.
ENDIF.
```

## 🤫 Suppression & Pseudo-Comments

To suppress findings for this rule, append the pseudo-comment or pragma to the statement:

```abap
" Using pseudo-comment:
... "#EC EMPTY_BLOCK

" Using pragma:
... ##EMPTY_BLOCK.
```

## Configuration (`skylint.yaml`)

```yaml
checks:
  no-empty-block:
    enabled: true
    severity: warning
```

## ABAP Class Details

* **Native ATC Class:** `ZCL_SKYLINT_NO_EMPTY_BLOCK`
* **Implementation File:** [zcl_skylint_no_empty_block.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_no_empty_block.clas.abap)
