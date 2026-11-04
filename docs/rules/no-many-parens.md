---
title: "Remove Redundant Parentheses in Boolean and Assignment Expressions"
description: "Detect and remove redundant parentheses in ABAP conditions and assignments using automated Clean ABAP ATC quickfixes."
keywords: "no-many-parens, Clean ABAP, redundant parentheses, IF condition, SAP ATC, quickfix"
category: "anti-patterns"
ruleId: "no-many-parens"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L2986"
---

# Remove Redundant Parentheses in Boolean and Assignment Expressions

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Anti-Patterns & Bad Practices" />
  <Badge type="warning" text="QuickFix Ready" />
  <Badge type="danger" text="#EC NO_MANY_PARENS" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L2986" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Remove redundant parentheses.

> **ATC Finding Message:** `Parentheses wrap a complete expression and can be removed`

## Rationale

Wrapping single comparison clauses, entire simple conditions, or elementary assignments in unnecessary parentheses clutters source code without changing operator precedence or runtime behavior. Redundant parentheses create visual noise, make expressions appear deceptively complex, and often remain as remnants from incomplete refactorings. Clean ABAP advises keeping expressions minimal and retaining parentheses only where logical precedence or grouping genuinely requires them. The ATC check reports NO_MNY_PAR and provides the NOPARENS quickfix.

### Non-Compliant

```abap
IF ( lv_order_status = 'APPROVED' ).
  process_purchase_order( iv_order_id = lv_order_id ).
ENDIF.
```

### Compliant

```abap
IF lv_order_status = 'APPROVED'.
  process_purchase_order( iv_order_id = lv_order_id ).
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
... "#EC NO_MANY_PARENS

" SAP CI_ prefix format:
... "#EC CI_NO_MANY_PARENS
```

## Detection and Quickfix Details

The check inspects `IF`, `ELSEIF`, `WHILE`, `CHECK`, and `COMPUTE` statements. It determines whether an outer pair of parentheses encloses the complete condition or whether a single comparison clause without logical operators is redundantly bracketed. The automated `NOPARENS` quickfix flattens the statement by removing the unnecessary outer parentheses.

### Excluded Scenarios
Expressions containing constructor operators (`VALUE`, `COND`, `CONV`, `SWITCH`, `REDUCE`, `NEW`), `NOT` negation boundaries, or mixed `AND`/`OR` precedence groups are intentionally preserved.

### Suppression
Suppress with pseudo comment `"#EC NO_MANY_PARENS`.


## Related Rules

* [Replace Single-Branch CASE Statements with IF Conditions](/rules/no-single-when) — <code>#EC NO_SINGLE_WHEN</code>
* [Avoid CHECK Statements Inside and Outside Iteration Loops](/rules/no-check-stmt) — <code>#EC NO_CHECK_IN_LOOP</code>
* [Avoid Comparing Boolean Method Calls to abap_true or abap_false](/rules/no-bool-compare) — <code>#EC NO_BOOL_COMPARE</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_NO_MANY_PARENS`
* **ABAP Implementation:** [/skyl/cl_no_many_parens.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_no_many_parens.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 2986)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L2986)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_NO_MANY_PARENS&title=%5BBug%5D%3A%20Issue%20in%20no-many-parens)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20no-many-parens)**
