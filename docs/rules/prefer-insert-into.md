# `prefer-insert-into`

> **Category:** [Clean ABAP & Modern Syntax](/rules/#clean-abap) &nbsp;|&nbsp; **Severity:** `warning` &nbsp;|&nbsp; **Finding Code:** `PREF_INSRT` &nbsp;|&nbsp; **QuickFix:** ⚡ Yes

## Description

Prefer INSERT ... INTO TABLE over APPEND for table safety.

## ❌ Non-Compliant Code

```abap
APPEND ls_item TO lt_hashed_items.
```

## ✅ Compliant Code

```abap
INSERT ls_item INTO TABLE lt_hashed_items.
```

## 🤫 Suppression & Pseudo-Comments

To suppress findings for this rule, append the pseudo-comment or pragma to the statement:

```abap
" Using pseudo-comment:
... "#EC INSERT_INTO
" Or with SAP CI_ prefix:
... "#EC CI_INSERT_INTO

" Using pragma:
... ##INSERT_INTO.
" Or with SAP CI_ prefix:
... ##CI_INSERT_INTO.
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
