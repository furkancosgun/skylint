# `require-transporting`

> **Category:** [Performance & Database](/rules/#performance) &nbsp;|&nbsp; **Severity:** `warning` &nbsp;|&nbsp; **Finding Code:** `FULL_MODIF` &nbsp;|&nbsp; **QuickFix:** No

## Description

Avoid full-line MODIFY itab inside LOOP without TRANSPORTING clause.

## ❌ Non-Compliant Code

```abap
READ TABLE lt_items WITH KEY id = lv_id TRANSPORTING ALL FIELDS INTO ls_item.
```

## ✅ Compliant Code

```abap
READ TABLE lt_items WITH KEY id = lv_id TRANSPORTING NO FIELDS.
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
