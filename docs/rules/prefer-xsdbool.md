# `prefer-xsdbool`

> **Category:** [Clean ABAP & Modern Syntax](/rules/#clean-abap) &nbsp;|&nbsp; **Severity:** `warning` &nbsp;|&nbsp; **Finding Code:** `PREFERXSDB` &nbsp;|&nbsp; **QuickFix:** ⚡ Yes

## Description

Prefer xsdbool( ) expression over manual IF-ELSE assignment.

## ❌ Non-Compliant Code

```abap
IF lv_count > 0.
  lv_has_items = abap_true.
ELSE.
  lv_has_items = abap_false.
ENDIF.
```

## ✅ Compliant Code

```abap
lv_has_items = xsdbool( lv_count > 0 ).
```

## 🤫 Suppression & Pseudo-Comments

To suppress findings for this rule, append the pseudo-comment or pragma to the statement:

```abap
" Using pseudo-comment:
... "#EC XSDBOOL
" Or with SAP CI_ prefix:
... "#EC CI_XSDBOOL

" Using pragma:
... ##XSDBOOL.
" Or with SAP CI_ prefix:
... ##CI_XSDBOOL.
```

## Configuration (`skylint.yaml`)

```yaml
checks:
  prefer-xsdbool:
    enabled: true
    severity: warning
```

## ABAP Class Details

* **Native ATC Class:** `ZCL_SKYLINT_PREF_XSDBOOL`
* **Implementation File:** [zcl_skylint_pref_xsdbool.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_pref_xsdbool.clas.abap)
