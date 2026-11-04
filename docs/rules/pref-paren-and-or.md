---
title: "Parenthesize Combinations of AND and OR"
description: "Parenthesize Combinations of AND and OR - Clean ABAP guidelines, modern SAP syntax rules, and automated ATC code inspection for SAP S/4HANA and ABAP Cloud."
keywords: "Clean ABAP, SAP ATC Check, ABAP Cloud, S/4HANA Readiness, pref-paren-and-or, clean-abap"
category: "clean-abap"
ruleId: "pref-paren-and-or"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L86"
---

# Parenthesize Combinations of AND and OR

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

Different programming languages and databases have varying operator precedences for logical operators. Unparenthesized conditions mixing AND and OR (such as a AND b OR c) are ambiguous to human readers and easily hide critical branching bugs. Explicitly parenthesize combinations as ( a AND b ) OR c to make evaluation precedence unmistakable.

### Non-Compliant

```abap
IF cond_a AND cond_b OR cond_c.
  step( ).
ENDIF.
```

### Compliant

```abap
IF ( cond_a AND cond_b ) OR cond_c.
  step( ).
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


## Related Rules

* [Limit Boolean Expression Complexity in Conditional Statements](/rules/max-bool-expr) — <code>#EC MAX_BOOL_EXPR</code>
* [Avoid Duplicate Branch Conditions](/rules/no-dup-cond) — <code>#EC NO_DUP_COND</code>
* [Avoid Comparing to abap_true / abap_false](/rules/no-bool-compare) — <code>#EC NO_BOOL_COMPARE</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_PREF_PAREN_AND_OR`
* **ABAP Implementation:** [/skyl/cl_pref_paren_and_or.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_pref_paren_and_or.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 86)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L86)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_PREF_PAREN_AND_OR&title=%5BBug%5D%3A%20Issue%20in%20pref-paren-and-or)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20pref-paren-and-or)**
