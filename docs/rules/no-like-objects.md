# `no-like-objects`

> **Category:** [Anti-Patterns & Bad Practices](/rules/#anti-patterns) &nbsp;|&nbsp; **Severity:** `warning` &nbsp;|&nbsp; **Finding Code:** `AVOID_LIKE` &nbsp;|&nbsp; **QuickFix:** No

## Description

Avoid LIKE referencing data objects; use explicit TYPE.

## ❌ Non-Compliant Code

```abap
DATA lv_customer LIKE ls_customer.
```

## ✅ Compliant Code

```abap
DATA lv_customer TYPE ty_customer.
```

## 🤫 Suppression & Pseudo-Comments

To suppress findings for this rule, append the pseudo-comment or pragma to the statement:

```abap
" Using pseudo-comment:
... "#EC LIKE_OBJECTS
" Or with SAP CI_ prefix:
... "#EC CI_LIKE_OBJECTS

" Using pragma:
... ##LIKE_OBJECTS.
" Or with SAP CI_ prefix:
... ##CI_LIKE_OBJECTS.
```

## Configuration (`skylint.yaml`)

```yaml
checks:
  no-like-objects:
    enabled: true
    severity: warning
```

## ABAP Class Details

* **Native ATC Class:** `ZCL_SKYLINT_NO_LIKE_OBJECTS`
* **Implementation File:** [zcl_skylint_no_like_objects.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_no_like_objects.clas.abap)
