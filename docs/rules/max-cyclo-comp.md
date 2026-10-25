---
title: "Limit Cyclomatic Complexity (McCabe Complexity Metric)"
description: "Control McCabe cyclomatic complexity in ABAP code to reduce defect density and improve automated unit test coverage."
keywords: "Cyclomatic Complexity ABAP, McCabe Metric SAP, Clean ABAP Code Quality, Branch Coverage ATC"
---

# Limit Cyclomatic Complexity (McCabe Complexity Metric)

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Metrics & Complexity Limits" />
  <Badge type="danger" text="#EC MAX_CYCLO_COMP" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Cyclomatic Complexity Threshold.

> **ATC Finding Message:** `Procedure cyclomatic complexity exceeds threshold`

## Rationale

Cyclomatic Complexity measures the number of linearly independent paths through a procedure's source code (branch points like `IF`, `ELSEIF`, `WHEN`, `WHILE`, `AND`, `OR`, `CATCH`). High complexity correlates directly with high defect density, regression risks during refactoring, and poor unit test branch coverage.

**Clean ABAP Guideline:** Keep cyclomatic complexity under 10 (or maximum 15 for large state dispatches). Extract branches into polymorphically dispatched strategy classes or smaller helper methods.

### Non-Compliant

```abap
" Anti-pattern: Massive branching complexity score (>20) with nested conditionals
METHOD calculate_discount.
  IF iv_region = 'EU'.
    IF iv_cust_tier = 'VIP' AND iv_amount > 1000.
      rv_disc = 20.
    ELSEIF iv_cust_tier = 'GOLD' OR iv_amount > 500.
      rv_disc = 15.
    ...
  ENDIF.
ENDMETHOD.
```

### Compliant

```abap
" Clean ABAP: Delegate calculations to cohesive strategy pattern or rule table
METHOD calculate_discount.
  DATA(lo_strategy) = mo_discount_factory->get_strategy( iv_region ).
  rv_disc = lo_strategy->calculate( iv_tier = iv_cust_tier iv_amount = iv_amount ).
ENDMETHOD.
```

## Configuration & Thresholds

This check can be fine-tuned directly in the ATC Check Variant Editor (`CHKV`) in Eclipse ADT:

| Parameter Name | Data Type | Default Value | Description & Guidance |
|---|---|:---:|---|
| `MAX_COMPLEXITY` | `Integer` | <code>5</code> | Maximum allowed cyclomatic complexity score per method (default threshold: 10) |

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC MAX_CYCLO_COMP

" SAP CI_ prefix format:
... "#EC CI_MAX_CYCLO_COMP
```

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_MAX_CYCLO_COMP`
* **Implementation File:** [zcl_skylint_max_cyclo_comp.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_max_cyclo_comp.clas.abap)
