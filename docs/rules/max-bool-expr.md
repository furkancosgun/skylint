---
title: "Limit Boolean Expression Complexity in Conditional Statements"
description: "Simplify complex boolean logic in ABAP IF statements. Extract intricate conditions into named predicate methods."
keywords: "Boolean expression complexity ABAP, Predicate methods Clean ABAP, Operator Precedence SAP, Clean Code Logic"
---

# Limit Boolean Expression Complexity in Conditional Statements

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Metrics & Complexity Limits" />
  <Badge type="danger" text="#EC MAX_BOOL_EXPR" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Limit boolean expressions in conditions.

> **ATC Finding Message:** `Split the condition or extract named helpers`

## Rationale

Boolean conditions combining more than 3 to 4 `AND` and `OR` operators in a single `IF` or `WHILE` statement are notoriously prone to precedence bugs. Developers misinterpret operator binding order, and unit tests fail to cover all combinations in the truth table.

**Clean ABAP Guideline:** Extract complex boolean conditions into well-named **boolean helper methods (predicate methods)** like `is_delivery_allowed( )` or `has_valid_credit_limit( )`.

### Non-Compliant

```abap
" Anti-pattern: Complex multi-term boolean condition
IF ( is_order-status = 'O' OR is_order-status = 'P' )
   AND is_order-total_amount > 500
   AND is_customer_active( is_order-cust_id ) = abap_true
   AND NOT ( is_order-blocked = abap_true OR is_order-on_hold = abap_true ).
```

### Compliant

```abap
" Clean ABAP: Self-documenting predicate method call
IF is_order_ready_for_dispatch( is_order ) = abap_true.
  dispatch_order( is_order ).
ENDIF.
```

## Configuration & Thresholds

This check can be fine-tuned directly in the ATC Check Variant Editor (`CHKV`) in Eclipse ADT:

| Parameter Name | Data Type | Default Value | Description & Guidance |
|---|---|:---:|---|
| `MAX_BOOLEAN_EXPRESSIONS` | `Integer` | <code>4</code> | Maximum allowed boolean operators (AND, OR, NOT) in a single condition |

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC MAX_BOOL_EXPR

" SAP CI_ prefix format:
... "#EC CI_MAX_BOOL_EXPR
```

## References & Standards

* [Clean ABAP: Decompose Complex Conditions](https://github.com/SAP/styleguides/blob/main/clean-abap/CleanABAP.md#decompose-complex-conditions)

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_MAX_BOOL_EXPR`
* **Implementation File:** [zcl_skylint_max_bool_expr.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_max_bool_expr.clas.abap)
