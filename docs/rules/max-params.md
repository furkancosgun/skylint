# `max-params`

> **Category:** [Metrics & Complexity Limits](/rules/#metrics) &nbsp;|&nbsp; **Severity:** `warning` &nbsp;|&nbsp; **Finding Code:** `PARAMCOUNT` &nbsp;|&nbsp; **QuickFix:** No

## Description

Method signature cleanliness (excessive parameter count).

## ❌ Non-Compliant Code

```abap
METHODS execute
  IMPORTING p1 TYPE i p2 TYPE i p3 TYPE i p4 TYPE i p5 TYPE i p6 TYPE i.
```

## ✅ Compliant Code

```abap
METHODS execute
  IMPORTING is_options TYPE ty_options.
```

## 🤫 Suppression & Pseudo-Comments

To suppress findings for this rule, append the pseudo-comment or pragma to the statement:

```abap
" Using pseudo-comment:
... "#EC MAX_PARAMS
" Or with SAP CI_ prefix:
... "#EC CI_MAX_PARAMS

" Using pragma:
... ##MAX_PARAMS.
" Or with SAP CI_ prefix:
... ##CI_MAX_PARAMS.
```

## Configuration (`skylint.yaml`)

```yaml
checks:
  max-params:
    enabled: true
    severity: warning
```

## ABAP Class Details

* **Native ATC Class:** `ZCL_SKYLINT_MAX_PARAMS`
* **Implementation File:** [zcl_skylint_max_params.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_max_params.clas.abap)
