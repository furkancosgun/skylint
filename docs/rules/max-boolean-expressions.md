---
description: "Limit boolean expressions in conditions"
---

# Limit the Number of Boolean Expressions in a Condition

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

Long boolean conditions combine many independent decisions and are difficult to review and test. Split the condition into named helper methods or intermediate variables, or restructure the control flow. The default limit is four operands per IF, ELSEIF, WHILE, or CHECK statement.

### Non-Compliant

```abap
IF a = 1 AND b = 2 AND c = 3 AND d = 4 AND e = 5.
```

### Compliant

```abap
IF is_valid_header( ) AND is_valid_items( ).
```

## Configuration & Thresholds

This check can be fine-tuned directly in the ATC Check Variant Editor (`CHKV`) in Eclipse ADT:

| Parameter Name | Data Type | Default Value |
|---|---|:---:|
| `MAX_BOOLEAN_EXPRESSIONS` | `Integer` | <code>4</code> |

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC MAX_BOOL_EXPR

" SAP CI_ prefix format:
... "#EC CI_MAX_BOOL_EXPR
```

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_MAX_BOOL_EXPR`
* **Implementation File:** [zcl_skylint_max_bool_expr.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_max_bool_expr.clas.abap)
