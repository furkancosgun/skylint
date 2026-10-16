# `max-cyclomatic-complexity`

> **Category:** [Metrics & Complexity Limits](/rules/#metrics) &nbsp;|&nbsp; **Severity:** `warning` &nbsp;|&nbsp; **Finding Code:** `CYCLO_COMP` &nbsp;|&nbsp; **QuickFix:** No

## Description

Cyclomatic Complexity Threshold.

## ❌ Non-Compliant Code

```abap
" Complex method containing excessive branches (> 10 cyclomatic complexity)
METHOD compute.
  IF c1. ... ELSEIF c2. ... ELSEIF c3. ...
ENDMETHOD.
```

## ✅ Compliant Code

```abap
" Decompose into strategy classes or cohesive helper methods
METHOD compute.
  ro_strategy = mo_factory->get_strategy( mv_type ).
  ro_strategy->execute( ).
ENDMETHOD.
```

## 🤫 Suppression & Pseudo-Comments

To suppress findings for this rule, append the pseudo-comment or pragma to the statement:

```abap
" Using pseudo-comment:
... "#EC CYCLO_COMP
" Or with SAP CI_ prefix:
... "#EC CI_CYCLO_COMP

" Using pragma:
... ##CYCLO_COMP.
" Or with SAP CI_ prefix:
... ##CI_CYCLO_COMP.
```

## Configuration (`skylint.yaml`)

```yaml
checks:
  max-cyclomatic-complexity:
    enabled: true
    severity: warning
```

## ABAP Class Details

* **Native ATC Class:** `ZCL_SKYLINT_MAX_CYCLO_COMP`
* **Implementation File:** [zcl_skylint_max_cyclo_comp.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_max_cyclo_comp.clas.abap)
