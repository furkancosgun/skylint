---
title: "Avoid Duplicate Conditions in Branching Statements and Logical Operators"
description: "Detect duplicate branch conditions in IF/CASE and identical operands in boolean expressions in SAP ATC."
keywords: "no-dup-cond, duplicate condition, unreachable branch, Clean ABAP, SAP ATC"
category: "anti-patterns"
ruleId: "no-dup-cond"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L864"
---

# Avoid Duplicate Conditions in Branching Statements and Logical Operators

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Anti-Patterns & Bad Practices" />
  <Badge type="warning" text="QuickFix Ready" />
  <Badge type="danger" text="#EC NO_DUP_COND" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L864" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Avoid duplicate branch conditions in IF and CASE.

> **ATC Finding Messages:**
> - `Identical condition in branch; duplicate branch is unreachable`
> - `Identical operand in condition; remove the duplicate comparison`

## Rationale

A duplicated condition in an ELSEIF or WHEN branch can never be executed because the earlier branch with the identical condition always intercepts control first. Similarly, repeating the same operand within a single logical expression (such as cond OR cond or cond AND cond) is redundant and often masks a typographical error where an intended alternative condition was omitted. In Clean ABAP, every conditional branch must possess a distinct predicate and logical expressions must contain unique operands. The check reports NO_DUP_CND or NO_DUP_OPR and provides the REM_DUP_BR quickfix.

### Non-Compliant

```abap
IF lv_delivery_status = 'DELIVERED'.
  complete_order( ).
ELSEIF lv_delivery_status = 'DELIVERED'.
  archive_order( ).
ENDIF.
```

### Compliant

```abap
IF lv_delivery_status = 'DELIVERED'.
  complete_order( ).
ELSEIF lv_delivery_status = 'RETURNED'.
  archive_order( ).
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
... "#EC NO_DUP_COND

" SAP CI_ prefix format:
... "#EC CI_NO_DUP_COND
```

### Finding Codes and Detection Modes

The check inspects both branching structures and compound boolean expressions:

| Finding Code | Trigger Condition | QuickFix |
|---|---|---|
| `NO_DUP_CND` | Duplicate condition in `ELSEIF` or duplicate value in `WHEN` | `REM_DUP_BR` removes unreachable branch |
| `NO_DUP_OPR` | Duplicate operand within `IF`, `WHILE`, `CHECK`, or `ELSEIF` joined by same operator (`AND`/`OR`) | Manual review required |

Outer parentheses are stripped before comparing expressions, so `ELSEIF ( lv_status = 'A' )` correctly matches `IF lv_status = 'A'`. Suppress findings using `"#EC NO_DUP_COND`.


## Related Rules

* [Avoid Yoda Conditions by Placing Variables Before Literals](/rules/no-yoda-cond) — <code>#EC NO_YODA_COND</code>
* [Avoid Negated IF Conditions with an ELSE Branch by Inverting Condition and Swapping Branches](/rules/no-neg-cond) — <code>#EC NO_NEG_COND</code>
* [Collapse Value-Mapping IF Chains into COND](/rules/pref-cond) — <code>#EC PREF_COND</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_NO_DUP_COND`
* **ABAP Implementation:** [/skyl/cl_no_dup_cond.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_no_dup_cond.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 864)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L864)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_NO_DUP_COND&title=%5BBug%5D%3A%20Issue%20in%20no-dup-cond)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20no-dup-cond)**
