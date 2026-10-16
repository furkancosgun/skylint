# `require-transporting`

> **Category:** [Performance & Database](/rules/#performance) &nbsp;|&nbsp; **Severity:** `warning` &nbsp;|&nbsp; **Finding Code:** `FULL_MODIF` &nbsp;|&nbsp; **QuickFix:** No

## Description

Avoid full-line MODIFY itab inside LOOP without TRANSPORTING clause.

## ❌ Non-Compliant Code

```abap
DATA lt_tab TYPE STANDARD TABLE OF ty_row WITH DEFAULT KEY.
DATA ls_row TYPE ty_row.
LOOP AT lt_tab INTO ls_row.
  MODIFY lt_tab FROM ls_row.
ENDLOOP.
```

## ✅ Compliant Code

```abap
DATA lt_tab TYPE STANDARD TABLE OF ty_row WITH DEFAULT KEY.
DATA ls_row TYPE ty_row.
LOOP AT lt_tab INTO ls_row.
  MODIFY lt_tab FROM ls_row TRANSPORTING field1.
ENDLOOP.
```

## 🤫 Suppression & Pseudo-Comments

To suppress findings for this rule, append the pseudo-comment or pragma to the statement:

```abap
" Using pseudo-comment:
... "#EC TRANSPORTING

" Using pragma:
... ##TRANSPORTING.
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
