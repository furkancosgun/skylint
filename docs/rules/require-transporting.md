# `require-transporting`

> **Category:** [Performance & Database](/rules/#performance) &nbsp;|&nbsp; **Severity:** `warning` &nbsp;|&nbsp; **Finding Code:** `FULL_MODIF` &nbsp;|&nbsp; **QuickFix:** No

## Description

Avoid full-line MODIFY itab inside LOOP without TRANSPORTING clause.

## ❌ Non-Compliant Code

```abap
LOOP AT lt_items INTO ls_item.
  ls_item-status = 'DONE'.
  MODIFY lt_items FROM ls_item. " Full line copy without specifying TRANSPORTING
ENDLOOP.
```

## ✅ Compliant Code

```abap
LOOP AT lt_items INTO ls_item.
  ls_item-status = 'DONE'.
  MODIFY lt_items FROM ls_item TRANSPORTING status.
ENDLOOP.
```

## 🤫 Suppression & Pseudo-Comments

To suppress findings for this rule, append the pseudo-comment or pragma to the statement:

```abap
" Using pseudo-comment:
... "#EC TRANSPORTING
" Or with SAP CI_ prefix:
... "#EC CI_TRANSPORTING

" Using pragma:
... ##TRANSPORTING.
" Or with SAP CI_ prefix:
... ##CI_TRANSPORTING.
```

## Configuration (`skylint.yaml`)

```yaml
checks:
  require-transporting:
    enabled: true
    severity: warning
```

## ABAP Class Details

* **Native ATC Class:** `ZCL_SKYLINT_PREF_TRANSPORT`
* **Implementation File:** [zcl_skylint_pref_transport.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_pref_transport.clas.abap)
