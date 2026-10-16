# `no-magic-numbers`

> **Category:** [Anti-Patterns & Bad Practices](/rules/#anti-patterns) &nbsp;|&nbsp; **Severity:** `warning` &nbsp;|&nbsp; **Finding Code:** `MAGIC_NUM` &nbsp;|&nbsp; **QuickFix:** No

## Description

Avoid magic numbers in code; use named constants.

## ❌ Non-Compliant Code

```abap
IF lv_status = 3.
  process( ).
ENDIF.
```

## ✅ Compliant Code

```abap
CONSTANTS c_status_completed TYPE i VALUE 3.
IF lv_status = c_status_completed.
  process( ).
ENDIF.
```

## 🤫 Suppression & Pseudo-Comments

To suppress findings for this rule, append the pseudo-comment or pragma to the statement:

```abap
" Using pseudo-comment:
... "#EC MAGIC_NUMBERS
" Or with SAP CI_ prefix:
... "#EC CI_MAGIC_NUMBERS

" Using pragma:
... ##MAGIC_NUMBERS.
" Or with SAP CI_ prefix:
... ##CI_MAGIC_NUMBERS.
```

## Configuration (`skylint.yaml`)

```yaml
checks:
  no-magic-numbers:
    enabled: true
    severity: warning
```

## ABAP Class Details

* **Native ATC Class:** `ZCL_SKYLINT_NO_MAGIC_NUMBERS`
* **Implementation File:** [zcl_skylint_no_magic_numbers.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_no_magic_numbers.clas.abap)
