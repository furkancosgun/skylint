# `prefer-lines`

> **Category:** [Clean ABAP & Modern Syntax](/rules/#clean-abap) &nbsp;|&nbsp; **Severity:** `warning` &nbsp;|&nbsp; **Finding Code:** `DESCRIBELN` &nbsp;|&nbsp; **QuickFix:** ⚡ Yes

## Description

Prefer lines( ) built-in function over DESCRIBE TABLE ... LINES.

## ❌ Non-Compliant Code

```abap
DATA lv_cnt TYPE i.
DATA lt_tab TYPE string_table.
DESCRIBE TABLE lt_tab LINES lv_cnt.
```

## ✅ Compliant Code

```abap
DATA lv_cnt TYPE i.
DATA lt_tab TYPE string_table.
lv_cnt = lines( lt_tab ).
```

## 🤫 Suppression & Pseudo-Comments

To suppress findings for this rule, append the pseudo-comment or pragma to the statement:

```abap
" Using pseudo-comment:
... "#EC LINES

" Using pragma:
... ##LINES.
```

## Configuration (`skylint.yaml`)

```yaml
checks:
  prefer-lines:
    enabled: true
    severity: warning
```

## ABAP Class Details

* **Native ATC Class:** `ZCL_SKYLINT_PREF_LINES`
* **Implementation File:** [zcl_skylint_pref_lines.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_pref_lines.clas.abap)
