---
title: "Remove Redundant Self-Assignments and Identity Moves"
description: "Detect and delete redundant self-assignments and identity moves with automated ATC quickfixes in ABAP Cloud."
keywords: "no-redun-assign, self-assignment, redundant assignment, Clean ABAP, SAP ATC"
category: "anti-patterns"
ruleId: "no-redun-assign"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L1581"
---

# Remove Redundant Self-Assignments and Identity Moves

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Anti-Patterns & Bad Practices" />
  <Badge type="warning" text="QuickFix Ready" />
  <Badge type="danger" text="#EC NO_IDENTICAL_MOVE" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L1581" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Detect identical assignments and moves.

> **ATC Finding Message:** `Identical assignment has no effect; remove redundant statement`

## Rationale

Identical self-assignments (such as a = a or MOVE a TO a) perform no real work and indicate copy-paste mistakes, aborted refactorings, or accidentally overlooked target variables. Leaving redundant assignments in production logic introduces noise that confuses automated linters and human code reviewers. In Clean ABAP and ABAP Cloud codebases, removing identical moves eliminates dead code and ensures that all statements contribute meaningfully to business outcomes. Suppress with #EC NO_IDENTICAL_MOVE.

### Non-Compliant

```abap
ls_sales_order-customer_id = ls_sales_order-customer_id.
```

### Compliant

```abap
ls_sales_order-customer_id = iv_target_customer_id.
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

### QuickFix Details

The rule evaluates assignment statements (`COMPUTE` operator `=` and `?=` as well as `MOVE ... TO` and `MOVE ... ?TO`). When the compiler symbol resolution for the target matches the source symbol, finding `NO_IDN_MOV` is reported.

The `DELIDENT` QuickFix deletes the redundant self-assignment statement completely without altering surrounding code. Suppress with `"#EC NO_IDENTICAL_MOVE`.


## Related Rules

* [Avoid Chained Assignments Binding Multiple Targets Simultaneously](/rules/no-chained-assign) — <code>#EC NO_CHAINED_ASSIGN</code>
* [Remove Unread Local Variables and Field Symbols](/rules/no-unused-vars) — <code>#EC NO_UNUSED_VARS</code>
* [Avoid Comparisons and Operations with Identical Operands](/rules/no-self-compare) — <code>#EC NO_SELF_COMPARE</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_NO_REDUN_ASSIGN`
* **ABAP Implementation:** [/skyl/cl_no_redun_assign.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_no_redun_assign.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 1581)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L1581)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_NO_REDUN_ASSIGN&title=%5BBug%5D%3A%20Issue%20in%20no-redun-assign)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20no-redun-assign)**
