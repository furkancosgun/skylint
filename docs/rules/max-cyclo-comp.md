---
title: "Limit Cyclomatic Complexity (McCabe Complexity Metric)"
description: "Control McCabe cyclomatic complexity in ABAP code to reduce defect density and improve automated unit test coverage."
keywords: "Cyclomatic Complexity ABAP, McCabe Metric SAP, Clean ABAP Code Quality, Branch Coverage ATC"
category: "metrics"
ruleId: "max-cyclo-comp"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L2008"
---

# Limit Cyclomatic Complexity (McCabe Complexity Metric)

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Metrics & Complexity Limits" />
  <Badge type="danger" text="#EC MAX_CYCLO_COMP" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L2008" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
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


## Related Rules

* [Limit Boolean Expression Complexity in Conditional Statements](/rules/max-bool-expr) — <code>#EC MAX_BOOL_EXPR</code>
* [Limit Control Flow Nesting Depth (Guard Clause Enforcement)](/rules/max-nesting) — <code>#EC MAX_NESTING</code>
* [Limit Method and Constructor Statement Length](/rules/max-method-len) — <code>#EC MAX_METHOD_LEN</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_MAX_CYCLO_COMP`
* **ABAP Implementation:** [/skyl/cl_max_cyclo_comp.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_max_cyclo_comp.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 2008)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L2008)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_MAX_CYCLO_COMP&title=%5BBug%5D%3A%20Issue%20in%20max-cyclo-comp)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20max-cyclo-comp)**
