---
title: "Avoid Comparing to abap_true / abap_false"
description: "Avoid Comparing to abap_true / abap_false - Clean ABAP guidelines, modern SAP syntax rules, and automated ATC code inspection for SAP S/4HANA and ABAP Cloud."
keywords: "Clean ABAP, SAP ATC Check, ABAP Cloud, S/4HANA Readiness, no-bool-compare, anti-patterns"
category: "anti-patterns"
ruleId: "no-bool-compare"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L710"
---

# Avoid Comparing to abap_true / abap_false

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Anti-Patterns & Bad Practices" />
  <Badge type="warning" text="QuickFix Ready" />
  <Badge type="danger" text="#EC NO_BOOL_COMPARE" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L710" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Avoid comparing boolean method calls to boolean literals.

> **ATC Finding Message:** `Avoid boolean comparison for method calls; call method directly`

## Rationale

A boolean expression already evaluates to true or false, so comparing it to abap_true is redundant. The comparison hides predicate intent and can mask a missing method call or an accidental assignment. Test the expression directly and use NOT when the negative case is needed.

### Non-Compliant

```abap
IF is_valid( ) = abap_false.
  RETURN.
ENDIF.
```

### Compliant

```abap
IF NOT is_valid( ).
  RETURN.
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
... "#EC NO_BOOL_COMPARE

" SAP CI_ prefix format:
... "#EC CI_NO_BOOL_COMPARE
```


## Related Rules

* [Limit Boolean Expression Complexity in Conditional Statements](/rules/max-bool-expr) — <code>#EC MAX_BOOL_EXPR</code>
* [Avoid CASE with a Single WHEN Branch](/rules/no-single-when) — <code>#EC NO_SINGLE_WHEN</code>
* [Avoid CHECK Statements](/rules/no-check-stmt) — <code>#EC NO_CHECK_IN_LOOP</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_NO_BOOL_COMPARE`
* **ABAP Implementation:** [/skyl/cl_no_bool_compare.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_no_bool_compare.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 710)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L710)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_NO_BOOL_COMPARE&title=%5BBug%5D%3A%20Issue%20in%20no-bool-compare)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20no-bool-compare)**
