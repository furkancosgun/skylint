# `no-inline-length`

> **Category:** [Anti-Patterns & Bad Practices](/rules/#anti-patterns) &nbsp;|&nbsp; **Severity:** `warning` &nbsp;|&nbsp; **Finding Code:** `PAREN_LEN` &nbsp;|&nbsp; **QuickFix:** ⚡ Yes

## Description

Avoid inline length specification in declarations.

## ❌ Non-Compliant Code

```abap
DATA lv_code(10) TYPE c.
```

## ✅ Compliant Code

```abap
DATA lv_code TYPE c LENGTH 10.
```

## 🤫 Suppression & Pseudo-Comments

To suppress findings for this rule, append the pseudo-comment or pragma to the statement:

```abap
" Using pseudo-comment:
... "#EC PAREN_LEN
" Or with SAP CI_ prefix:
... "#EC CI_PAREN_LEN

" Using pragma:
... ##PAREN_LEN.
" Or with SAP CI_ prefix:
... ##CI_PAREN_LEN.
```

## Configuration (`skylint.yaml`)

```yaml
checks:
  no-inline-length:
    enabled: true
    severity: warning
```

## ABAP Class Details

* **Native ATC Class:** `ZCL_SKYLINT_NO_INLINE_LEN`
* **Implementation File:** [zcl_skylint_no_inline_len.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_no_inline_len.clas.abap)
