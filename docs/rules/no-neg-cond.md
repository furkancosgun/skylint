---
title: "Avoid Negated IF Conditions with an ELSE Branch by Inverting Condition and Swapping Branches"
description: "Invert negated IF conditions with ELSE branches in ABAP to prioritize positive control flow and enhance Clean ABAP readability."
keywords: "no-neg-cond, negated condition, IF ELSE, boolean logic, Clean ABAP"
category: "clean-abap"
ruleId: "no-neg-cond"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L3866"
---

# Avoid Negated IF Conditions with an ELSE Branch by Inverting Condition and Swapping Branches

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="danger" text="#EC NO_NEG_COND" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L3866" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Avoid negated IF conditions with ELSE.

> **ATC Finding Message:** `Invert the condition and swap the branches`

## Rationale

A negated condition accompanied by an ELSE branch forces readers to perform mental double negation before grasping the primary execution path. Formulating the positive condition first and swapping the statements between the IF and ELSE blocks makes the dominant logic immediately visible and easier to reason about. Skylint checks for standalone negated conditions in IF statements possessing a plain ELSE branch (without intermediate ELSEIF branches) and reports NO_NEG_CND.

### Non-Compliant

```abap
IF NOT lv_is_authorized = abap_true.
  reject_invoice( ).
ELSE.
  approve_invoice( ).
ENDIF.
```

### Compliant

```abap
IF lv_is_authorized = abap_true.
  approve_invoice( ).
ELSE.
  reject_invoice( ).
ENDIF.
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC NO_NEG_COND

" SAP CI_ prefix format:
... "#EC CI_NO_NEG_COND
```

## Scope and Exclusions

The check evaluates `IF` statements that satisfy all of the following conditions:

- The condition is negated at the root level using `NOT` or relational inequality operators (`<>`, `NE`).
- The condition does not combine terms using `AND` or `OR`.
- The statement contains an `ELSE` block without any intervening `ELSEIF` statements.
- Dedicated predicate negations (such as `IS NOT INITIAL`, `IS NOT BOUND`, `IS NOT ASSIGNED`, `IS NOT SUPPLIED`) are ignored as they are governed by dedicated rules.

Suppress findings using pseudo comment `"#EC NO_NEG_COND`.


## Related Rules

* [Collapse Value-Mapping IF Chains into COND](/rules/pref-cond) — <code>#EC PREF_COND</code>
* [Avoid Yoda Conditions by Placing Variables Before Literals](/rules/no-yoda-cond) — <code>#EC NO_YODA_COND</code>
* [Avoid Duplicate Conditions in Branching Statements and Logical Operators](/rules/no-dup-cond) — <code>#EC NO_DUP_COND</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_NO_NEG_COND`
* **ABAP Implementation:** [/skyl/cl_no_neg_cond.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_no_neg_cond.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 3866)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L3866)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_NO_NEG_COND&title=%5BBug%5D%3A%20Issue%20in%20no-neg-cond)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20no-neg-cond)**
