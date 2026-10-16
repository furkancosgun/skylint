# `no-empty-catch`

> **Category:** [Anti-Patterns & Bad Practices](/rules/#anti-patterns) &nbsp;|&nbsp; **Severity:** `warning` &nbsp;|&nbsp; **Finding Code:** `EMPTYCATCH` &nbsp;|&nbsp; **QuickFix:** No

## Description

Detect empty CATCH blocks swallowing exceptions.

## ❌ Non-Compliant Code

```abap
TRY.
CATCH cx_root.
ENDTRY.
```

## ✅ Compliant Code

```abap
DATA lv_x TYPE i.
TRY.
CATCH cx_root.
lv_x = 1.
ENDTRY.
```

## 🤫 Suppression & Pseudo-Comments

To suppress findings for this rule, append the pseudo-comment or pragma to the statement:

```abap
" Using pseudo-comment:
... "#EC NO_HANDLER

" Using pragma:
... ##NO_HANDLER.
```

## Configuration (`skylint.yaml`)

```yaml
checks:
  no-empty-catch:
    enabled: true
    severity: warning
```

## ABAP Class Details

* **Native ATC Class:** `ZCL_SKYLINT_NO_EMPTY_CATCH`
* **Implementation File:** [zcl_skylint_no_empty_catch.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_no_empty_catch.clas.abap)
