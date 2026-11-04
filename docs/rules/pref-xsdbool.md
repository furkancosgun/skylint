---
title: "Replace IF/ELSE Boolean Assignments with xsdbool( )"
description: "Convert duplicated IF/ELSE flag assignments into a single xsdbool( ) expression to shorten boolean guards and remove dead branches in ABAP."
keywords: "pref-xsdbool, xsdbool, boolean expression, Clean ABAP, SAP ATC"
category: "clean-abap"
ruleId: "pref-xsdbool"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L1064"
---

# Replace IF/ELSE Boolean Assignments with xsdbool( )

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="warning" text="QuickFix Ready" />
  <Badge type="danger" text="#EC PREF_XSDBOOL" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L1064" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Prefer xsdbool( ) expression over manual IF-ELSE assignment.

> **ATC Finding Message:** `Prefer xsdbool( ) over manual IF-ELSE assignment`

## Rationale

When both branches of an IF only assign abap_true and abap_false to the same variable, the whole block is a single boolean expression written the long way. xsdbool( ) evaluates the condition once, returns a type-correct flag, and removes the duplicated branches so the two assignments can never drift apart during maintenance. The check only fires for the exact IF/assignment/ELSE/assignment/ENDIF shape, and its TOXSDBOOL QuickFix inverts the condition with NOT when the true branch holds the false literal.

### Non-Compliant

```abap
IF lv_available_quantity > lv_reorder_threshold.
  lv_is_reorder_required = abap_true.
ELSE.
  lv_is_reorder_required = abap_false.
ENDIF.
```

### Compliant

```abap
lv_is_reorder_required = xsdbool( lv_available_quantity > lv_reorder_threshold ).
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
... "#EC PREF_XSDBOOL

" SAP CI_ prefix format:
... "#EC CI_PREF_XSDBOOL
```

### Detected pattern

The rule only fires when the block consists of exactly five statements:

```abap
IF <condition>.
  <target> = abap_true.
ELSE.
  <target> = abap_false.
ENDIF.
```

Both assignments must target the same variable with opposite literals; an extra statement, a missing `ELSE`, or two different targets keep the `IF` untouched. When the true branch assigns `abap_false`, the QuickFix wraps the condition in `NOT ( ... )`. The finding code is `PREF_XSDBL` and the pseudo-comment is `"#EC PREF_XSDBOOL`.


## Related Rules

* [Limit Boolean Expression Complexity in Conditional Statements](/rules/max-bool-expr) — <code>#EC MAX_BOOL_EXPR</code>
* [Prefer CASE over Multiple IF / ELSEIF on the Same Variable](/rules/pref-case) — <code>#EC PREF_CASE</code>
* [Collapse Value-Mapping IF Chains into COND](/rules/pref-cond) — <code>#EC PREF_COND</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_PREF_XSDBOOL`
* **ABAP Implementation:** [/skyl/cl_pref_xsdbool.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_pref_xsdbool.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 1064)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L1064)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_PREF_XSDBOOL&title=%5BBug%5D%3A%20Issue%20in%20pref-xsdbool)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20pref-xsdbool)**
