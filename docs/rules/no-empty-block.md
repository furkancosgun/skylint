---
title: "Avoid Empty Control Blocks in Branching and Looping Statements"
description: "Detect and remove empty control blocks in IF, CASE, LOOP, and TRY statements in Clean ABAP and SAP ATC."
keywords: "no-empty-block, empty control block, Clean ABAP, empty CATCH, SAP ATC"
category: "anti-patterns"
ruleId: "no-empty-block"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L798"
---

# Avoid Empty Control Blocks in Branching and Looping Statements

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Anti-Patterns & Bad Practices" />
  <Badge type="warning" text="QuickFix Ready" />
  <Badge type="danger" text="#EC NO_EMPTY_BLOCK" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L798" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Avoid empty control blocks (IF, CASE, LOOP, TRY, etc.).

> **ATC Finding Messages:**
> - `Empty control block detected; remove redundant control statement`
> - `TRY block without CATCH is superfluous`

## Rationale

Empty control blocks in IF, ELSEIF, ELSE, CASE, LOOP, DO, WHILE, or TRY constructs typically signal forgotten business logic, incomplete error handling, or abandoned prototypes. Leaving vacant blocks confuses reviewers and maintainers, who must verify whether the lack of action was intentional or a bug. In Clean ABAP, invert or simplify the condition to remove the empty branch entirely, or remove unused loops and TRY blocks that have no CATCH handling. The check flags empty blocks with NO_EMPTY_B or NO_TRY_WO and removes redundant control blocks via the RMBLOCK quickfix.

### Non-Compliant

```abap
IF lv_is_contract_active = abap_true.
ELSE.
  terminate_subscription( ).
ENDIF.
```

### Compliant

```abap
IF lv_is_contract_active = abap_false.
  terminate_subscription( ).
ENDIF.
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
| `CHECK_IF` | `Boolean` | <code>true</code> | Detect empty IF, ELSEIF, or ELSE branches. |
| `CHECK_LOOP` | `Boolean` | <code>true</code> | Detect empty LOOP blocks containing no executable statements. |
| `CHECK_CASE` | `Boolean` | <code>true</code> | Detect empty CASE or WHEN blocks. |
| `CHECK_TRY` | `Boolean` | <code>true</code> | Detect empty TRY blocks containing no protected statements. |
| `CHECK_CATCH` | `Boolean` | <code>true</code> | Detect empty CATCH blocks containing no exception handling. |
| `CHECK_TRY_NO_CATCH` | `Boolean` | <code>true</code> | Detect TRY blocks that do not specify any CATCH or CLEANUP clause. |
| `CHECK_DO` | `Boolean` | <code>true</code> | Detect empty DO iteration blocks. |
| `CHECK_WHILE` | `Boolean` | <code>true</code> | Detect empty WHILE iteration blocks. |

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC NO_EMPTY_BLOCK

" SAP CI_ prefix format:
... "#EC CI_NO_EMPTY_BLOCK
```

### Supported Control Structures and Findings

The rule flags empty bodies across all standard ABAP control flow statements:

| Statement | Trigger Condition | Finding Code |
|---|---|---|
| `IF` / `ELSEIF` / `ELSE` | Consecutive boundary keywords (e.g. `IF ... ELSE`, `ELSE ... ENDIF`) | `NO_EMPTY_B` |
| `LOOP` / `DO` / `WHILE` | Consecutive start and end loop keywords without body statements | `NO_EMPTY_B` |
| `CASE` / `WHEN` | Consecutive `WHEN` without statements or empty `CASE ... ENDCASE` | `NO_EMPTY_B` |
| `TRY` / `CATCH` | Empty `CATCH` block without error handling | `NO_EMPTY_B` |
| `TRY` without `CATCH` | `TRY` block lacking any `CATCH` or `CLEANUP` handler | `NO_TRY_WO` |

The `RMBLOCK` quickfix deletes empty blocks automatically. Suppress findings using `"#EC NO_EMPTY_BLOCK`.


## Related Rules

* [Limit Control Flow Block Nesting Depth](/rules/max-nesting) — <code>#EC MAX_NESTING</code>
* [Replace Single-Branch CASE Statements with IF Conditions](/rules/no-single-when) — <code>#EC NO_SINGLE_WHEN</code>
* [Avoid CHECK Statements Inside and Outside Iteration Loops](/rules/no-check-stmt) — <code>#EC NO_CHECK_IN_LOOP</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_NO_EMPTY_BLOCK`
* **ABAP Implementation:** [/skyl/cl_no_empty_block.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_no_empty_block.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 798)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L798)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_NO_EMPTY_BLOCK&title=%5BBug%5D%3A%20Issue%20in%20no-empty-block)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20no-empty-block)**
