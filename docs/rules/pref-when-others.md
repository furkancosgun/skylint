---
title: "Require WHEN OTHERS as the Last Branch of Every CASE"
description: "Enforce a WHEN OTHERS fallback as the last branch of ABAP CASE statements so unexpected statuses and enum values fail loudly instead of silently."
keywords: "ABAP CASE WHEN OTHERS, CASE statement fallback, ABAP status enum, SAP ATC, pref-when-others"
category: "clean-abap"
ruleId: "pref-when-others"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L4294"
---

# Require WHEN OTHERS as the Last Branch of Every CASE

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="warning" text="QuickFix Ready" />
  <Badge type="danger" text="#EC PREF_WHEN_OTHERS" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L4294" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Require WHEN OTHERS as the last CASE branch.

> **ATC Finding Messages:**
> - `CASE statement has no WHEN OTHERS fallback branch`
> - `WHEN OTHERS should be the last branch of the CASE statement`

## Rationale

A CASE without WHEN OTHERS silently does nothing when a new enum value, status or exception type appears, so the defect surfaces much later as a missing update or a stale record. A terminal WHEN OTHERS with RAISE EXCEPTION or a documented safe default makes the branching total and turns an unknown state into a loud, testable failure. Keeping it last matters as well: readers scan branches top-down and expect the fallback at the bottom instead of hidden between explicit cases.

### Non-Compliant

```abap
CASE ls_order-status.
  WHEN c_status-open.
    release_order( ).
  WHEN c_status-blocked.
    reject_order( ).
ENDCASE.
```

### Compliant

```abap
CASE ls_order-status.
  WHEN c_status-open.
    release_order( ).
  WHEN c_status-blocked.
    reject_order( ).
  WHEN OTHERS.
    RAISE EXCEPTION NEW zcx_illegal_order_status( ).
ENDCASE.
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
| `MIN_BRANCHES` | `Integer` | <code>2</code> | Number of explicit WHEN branches a CASE needs before WHEN OTHERS becomes mandatory (default 2). |
| `REQUIRE_LAST` | `Boolean` | <code>true</code> | Report a WHEN OTHERS branch that is not the final WHEN branch of its CASE (default enabled). |

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC PREF_WHEN_OTHERS

" SAP CI_ prefix format:
... "#EC CI_PREF_WHEN_OTHERS
```

### Findings and the quickfix

| Finding | Raised on | Meaning |
| --- | --- | --- |
| `PREF_NO_WO` | the `CASE` statement | at least `MIN_BRANCHES` explicit `WHEN` branches but no `WHEN OTHERS` |
| `PREF_WOPOS` | the offending `WHEN OTHERS` | `WHEN OTHERS` exists but further `WHEN` branches follow it |

The `ADD_WO` quickfix inserts `WHEN OTHERS.` directly before `ENDCASE`, indented to the `CASE` column. It deliberately does not invent error handling: add the `RAISE EXCEPTION` or the default assignment yourself.

### Threshold and exceptions

- `MIN_BRANCHES` (default `2`) protects small, obviously total CASE statements such as a two-value mapping. Set it to `1` to demand a fallback everywhere, or raise it for legacy code bases full of short CASE blocks.
- `REQUIRE_LAST` (default on) only controls `PREF_WOPOS`; switch it off if your guideline merely requires the branch to exist.
- Nested CASE statements are tracked with an explicit stack, so an inner `WHEN OTHERS` never satisfies the outer `CASE`.
- Suppress a deliberate exhaustive CASE with `"#EC PREF_WHEN_OTHERS` on the `CASE` statement.


## Related Rules

* [Prefer CASE over Multiple IF / ELSEIF on the Same Variable](/rules/pref-case) — <code>#EC PREF_CASE</code>
* [Replace Single-Branch CASE Statements with IF Conditions](/rules/no-single-when) — <code>#EC NO_SINGLE_WHEN</code>
* [Avoid Empty Control Blocks in Branching and Looping Statements](/rules/no-empty-block) — <code>#EC NO_EMPTY_BLOCK</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_PREF_WHEN_OTHERS`
* **ABAP Implementation:** [/skyl/cl_pref_when_others.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_pref_when_others.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 4294)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L4294)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_PREF_WHEN_OTHERS&title=%5BBug%5D%3A%20Issue%20in%20pref-when-others)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20pref-when-others)**
