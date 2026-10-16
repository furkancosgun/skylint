# `max-nesting-depth`

> **Category:** [Metrics & Complexity Limits](/rules/#metrics) &nbsp;|&nbsp; **Severity:** `warning` &nbsp;|&nbsp; **Finding Code:** `NESTING_DP` &nbsp;|&nbsp; **QuickFix:** No

## Description

Nesting Depth Limit (excessive control block nesting).

## ❌ Non-Compliant Code

```abap
IF cond1.
  IF cond2.
    IF cond3.
      IF cond4.
        execute( ).
      ENDIF.
    ENDIF.
  ENDIF.
ENDIF.
```

## ✅ Compliant Code

```abap
IF NOT cond1 OR NOT cond2 OR NOT cond3 OR NOT cond4.
  RETURN.
ENDIF.
execute( ).
```

## 🤫 Suppression & Pseudo-Comments

To suppress findings for this rule, append the pseudo-comment or pragma to the statement:

```abap
" Using pseudo-comment:
... "#EC NESTING
" Or with SAP CI_ prefix:
... "#EC CI_NESTING

" Using pragma:
... ##NESTING.
" Or with SAP CI_ prefix:
... ##CI_NESTING.
```

## Configuration (`skylint.yaml`)

```yaml
checks:
  max-nesting-depth:
    enabled: true
    severity: warning
```

## ABAP Class Details

* **Native ATC Class:** `ZCL_SKYLINT_MAX_NESTING`
* **Implementation File:** [zcl_skylint_max_nesting.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_max_nesting.clas.abap)
