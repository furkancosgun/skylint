# `no-magic-numbers`

> **Category:** [Anti-Patterns & Bad Practices](/rules/#anti-patterns) &nbsp;|&nbsp; **Severity:** `warning` &nbsp;|&nbsp; **Finding Code:** `MAGIC_NUM` &nbsp;|&nbsp; **QuickFix:** No

## Description

Avoid magic numbers in code; use named constants.

## ❌ Non-Compliant Code

```abap
DATA lv_val TYPE i.
lv_val = 42.
```

## ✅ Compliant Code

```abap
DATA lv_val TYPE i.
lv_val = 1.
```

## 🤫 Suppression & Pseudo-Comments

To suppress findings for this rule, append the pseudo-comment or pragma to the statement:

```abap
" Using pseudo-comment:
... "#EC MAGIC_NUMBERS

" Using pragma:
... ##MAGIC_NUMBERS.
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
