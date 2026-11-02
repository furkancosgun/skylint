---
title: "Avoid Duplicate Subexpressions in Conditions"
description: "Flag duplicate boolean subexpressions in ABAP IF, ELSEIF, CHECK, and WHILE conditions."
keywords: "Duplicate Subexpression ABAP, Redundant Condition, Clean ABAP Conditions, Logic Simplification"
category: "clean-abap"
ruleId: "no-dup-subexpr"
---

# Avoid Duplicate Subexpressions in Conditions

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="danger" text="#EC NO_DUP_SUBEXPR" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Avoid duplicate subexpressions in conditions.

> **ATC Finding Message:** `Duplicate subexpression detected in boolean condition`

## Rationale

Repeating identical subexpressions inside the same boolean condition (e.g. `IF cond_a AND cond_a`) adds clutter, impairs readability, and frequently indicates copy-paste errors or missing variables.

**Standard:** Eliminate duplicate boolean operands and simplify complex expressions.

### Non-Compliant

```abap
IF a = 1 AND a = 1.
  " Redundant subexpression
ENDIF.
```

### Compliant

```abap
IF a = 1.
  " Clean single expression
ENDIF.
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC NO_DUP_SUBEXPR

" SAP CI_ prefix format:
... "#EC CI_NO_DUP_SUBEXPR
```


## Related Rules

* [Avoid Duplicate Branch Conditions](/rules/no-dup-cond) — <code>#EC NO_DUP_COND</code>
* [Avoid Comparisons and Arithmetic with Identical Operands](/rules/no-self-compare) — <code>#EC NO_SELF_COMPARE</code>
* [Limit Boolean Expression Complexity in Conditional Statements](/rules/max-bool-expr) — <code>#EC MAX_BOOL_EXPR</code>

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_NO_DUP_SUBEXPR`
* **Implementation File:** [zcl_skylint_no_dup_subexpr.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_no_dup_subexpr.clas.abap)
