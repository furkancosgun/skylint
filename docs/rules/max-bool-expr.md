---
title: "Limit Boolean Expression Complexity in Conditional Statements"
description: "Limit boolean expression complexity in ABAP conditional statements by extracting intricate multi-operator conditions into clean predicate methods."
keywords: "max-bool-expr, boolean complexity ABAP, predicate method, Clean ABAP, SAP ATC check"
category: "metrics"
ruleId: "max-bool-expr"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L3894"
---

# Limit Boolean Expression Complexity in Conditional Statements

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Metrics & Complexity Limits" />
  <Badge type="danger" text="#EC MAX_BOOL_EXPR" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L3894" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Limit boolean expressions in conditions.

> **ATC Finding Message:** `Split the condition or extract named helpers`

## Rationale

Compound boolean conditions combining multiple AND, OR, and EQUIV operators in IF, ELSEIF, WHILE, or CHECK statements severely degrade code readability and increase the risk of logical precedence bugs. In ABAP, AND binds stronger than OR, but complex truth tables make verification difficult and often lead to incomplete branch coverage in ABAP Unit tests. Clean ABAP mandates extracting complex boolean conditions into dedicated, well-named predicate methods (returning abap_bool) or intermediate boolean variables, ensuring robust compliance with Clean Core and ABAP Cloud Contract C1.

### Non-Compliant

```abap
IF ls_sales_order-net_amount > 1000
   AND ls_sales_order-currency = 'EUR'
   AND ls_sales_order-is_blocked = abap_false
   AND ls_sales_order-is_approved = abap_true
   AND ls_sales_order-customer_rating = 'A'.
  process_sales_order( ls_sales_order ).
ENDIF.
```

### Compliant

```abap
IF is_order_eligible_for_discount( ls_sales_order ) = abap_true.
  process_sales_order( ls_sales_order ).
ENDIF.
```

## Configuration & Thresholds

This check can be fine-tuned directly in the ATC Check Variant Editor (`CHKV`) in Eclipse ADT:

| Parameter Name | Data Type | Default Value | Description & Guidance |
|---|---|:---:|---|
| `MAX_BOOLEAN_EXPRESSIONS` | `Integer` | <code>4</code> | Maximum allowed boolean operands in a single condition statement (counts AND, OR, EQUIV operators plus one, default: 4). |

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC MAX_BOOL_EXPR

" SAP CI_ prefix format:
... "#EC CI_MAX_BOOL_EXPR
```

## Detection and Operator Evaluation

The check evaluates boolean conditional expressions in `IF`, `ELSEIF`, `WHILE`, and `CHECK` statements:

- **Tracked Operators**: Counts occurrences of `AND`, `OR`, and `EQUIV` keywords at condition level.
- **Between Addition**: The `AND` keyword within a `BETWEEN ... AND ...` expression is recognized and excluded from the operator count.
- **Operand Calculation**: Operands are calculated as `number of operators + 1`. If the operand count exceeds `MAX_BOOLEAN_EXPRESSIONS` (default `4`), the statement is reported with finding code `MAX_BOOL`.

## Suppression

Suppress a finding using the pseudo-comment `"#EC MAX_BOOL_EXPR` on the reported conditional statement.


## Related Rules

* [Limit McCabe Cyclomatic Complexity per Procedure](/rules/max-cyclo-comp) — <code>#EC MAX_CYCLO_COMP</code>
* [Avoid Comparing Boolean Method Calls to abap_true or abap_false](/rules/no-bool-compare) — <code>#EC NO_BOOL_COMPARE</code>
* [Limit Control Flow Block Nesting Depth](/rules/max-nesting) — <code>#EC MAX_NESTING</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_MAX_BOOL_EXPR`
* **ABAP Implementation:** [/skyl/cl_max_bool_expr.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_max_bool_expr.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 3894)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L3894)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_MAX_BOOL_EXPR&title=%5BBug%5D%3A%20Issue%20in%20max-bool-expr)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20max-bool-expr)**
