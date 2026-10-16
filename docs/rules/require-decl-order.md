# `require-decl-order`

> **Category:** [Clean ABAP & Modern Syntax](/rules/#clean-abap) &nbsp;|&nbsp; **Severity:** `warning` &nbsp;|&nbsp; **Finding Code:** `DECL_ORDER` &nbsp;|&nbsp; **QuickFix:** No

## Description

Enforce local declaration order (TYPES -> CONSTANTS -> DATA -> FIELD-SYMBOLS).

## ❌ Non-Compliant Code

```abap
DATA lv_x TYPE i.
TYPES ty_t TYPE i.
```

## ✅ Compliant Code

```abap
TYPES ty_t TYPE i.
DATA lv_x TYPE i.
```

## 🤫 Suppression & Pseudo-Comments

To suppress findings for this rule, append the pseudo-comment or pragma to the statement:

```abap
" Using pseudo-comment:
... "#EC DECL_ORDER

" Using pragma:
... ##DECL_ORDER.
```

## Configuration (`skylint.yaml`)

```yaml
checks:
  require-decl-order:
    enabled: true
    severity: warning
```

## ABAP Class Details

* **Native ATC Class:** `ZCL_SKYLINT_PREF_DECL_ORDER`
* **Implementation File:** [zcl_skylint_pref_decl_order.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_pref_decl_order.clas.abap)
