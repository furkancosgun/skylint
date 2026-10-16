# `no-raise-shortdump`

> **Category:** [Anti-Patterns & Bad Practices](/rules/#anti-patterns) &nbsp;|&nbsp; **Severity:** `warning` &nbsp;|&nbsp; **Finding Code:** `SHORTDUMP` &nbsp;|&nbsp; **QuickFix:** No

## Description

Avoid RAISE SHORTDUMP (prefer graceful exceptions).

## ❌ Non-Compliant Code

```abap
RAISE SHORTDUMP TYPE cx_fatal.
```

## ✅ Compliant Code

```abap
RAISE EXCEPTION NEW cx_fatal( ).
```

## 🤫 Suppression & Pseudo-Comments

To suppress findings for this rule, append the pseudo-comment or pragma to the statement:

```abap
" Using pseudo-comment:
... "#EC SHORTDUMP
" Or with SAP CI_ prefix:
... "#EC CI_SHORTDUMP

" Using pragma:
... ##SHORTDUMP.
" Or with SAP CI_ prefix:
... ##CI_SHORTDUMP.
```

## Configuration (`skylint.yaml`)

```yaml
checks:
  no-raise-shortdump:
    enabled: true
    severity: warning
```

## ABAP Class Details

* **Native ATC Class:** `ZCL_SKYLINT_NO_SHORTDUMP`
* **Implementation File:** [zcl_skylint_no_shortdump.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_no_shortdump.clas.abap)
