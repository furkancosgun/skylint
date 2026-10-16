# `prefer-line-exists`

> **Category:** [Clean ABAP & Modern Syntax](/rules/#clean-abap) &nbsp;|&nbsp; **Severity:** `warning` &nbsp;|&nbsp; **Finding Code:** `PREFLINEX` &nbsp;|&nbsp; **QuickFix:** No

## Description

Prefer line_exists( ) over READ TABLE ... TRANSPORTING NO FIELDS.

## ❌ Non-Compliant Code

```abap
READ TABLE lt_items TRANSPORTING NO FIELDS WITH KEY id = lv_id.
IF sy-subrc = 0.
  process( ).
ENDIF.
```

## ✅ Compliant Code

```abap
IF line_exists( lt_items[ id = lv_id ] ).
  process( ).
ENDIF.
```

## 🤫 Suppression & Pseudo-Comments

To suppress findings for this rule, append the pseudo-comment or pragma to the statement:

```abap
" Using pseudo-comment:
... "#EC LINE_EXISTS
" Or with SAP CI_ prefix:
... "#EC CI_LINE_EXISTS

" Using pragma:
... ##LINE_EXISTS.
" Or with SAP CI_ prefix:
... ##CI_LINE_EXISTS.
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
