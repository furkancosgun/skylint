# `max-method-length`

> **Category:** [Metrics & Complexity Limits](/rules/#metrics) &nbsp;|&nbsp; **Severity:** `warning` &nbsp;|&nbsp; **Finding Code:** `METHOD_LEN` &nbsp;|&nbsp; **QuickFix:** No

## Description

Method Length Limit (excessive statement count).

## ❌ Non-Compliant Code

```abap
" Large method exceeding configured statement threshold (> 50 statements)
METHOD execute.
  " 60+ statements in a single procedure...
ENDMETHOD.
```

## ✅ Compliant Code

```abap
" Split into smaller, single-responsibility helper methods
METHOD execute.
  prepare_data( ).
  process_records( ).
  finalize_result( ).
ENDMETHOD.
```

## 🤫 Suppression & Pseudo-Comments

To suppress findings for this rule, append the pseudo-comment or pragma to the statement:

```abap
" Using pseudo-comment:
... "#EC METHOD_LEN
" Or with SAP CI_ prefix:
... "#EC CI_METHOD_LEN

" Using pragma:
... ##METHOD_LEN.
" Or with SAP CI_ prefix:
... ##CI_METHOD_LEN.
```

## Configuration (`skylint.yaml`)

```yaml
checks:
  max-method-length:
    enabled: true
    severity: warning
```

## ABAP Class Details

* **Native ATC Class:** `ZCL_SKYLINT_MAX_METHOD_LEN`
* **Implementation File:** [zcl_skylint_max_method_len.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_max_method_len.clas.abap)
