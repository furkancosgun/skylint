# `no-single-when`

> **Category:** [Anti-Patterns & Bad Practices](/rules/#anti-patterns) &nbsp;|&nbsp; **Severity:** `warning` &nbsp;|&nbsp; **Finding Code:** `SHORTCASE` &nbsp;|&nbsp; **QuickFix:** No

## Description

Avoid short CASE constructs with only one WHEN branch; prefer IF.

## ❌ Non-Compliant Code

```abap
CASE lv_status.
  WHEN 'A'.
    process_a( ).
ENDCASE.
```

## ✅ Compliant Code

```abap
IF lv_status = 'A'.
  process_a( ).
ENDIF.
```

## 🤫 Suppression & Pseudo-Comments

To suppress findings for this rule, append the pseudo-comment or pragma to the statement:

```abap
" Using pseudo-comment:
... "#EC SINGLE_WHEN
" Or with SAP CI_ prefix:
... "#EC CI_SINGLE_WHEN

" Using pragma:
... ##SINGLE_WHEN.
" Or with SAP CI_ prefix:
... ##CI_SINGLE_WHEN.
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
