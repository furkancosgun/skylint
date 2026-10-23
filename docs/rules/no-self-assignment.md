---
description: "Detect Identical Self Assignments"
---

# Avoid Redundant Self-Assignments

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Anti-Patterns & Bad Practices" />
  <Badge type="warning" text="QuickFix Ready" />
  <Badge type="danger" text="#EC SELF_ASSIGN" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Detect Identical Self Assignments.

> **ATC Finding Message:** `Identical assignment has no effect; remove redundant statement`

## Rationale

Assigning a variable or component to itself does nothing and is usually left over from refactoring or a typo in the source field. The same is true for MOVE source TO target with identical source and target. It adds noise and can hide a missing assignment. Assign the intended source value or delete the statement.

### Non-Compliant

```abap
ls_order-customer_id = ls_order-customer_id.
MOVE lv_count TO lv_count.
```

### Compliant

```abap
ls_order-customer_id = iv_customer_id.
MOVE lv_count TO lv_total.
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
... "#EC SELF_ASSIGN

" SAP CI_ prefix format:
... "#EC CI_SELF_ASSIGN
```

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_NO_SELF_ASSIGN`
* **Implementation File:** [zcl_skylint_no_self_assign.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_no_self_assign.clas.abap)
