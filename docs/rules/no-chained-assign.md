---
title: "Avoid Chained Assignments Binding Multiple Targets Simultaneously"
description: "Avoid chained assignments across multiple variables and use sequential assignment statements in Clean ABAP."
keywords: "no-chained-assign, chained assignments, multiple assignment, Clean ABAP, SAP ATC"
category: "anti-patterns"
ruleId: "no-chained-assign"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L654"
---

# Avoid Chained Assignments Binding Multiple Targets Simultaneously

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Anti-Patterns & Bad Practices" />
  <Badge type="warning" text="QuickFix Ready" />
  <Badge type="danger" text="#EC NO_CHAINED_ASSIGN" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L654" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Avoid Chained Assignments.

> **ATC Finding Message:** `Avoid chained assignments; write separate assignment statements`

## Rationale

Chained assignments such as target_a = target_b = value evaluate from right to left, assigning intermediate evaluation results across multiple targets in a single statement. This construct reduces code clarity, complicates runtime debugging in the ABAP Debugger where step-by-step target inspection is hindered, and creates subtle bugs when types differ between variables. Split chained assignments into explicit, sequential assignment statements to ensure transparent execution order and straightforward refactoring. The check reports NO_CHN_ASG and splits assignments with the SPLITASG quickfix.

### Non-Compliant

```abap
lv_order_status = lv_header_status = lv_default_status.
```

### Compliant

```abap
lv_header_status = lv_default_status.
lv_order_status = lv_header_status.
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

### Execution Order and Debugging

Chained assignments evaluate right-to-left:

```abap
" Anti-pattern: Chained assignment hides step-wise evaluation
lv_invoice_total = lv_cleared_total = 0.

" Recommended: Explicit sequential assignments
lv_cleared_total = 0.
lv_invoice_total = lv_cleared_total.
```

Equal signs inside parentheses (such as `xsdbool( lv_status = 'X' )` or method parameter bindings `compute( iv_param = 1 )`) are recognized as nested expressions and are not flagged. The `SPLITASG` quickfix unrolls chained assignments in right-to-left evaluation order. Suppress findings with `"#EC NO_CHAINED_ASSIGN`.


## Related Rules

* [Avoid Chained Declarations for Variables, Types, and Constants](/rules/no-chained-decl) — <code>#EC NO_CHAINED_DECL</code>
* [Remove Redundant Self-Assignments and Identity Moves](/rules/no-redun-assign) — <code>#EC NO_IDENTICAL_MOVE</code>
* [Remove Unread Local Variables and Field Symbols](/rules/no-unused-vars) — <code>#EC NO_UNUSED_VARS</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_NO_CHAINED_ASSIGN`
* **ABAP Implementation:** [/skyl/cl_no_chained_assign.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_no_chained_assign.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 654)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L654)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_NO_CHAINED_ASSIGN&title=%5BBug%5D%3A%20Issue%20in%20no-chained-assign)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20no-chained-assign)**
