---
title: "Parenthesize Mixed AND/OR Conditions Explicitly"
description: "Parenthesize mixed AND/OR conditions in IF, ELSEIF, CHECK and WHILE so operator precedence is explicit and reviewable in Clean ABAP code."
keywords: "pref-paren-and-or, AND OR precedence, IF condition, Clean ABAP, SAP ATC"
category: "clean-abap"
ruleId: "pref-paren-and-or"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L86"
---

# Parenthesize Mixed AND/OR Conditions Explicitly

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="warning" text="QuickFix Ready" />
  <Badge type="danger" text="#EC PREF_PAREN_AND_OR" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L86" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Parenthesize Combinations of AND and OR.

> **ATC Finding Message:** `Parenthesize combinations of AND and OR to eliminate ambiguity`

## Rationale

ABAP evaluates AND before OR, but SQL, JavaScript and most other languages a developer reads daily do not share that intuition, and long conditions are routinely misread. The check scans IF, ELSEIF, CHECK and WHILE conditions at each parenthesis depth and reports PREF_PAREN as soon as one depth mixes AND with OR or EQUIV. Explicit parentheses turn implicit precedence into visible grouping, which prevents bugs when a condition is later extended with one more term. The ADD_PAREN quickfix rewrites the condition with a parenthesized AND group.

### Non-Compliant

```abap
IF lv_is_approved = abap_true AND lv_amount > lv_limit OR lv_is_escalated = abap_true.
  release_purchase_order( ).
ENDIF.
```

### Compliant

```abap
IF ( lv_is_approved = abap_true AND lv_amount > lv_limit ) OR lv_is_escalated = abap_true.
  release_purchase_order( ).
ENDIF.
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
... "#EC PREF_PAREN_AND_OR

" SAP CI_ prefix format:
... "#EC CI_PREF_PAREN_AND_OR
```

## Detection Details

Conditions are evaluated separately per parenthesis depth, so a mixed outer clause is reported even when an inner group already uses parentheses. A `BETWEEN ... AND ...` pair is not counted as a conjunction and therefore never produces a finding on its own. The `ADD_PAREN` quickfix wraps every `AND` group of the condition in parentheses while keeping the indentation of the original statement.


## Related Rules

* [Limit Boolean Expression Complexity in Conditional Statements](/rules/max-bool-expr) — <code>#EC MAX_BOOL_EXPR</code>
* [Avoid Duplicate Conditions in Branching Statements and Logical Operators](/rules/no-dup-cond) — <code>#EC NO_DUP_COND</code>
* [Avoid Comparing Boolean Method Calls to abap_true or abap_false](/rules/no-bool-compare) — <code>#EC NO_BOOL_COMPARE</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_PREF_PAREN_AND_OR`
* **ABAP Implementation:** [/skyl/cl_pref_paren_and_or.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_pref_paren_and_or.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 86)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L86)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_PREF_PAREN_AND_OR&title=%5BBug%5D%3A%20Issue%20in%20pref-paren-and-or)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20pref-paren-and-or)**
