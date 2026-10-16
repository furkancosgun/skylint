# `no-single-when`

> **Category:** [Anti-Patterns & Bad Practices](/rules/#anti-patterns) &nbsp;|&nbsp; **Severity:** `warning` &nbsp;|&nbsp; **Finding Code:** `SHORTCASE` &nbsp;|&nbsp; **QuickFix:** No

## Description

Avoid short CASE constructs with only one WHEN branch; prefer IF.

## ❌ Non-Compliant Code

```abap
DATA lv_x TYPE i.
DATA lv_type TYPE i.
CASE lv_type.
WHEN 1.
lv_x = 1.
ENDCASE.
```

## ✅ Compliant Code

```abap
DATA lv_x TYPE i.
DATA lv_type TYPE i.
CASE lv_type.
WHEN 1.
lv_x = 1.
WHEN 2.
lv_x = 2.
ENDCASE.
```

## 🤫 Suppression & Pseudo-Comments

To suppress findings for this rule, append the pseudo-comment or pragma to the statement:

```abap
" Using pseudo-comment:
... "#EC SINGLE_WHEN

" Using pragma:
... ##SINGLE_WHEN.
```

## Configuration (`skylint.yaml`)

```yaml
checks:
  no-single-when:
    enabled: true
    severity: warning
```

## ABAP Class Details

* **Native ATC Class:** `ZCL_SKYLINT_NO_SINGLE_WHEN`
* **Implementation File:** [zcl_skylint_no_single_when.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_no_single_when.clas.abap)
