# `prefer-return`

> **Category:** [Clean ABAP & Modern Syntax](/rules/#clean-abap) &nbsp;|&nbsp; **Severity:** `warning` &nbsp;|&nbsp; **Finding Code:** `EXITOUTLP` &nbsp;|&nbsp; **QuickFix:** ⚡ Yes

## Description

Prefer RETURN over EXIT outside loop constructs.

## ❌ Non-Compliant Code

```abap
EXIT.
```

## ✅ Compliant Code

```abap
DATA lt_tab TYPE string_table.
DATA ls_row TYPE string.
LOOP AT lt_tab INTO ls_row.
EXIT.
ENDLOOP.
```

## 🤫 Suppression & Pseudo-Comments

To suppress findings for this rule, append the pseudo-comment or pragma to the statement:

```abap
" Using pseudo-comment:
... "#EC RETURN

" Using pragma:
... ##RETURN.
```

## Configuration (`skylint.yaml`)

```yaml
checks:
  prefer-return:
    enabled: true
    severity: warning
```

## ABAP Class Details

* **Native ATC Class:** `ZCL_SKYLINT_PREF_RETURN`
* **Implementation File:** [zcl_skylint_pref_return.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_pref_return.clas.abap)
