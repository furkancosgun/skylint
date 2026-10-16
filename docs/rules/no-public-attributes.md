# `no-public-attributes`

> **Category:** [Anti-Patterns & Bad Practices](/rules/#anti-patterns) &nbsp;|&nbsp; **Severity:** `warning` &nbsp;|&nbsp; **Finding Code:** `NOPUBATTR` &nbsp;|&nbsp; **QuickFix:** No

## Description

Avoid mutable public attributes in classes.

## ❌ Non-Compliant Code

```abap
CLASS cl_model DEFINITION PUBLIC.
  PUBLIC SECTION.
    DATA mv_state TYPE i.
ENDCLASS.
```

## ✅ Compliant Code

```abap
CLASS cl_model DEFINITION PUBLIC.
  PUBLIC SECTION.
    METHODS get_state RETURNING VALUE(rv_state) TYPE i.
  PRIVATE SECTION.
    DATA mv_state TYPE i.
ENDCLASS.
```

## 🤫 Suppression & Pseudo-Comments

To suppress findings for this rule, append the pseudo-comment or pragma to the statement:

```abap
" Using pseudo-comment:
... "#EC PUBLIC_ATTR
" Or with SAP CI_ prefix:
... "#EC CI_PUBLIC_ATTR

" Using pragma:
... ##PUBLIC_ATTR.
" Or with SAP CI_ prefix:
... ##CI_PUBLIC_ATTR.
```

## Configuration (`skylint.yaml`)

```yaml
checks:
  no-public-attributes:
    enabled: true
    severity: warning
```

## ABAP Class Details

* **Native ATC Class:** `ZCL_SKYLINT_NO_PUBLIC_ATTR`
* **Implementation File:** [zcl_skylint_no_public_attr.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_no_public_attr.clas.abap)
