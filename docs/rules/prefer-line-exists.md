# `prefer-line-exists`

> **Category:** [Clean ABAP & Modern Syntax](/rules/#clean-abap) &nbsp;|&nbsp; **Severity:** `warning` &nbsp;|&nbsp; **Finding Code:** `PREFLINEX` &nbsp;|&nbsp; **QuickFix:** No

## Description

Prefer line_exists( ) over READ TABLE ... TRANSPORTING NO FIELDS.

## ❌ Non-Compliant Code

```abap
DATA lt_tab TYPE string_table.
READ TABLE lt_tab TRANSPORTING NO FIELDS WITH KEY table_line = ''.
```

## ✅ Compliant Code

```abap
DATA lt_tab TYPE string_table.
DATA ls_row TYPE string.
READ TABLE lt_tab INTO ls_row INDEX 1.
```

## 🤫 Suppression & Pseudo-Comments

To suppress findings for this rule, append the pseudo-comment or pragma to the statement:

```abap
" Using pseudo-comment:
... "#EC LINE_EXISTS

" Using pragma:
... ##LINE_EXISTS.
```

## Configuration (`skylint.yaml`)

```yaml
checks:
  prefer-line-exists:
    enabled: true
    severity: warning
```

## ABAP Class Details

* **Native ATC Class:** `ZCL_SKYLINT_PREF_LINE_EXISTS`
* **Implementation File:** [zcl_skylint_pref_line_exists.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_pref_line_exists.clas.abap)
