---
title: "Parenthesize Combinations of AND and OR"
description: "Parenthesize Combinations of AND and OR - Clean ABAP guidelines, modern SAP syntax rules, and automated ATC code inspection for SAP S/4HANA and ABAP Cloud."
keywords: "Clean ABAP, SAP ATC Check, ABAP Cloud, S/4HANA Readiness, pref-paren-and-or, clean-abap"
category: "clean-abap"
ruleId: "pref-paren-and-or"
---

# Parenthesize Combinations of AND and OR

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="danger" text="#EC PREF_PAREN_AND_OR" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Parenthesize Combinations of AND and OR.

> **ATC Finding Message:** `Parenthesize combinations of AND and OR to eliminate ambiguity`

## Rationale

Different programming languages and databases have varying operator precedences for logical operators. Unparenthesized conditions mixing AND and OR (such as a AND b OR c) are ambiguous to human readers and easily hide critical branching bugs. Explicitly parenthesize combinations as ( a AND b ) OR c to make evaluation precedence unmistakable.

### Non-Compliant

```abap
IF cond_a AND cond_b OR cond_c.
  step( ).
ENDIF.
```

### Compliant

```abap
IF ( cond_a AND cond_b ) OR cond_c.
  step( ).
ENDIF.
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC PREF_PAREN_AND_OR

" SAP CI_ prefix format:
... "#EC CI_PREF_PAREN_AND_OR
```


## Related Rules

* [Limit Boolean Expression Complexity in Conditional Statements](/rules/max-bool-expr) — <code>#EC MAX_BOOL_EXPR</code>
* [Avoid Duplicate Branch Conditions](/rules/no-dup-cond) — <code>#EC NO_DUP_COND</code>
* [Avoid Comparing to abap_true / abap_false](/rules/no-bool-compare) — <code>#EC NO_BOOL_COMPARE</code>

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_PREF_PAREN_AND_OR`
* **Implementation File:** [zcl_skylint_pref_paren_and_or.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_pref_paren_and_or.clas.abap)
