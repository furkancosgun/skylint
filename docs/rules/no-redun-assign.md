---
title: "Remove Redundant Self-Assignments and CLEAR Statements"
description: "Remove Redundant Self-Assignments and CLEAR Statements - Clean ABAP guidelines, modern SAP syntax rules, and automated ATC code inspection for SAP S/4HANA and ABAP Cloud."
keywords: "Clean ABAP, SAP ATC Check, ABAP Cloud, S/4HANA Readiness, no-redun-assign, anti-patterns"
category: "anti-patterns"
ruleId: "no-redun-assign"
---

# Remove Redundant Self-Assignments and CLEAR Statements

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Anti-Patterns & Bad Practices" />
  <Badge type="warning" text="QuickFix Ready" />
  <Badge type="danger" text="#EC SELF_ASSIGN" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Remove Redundant Assignments & CLEARs.

> **ATC Finding Messages:**
> - `Identical assignment has no effect; remove redundant statement`
> - `Do not CLEAR or FREE variables after declaration; they are already initial`
> - `Variable is CLEARed or FREEd but never read again before procedure ends`

## Rationale

Self-assignments (e.g. a = a or MOVE a TO a) and superfluous CLEAR/FREE operations have zero net effect on program execution state. Clearing variables immediately after declaration is unnecessary because ABAP automatically initializes variables to their type defaults. Similarly, clearing variables at procedure exit when they are never read again is dead code. Remove these redundant statements to improve clarity and reduce noise.

### Non-Compliant

```abap
ls_order-id = ls_order-id.
DATA lt_items TYPE string_table.
CLEAR lt_items.
```

### Compliant

```abap
ls_order-id = iv_id.
DATA lt_items TYPE string_table.
```

## Automated QuickFix

This rule provides an **automated QuickFix** directly in Eclipse ABAP Development Tools (ADT):
1. Position the cursor on the flagged statement.
2. Press <kbd>Ctrl</kbd> + <kbd>1</kbd> (Quick Assist).
3. Select the automated refactoring to apply the clean syntax immediately.

## Configuration & Thresholds

This check can be fine-tuned directly in the ATC Check Variant Editor (`CHKV`) in Eclipse ADT:

| Parameter Name | Data Type | Default Value | Description & Guidance |
|---|---|:---:|---|
| `CHECK_SELF_ASSIGN` | `Boolean` | <code>true</code> | Detect identical assignments where variable is assigned to itself (a = a) |
| `CHECK_BEFORE_WRITE` | `Boolean` | <code>true</code> | Detect redundant CLEAR statements immediately followed by variable write/overwrite |
| `CHECK_WITHOUT_READ` | `Boolean` | <code>true</code> | Detect redundant CLEAR at the very end of procedure where variable is never read again |

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC SELF_ASSIGN

" SAP CI_ prefix format:
... "#EC CI_SELF_ASSIGN
```


## Related Rules

* [Avoid Chained Assignments (a = b = c = 1)](/rules/no-chained-assign) — <code>#EC NO_CHAINED_ASSIGN</code>
* [Eliminate Unused Local Variables and Symbols](/rules/no-unused-vars) — <code>#EC NO_UNUSED_VARS</code>
* [Avoid Hungarian Notation and Type Prefixes](/rules/no-hungarian) — <code>#EC NO_HUNGARIAN</code>

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_NO_REDUN_ASSIGN`
* **Implementation File:** [zcl_skylint_no_redun_assign.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_no_redun_assign.clas.abap)
