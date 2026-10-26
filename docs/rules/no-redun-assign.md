---
title: "Remove Redundant Self-Assignments and Identity Moves"
description: "Remove Redundant Self-Assignments and Identity Moves - Clean ABAP guidelines, modern SAP syntax rules, and automated ATC code inspection for SAP S/4HANA and ABAP Cloud."
keywords: "Clean ABAP, SAP ATC Check, ABAP Cloud, S/4HANA Readiness, no-redun-assign, anti-patterns"
category: "anti-patterns"
ruleId: "no-redun-assign"
---

# Remove Redundant Self-Assignments and Identity Moves

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Anti-Patterns & Bad Practices" />
  <Badge type="warning" text="QuickFix Ready" />
  <Badge type="danger" text="#EC NO_IDENTICAL_MOVE" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Detect identical assignments and moves.

> **ATC Finding Message:** `Identical assignment has no effect; remove redundant statement`

## Rationale

Self-assignments (e.g. a = a or MOVE a TO a) have zero net effect on program execution state and indicate either dead code, incomplete copy-paste, or accidental reassignment. Remove these redundant statements to improve code clarity and reduce maintenance overhead.

### Non-Compliant

```abap
ls_order-id = ls_order-id.
MOVE lv_count TO lv_count.
```

### Compliant

```abap
ls_order-id = iv_id.
lv_count = iv_count.
```

## Automated QuickFix

This rule provides an **automated QuickFix** directly in Eclipse ABAP Development Tools (ADT):
1. Position the cursor on the flagged statement.
2. Press <kbd>Ctrl</kbd> + <kbd>1</kbd> (Quick Assist).
3. Select the automated refactoring to apply the clean syntax immediately.

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC NO_IDENTICAL_MOVE

" SAP CI_ prefix format:
... "#EC CI_NO_IDENTICAL_MOVE
```


## Related Rules

* [Avoid Chained Assignments (a = b = c = 1)](/rules/no-chained-assign) — <code>#EC NO_CHAINED_ASSIGN</code>
* [Eliminate Unused Local Variables and Symbols](/rules/no-unused-vars) — <code>#EC NO_UNUSED_VARS</code>
* [Avoid Comparisons and Arithmetic with Identical Operands](/rules/no-self-compare) — <code>#EC NO_SELF_COMPARE</code>

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_NO_REDUN_ASSIGN`
* **Implementation File:** [zcl_skylint_no_redun_assign.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_no_redun_assign.clas.abap)
