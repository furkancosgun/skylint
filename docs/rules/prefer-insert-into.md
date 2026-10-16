# `prefer-insert-into`

> **Category:** [Clean ABAP & Modern Syntax](/rules/#clean-abap) &nbsp;|&nbsp; **Severity:** `warning` &nbsp;|&nbsp; **Finding Code:** `PREF_INSRT` &nbsp;|&nbsp; **QuickFix:** ⚡ Yes

## Description

Prefer INSERT ... INTO TABLE over APPEND for table safety.

## ❌ Non-Compliant Code

```abap
DATA lt_tab TYPE string_table.
DATA ls_row TYPE string.
APPEND ls_row TO lt_tab.
```

## ✅ Compliant Code

```abap
DATA lt_tab TYPE string_table.
DATA ls_row TYPE string.
INSERT ls_row INTO TABLE lt_tab.
```

## 🤫 Suppression & Pseudo-Comments

To suppress findings for this rule, append the pseudo-comment or pragma to the statement:

```abap
" Using pseudo-comment:
... "#EC INSERT_INTO

" Using pragma:
... ##INSERT_INTO.
```

## Configuration (`skylint.yaml`)

```yaml
checks:
  prefer-insert-into:
    enabled: true
    severity: warning
```

## ABAP Class Details

* **Native ATC Class:** `ZCL_SKYLINT_PREF_INSERT`
* **Implementation File:** [zcl_skylint_pref_insert.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_pref_insert.clas.abap)
