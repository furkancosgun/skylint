---
title: "Limit McCabe Cyclomatic Complexity per Procedure"
description: "Monitor McCabe cyclomatic complexity in ABAP procedures to prevent defect-prone branching and guarantee testable code units."
keywords: "max-cyclo-comp, cyclomatic complexity, McCabe metric, Clean ABAP, SAP ATC"
category: "metrics"
ruleId: "max-cyclo-comp"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L2037"
---

# Limit McCabe Cyclomatic Complexity per Procedure

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Metrics & Complexity Limits" />
  <Badge type="danger" text="#EC MAX_CYCLO_COMP" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L2037" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Cyclomatic Complexity Threshold.

> **ATC Finding Message:** `Procedure cyclomatic complexity exceeds threshold`

## Rationale

Cyclomatic Complexity (McCabe metric) measures the number of linearly independent paths through a procedure's control graph. In SAP ABAP systems, high complexity strongly correlates with elevated defect rates, high regression frequency during maintenance, and inadequate unit test branch coverage. Procedures with cyclomatic complexity exceeding 10 or 15 cannot be reliably reasoned about or exhaustively tested under modern ABAP Cloud practices. Decomposing convoluted branch networks into polymorphically dispatched strategies or focused helper routines isolates edge cases and ensures robust testability.

### Non-Compliant

```abap
METHOD calculate_settlement_discount.
  DATA lv_discount_rate TYPE i.

  IF iv_customer_tier = 'PLATINUM' AND iv_order_amount > 1000.
    lv_discount_rate = 25.
  ELSEIF iv_customer_tier = 'GOLD' AND iv_order_amount > 500.
    lv_discount_rate = 15.
  ELSEIF iv_customer_tier = 'SILVER' OR iv_has_vip_pass = abap_true.
    lv_discount_rate = 10.
  ELSE.
    lv_discount_rate = 0.
  ENDIF.
  rv_discount_rate = lv_discount_rate.
ENDMETHOD.
```

### Compliant

```abap
METHOD calculate_settlement_discount.
  DATA(lo_discount_policy) = mo_discount_factory->resolve_policy( iv_customer_tier ).
  rv_discount_rate = lo_discount_policy->compute_discount( iv_order_amount ).
ENDMETHOD.
```

## Configuration & Thresholds

This check can be fine-tuned directly in the ATC Check Variant Editor (`CHKV`) in Eclipse ADT:

| Parameter Name | Data Type | Default Value | Description & Guidance |
|---|---|:---:|---|
| `MAX_COMPLEXITY` | `Integer` | <code>5</code> | Maximum allowable cyclomatic complexity score (McCabe metric) for a procedure before reporting (default: 5). |

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC MAX_CYCLO_COMP

" SAP CI_ prefix format:
... "#EC CI_MAX_CYCLO_COMP
```

## Complexity Calculation Rules

The check initializes procedure complexity at `1` and evaluates statement keywords and unreferenced operator tokens:

| Construct | Contribution | Notes |
|---|---|---|
| Base score | +1 | Every procedure starts with 1 independent path |
| Branch keywords | +1 each | `IF`, `ELSEIF`, `LOOP`, `DO`, `WHILE`, `WHEN`, `CATCH`, `CLEANUP` |
| Boolean conjunctions | +1 each | `AND` (except inside `BETWEEN ... AND ...`), `OR` |
| Constructor branching | +1 each | `COND`, `SWITCH` |

| Finding Code | Severity | Trigger | Suppression |
|---|---|---|---|
| `MAX_CYCLO` | Warning | Procedure complexity exceeds `MAX_COMPLEXITY` | `##MAX_CYCLO_COMP` or `"#EC MAX_CYCLO_COMP` |


## Related Rules

* [Limit Boolean Expression Complexity in Conditional Statements](/rules/max-bool-expr) — <code>#EC MAX_BOOL_EXPR</code>
* [Limit Control Flow Block Nesting Depth](/rules/max-nesting) — <code>#EC MAX_NESTING</code>
* [Limit Method and Constructor Statement Length](/rules/max-method-len) — <code>#EC MAX_METHOD_LEN</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_MAX_CYCLO_COMP`
* **ABAP Implementation:** [/skyl/cl_max_cyclo_comp.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_max_cyclo_comp.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 2037)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L2037)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_MAX_CYCLO_COMP&title=%5BBug%5D%3A%20Issue%20in%20max-cyclo-comp)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20max-cyclo-comp)**
