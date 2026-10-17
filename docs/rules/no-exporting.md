# `no-exporting`

> **Category:** [Anti-Patterns & Bad Practices](/rules/#anti-patterns) &nbsp;|&nbsp; **Severity:** `warning` &nbsp;|&nbsp; **Finding Code:** `OMITEXPORT` &nbsp;|&nbsp; **QuickFix:** ⚡ Yes

## Description

Omit redundant EXPORTING and RECEIVING in method calls.

## ❌ Non-Compliant Code

```abap
lo_calc->compute( EXPORTING iv_val = 10 ).
```

## ✅ Compliant Code

```abap
lo_calc->compute( iv_val = 10 ).
```

## 🤫 Suppression & Pseudo-Comments

To suppress findings for this rule, append the pseudo-comment or pragma to the statement:

```abap
" Using pseudo-comment:
... "#EC EXPORTING
" Or with SAP CI_ prefix:
... "#EC CI_EXPORTING

" Using pragma:
... ##EXPORTING.
" Or with SAP CI_ prefix:
... ##CI_EXPORTING.
```

## Configuration (`skylint.yaml`)

```yaml
checks:
  no-exporting:
    enabled: true
    severity: warning
```

## ABAP Class Details

* **Native ATC Class:** `ZCL_SKYLINT_NO_EXPORTING`
* **Implementation File:** [zcl_skylint_no_exporting.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_no_exporting.clas.abap)
