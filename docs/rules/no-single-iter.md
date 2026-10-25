---
title: "Avoid Loops That Execute At Most Once"
description: "Avoid Loops That Execute At Most Once - Clean ABAP guidelines, modern SAP syntax rules, and automated ATC code inspection for SAP S/4HANA and ABAP Cloud."
keywords: "Clean ABAP, SAP ATC Check, ABAP Cloud, S/4HANA Readiness, no-single-iter, anti-patterns"
category: "anti-patterns"
ruleId: "no-single-iter"
---

# Avoid Loops That Execute At Most Once

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Anti-Patterns & Bad Practices" />
  <Badge type="danger" text="#EC NO_SINGLE_ITER" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Avoid Loops That Execute At Most Once.

> **ATC Finding Message:** `Loop contains an unconditional EXIT or RETURN and executes at most once`

## Rationale

A loop statement (LOOP, WHILE, or DO) containing an unconditional EXIT or RETURN at its top nesting level will execute at most once. This usually indicates an algorithmic bug, a leftover prototyping construct, or the misuse of a loop instead of a conditional block or helper method.

### Non-Compliant

```abap
LOOP AT lt_items ASSIGNING <ls_item>.
  process( <ls_item> ).
  EXIT.
ENDLOOP.
```

### Compliant

```abap
IF line_exists( lt_items[ 1 ] ).
  process( lt_items[ 1 ] ).
ENDIF.
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC NO_SINGLE_ITER

" SAP CI_ prefix format:
... "#EC CI_NO_SINGLE_ITER
```


## Related Rules

* [Avoid Dead Code with Constant Conditions](/rules/no-dead-code) — <code>#EC NO_DEAD_CODE</code>
* [Avoid Dead / Unreachable Code](/rules/no-unreachable) — <code>#EC NO_UNREACHABLE</code>
* [Prefer Early Return to Reduce Nesting (Guard Clauses)](/rules/pref-early-ret) — <code>#EC PREF_GUARD_METHOD</code>

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_NO_SINGLE_ITER`
* **Implementation File:** [zcl_skylint_no_single_iter.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_no_single_iter.clas.abap)
