---
title: "Avoid Empty Control Blocks"
description: "Avoid Empty Control Blocks - Clean ABAP guidelines, modern SAP syntax rules, and automated ATC code inspection for SAP S/4HANA and ABAP Cloud."
keywords: "Clean ABAP, SAP ATC Check, ABAP Cloud, S/4HANA Readiness, no-empty-block, anti-patterns"
category: "anti-patterns"
ruleId: "no-empty-block"
---

# Avoid Empty Control Blocks

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Anti-Patterns & Bad Practices" />
  <Badge type="danger" text="#EC NO_EMPTY_BLOCK" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Avoid empty control blocks (IF, CASE, LOOP, TRY, etc.).

> **ATC Finding Messages:**
> - `Empty control block detected; remove redundant control statement`
> - `TRY block without CATCH is superfluous`

## Rationale

An empty branch usually signals unfinished logic, forgotten code, or an inverted condition. Readers must search for hidden behavior and may assume the branch does something. Restructure the condition so every branch has a purpose, or remove the empty block entirely.

### Non-Compliant

```abap
IF lv_is_active = abap_true.
  " no processing yet
ELSE.
  process( ).
ENDIF.
```

### Compliant

```abap
IF NOT lv_is_active.
  process( ).
ENDIF.
```

## Configuration & Thresholds

This check can be fine-tuned directly in the ATC Check Variant Editor (`CHKV`) in Eclipse ADT:

| Parameter Name | Data Type | Default Value | Description & Guidance |
|---|---|:---:|---|
| `CHECK_IF` | `Boolean` | <code>true</code> | Detect empty IF / ELSEIF / ELSE blocks |
| `CHECK_LOOP` | `Boolean` | <code>true</code> | Detect empty LOOP blocks |
| `CHECK_CASE` | `Boolean` | <code>true</code> | Detect empty CASE / WHEN blocks |
| `CHECK_TRY` | `Boolean` | <code>true</code> | Detect empty TRY blocks |
| `CHECK_CATCH` | `Boolean` | <code>true</code> | Detect empty CATCH blocks with no handling or comments |
| `CHECK_TRY_NO_CATCH` | `Boolean` | <code>true</code> | Detect TRY blocks that have no CATCH or CLEANUP clause |
| `CHECK_DO` | `Boolean` | <code>true</code> | Detect empty DO blocks |
| `CHECK_WHILE` | `Boolean` | <code>true</code> | Detect empty WHILE blocks |

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC NO_EMPTY_BLOCK

" SAP CI_ prefix format:
... "#EC CI_NO_EMPTY_BLOCK
```


## Related Rules

* [Limit Control Flow Nesting Depth (Guard Clause Enforcement)](/rules/max-nesting) — <code>#EC MAX_NESTING</code>
* [Avoid CASE with a Single WHEN Branch](/rules/no-single-when) — <code>#EC NO_SINGLE_WHEN</code>
* [Avoid CHECK Statements](/rules/no-check-stmt) — <code>#EC NO_CHECK_IN_LOOP</code>

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_NO_EMPTY_BLOCK`
* **Implementation File:** [zcl_skylint_no_empty_block.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_no_empty_block.clas.abap)
