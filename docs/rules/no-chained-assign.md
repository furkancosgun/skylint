---
title: "Avoid Chained Assignments (a = b = c = 1)"
description: "Avoid Chained Assignments (a = b = c = 1) - Clean ABAP guidelines, modern SAP syntax rules, and automated ATC code inspection for SAP S/4HANA and ABAP Cloud."
keywords: "Clean ABAP, SAP ATC Check, ABAP Cloud, S/4HANA Readiness, no-chained-assign, anti-patterns"
category: "anti-patterns"
ruleId: "no-chained-assign"
---

# Avoid Chained Assignments (a = b = c = 1)

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Anti-Patterns & Bad Practices" />
  <Badge type="warning" text="QuickFix Ready" />
  <Badge type="danger" text="#EC NO_CHAINED_ASSIGN" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Avoid Chained Assignments.

> **ATC Finding Message:** `Avoid chained assignments; write separate assignment statements`

## Rationale

Chained assignments evaluate right-to-left and bind multiple targets in a single statement, making code execution order difficult to follow and debug. Split chained assignments into distinct, explicit assignment statements.

### Non-Compliant

```abap
lv_a = lv_b = lv_c = 0.
```

### Compliant

```abap
lv_c = 0.
lv_b = lv_c.
lv_a = lv_b.
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
... "#EC NO_CHAINED_ASSIGN

" SAP CI_ prefix format:
... "#EC CI_NO_CHAINED_ASSIGN
```


## Related Rules

* [Avoid Chained Declarations (DATA:, CONSTANTS:, TYPES:)](/rules/no-chained-decl) — <code>#EC NO_CHAINED_DECL</code>
* [Remove Redundant Self-Assignments and CLEAR Statements](/rules/no-redun-assign) — <code>#EC SELF_ASSIGN</code>
* [Eliminate Unused Local Variables and Symbols](/rules/no-unused-vars) — <code>#EC NO_UNUSED_VARS</code>

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_NO_CHAINED_ASSIGN`
* **Implementation File:** [zcl_skylint_no_chained_assign.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_no_chained_assign.clas.abap)
