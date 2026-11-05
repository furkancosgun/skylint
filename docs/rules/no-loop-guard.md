---
title: "Redundant IF Condition Before LOOP AT"
description: "Report redundant IF itab IS NOT INITIAL checks surrounding LOOP AT blocks."
keywords: "no-loop-guard, redundant loop guard, LOOP AT, IS NOT INITIAL"
category: "clean-abap"
ruleId: "no-loop-guard"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L6014"
---

# Redundant IF Condition Before LOOP AT

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="danger" text="#EC NO_LOOP_GUARD" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L6014" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Redundant IF condition before LOOP AT.

> **ATC Finding Message:** `Unnecessary IF guard before LOOP AT; an empty table iterates 0 times`

## Rationale

An internal table loop (LOOP AT itab) executes zero times when the internal table is empty. Wrapping the entire loop in an IF itab IS NOT INITIAL check adds unnecessary nesting and boilerplate code.

### Non-Compliant

```abap
IF lt_items IS NOT INITIAL.
  LOOP AT lt_items INTO DATA(ls_item).
    process_item( ls_item ).
  ENDLOOP.
ENDIF.
```

### Compliant

```abap
LOOP AT lt_items INTO DATA(ls_item).
  process_item( ls_item ).
ENDLOOP.
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC NO_LOOP_GUARD

" SAP CI_ prefix format:
... "#EC CI_NO_LOOP_GUARD
```


## Related Rules

* [Prefer Early Return and CONTINUE Guard Clauses over Nesting](/rules/pref-early-ret) — <code>#EC PREF_GUARD_METHOD</code>
* [Avoid Empty Control Blocks in Branching and Looping Statements](/rules/no-empty-block) — <code>#EC NO_EMPTY_BLOCK</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_NO_LOOP_GUARD`
* **ABAP Implementation:** [/skyl/cl_no_loop_guard.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_no_loop_guard.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 6014)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L6014)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_NO_LOOP_GUARD&title=%5BBug%5D%3A%20Issue%20in%20no-loop-guard)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20no-loop-guard)**
