---
title: "Use BETWEEN for Inclusive Range Checks"
description: "Simplify ABAP range checks from duplicated comparisons to the readable BETWEEN operator and avoid off-by-one mistakes in ATC-reviewed code."
keywords: "ABAP BETWEEN operator, range check ABAP, Clean ABAP condition, SAP ATC, pref-between"
category: "clean-abap"
ruleId: "pref-between"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L4357"
---

# Use BETWEEN for Inclusive Range Checks

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="warning" text="QuickFix Ready" />
  <Badge type="danger" text="#EC PREF_BETWEEN" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L4357" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Prefer BETWEEN for inclusive range checks.

> **ATC Finding Message:** `Combine the duplicated range comparison with BETWEEN`

## Rationale

A condition like `amount >= min AND amount <= max` repeats the operand and hides one idea - an inclusive range - behind two comparisons that must stay symmetric; editing only one operator silently changes the semantics. BETWEEN states the range once, cannot be half-edited and removes the duplicated token that reviewers have to compare by eye. The check reports only genuine `>=`/`<=` pairs by default, because `>`/`<` is not equivalent for packed or fractional values.

### Non-Compliant

```abap
IF lv_amount >= lv_min_amount AND lv_amount <= lv_max_amount.
  approve_payment( ).
ENDIF.
```

### Compliant

```abap
IF lv_amount BETWEEN lv_min_amount AND lv_max_amount.
  approve_payment( ).
ENDIF.
```

## Automated QuickFix

This rule provides an **automated QuickFix** directly in Eclipse ABAP Development Tools (ADT):
1. Position the cursor on the flagged statement.
2. Press <kbd>Ctrl</kbd> + <kbd>1</kbd> (Quick Assist).
3. Select the automated refactoring to apply the clean syntax immediately.

## Configuration & Thresholds

This check can be fine-tuned directly in the ATC Check Variant Editor (`CHKV`) in Eclipse ADT:

| Parameter Name | Data Type | Default Value | Description & Guidance |
|---|---|:---:|---|
| `STRICT_RANGE` | `Boolean` | <code>false</code> | Also report strict > / < pairs; keep disabled because BETWEEN is inclusive and strict ranges are not equivalent for decimals (default disabled). |

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC PREF_BETWEEN

" SAP CI_ prefix format:
... "#EC CI_PREF_BETWEEN
```

### Recognised range shapes

`PREF_BETWN` is raised when exactly one `AND` at parenthesis depth zero joins two comparisons whose operands form a range:

| Shape | Example |
| --- | --- |
| same operand on the left | `lv_amount >= lv_min AND lv_amount <= lv_max` |
| same operand on the right | `lv_min <= lv_amount AND lv_max >= lv_amount` |
| chained on the left operand | `lv_min <= lv_amount AND lv_amount <= lv_max` |
| mirrored | `lv_amount >= lv_min AND lv_max >= lv_amount` |

Outer parentheses are stripped, so `IF ( lv_amount >= lv_min ) AND ( lv_amount <= lv_max ).` is recognised too. The `USE_BTWN` quickfix rewrites the complete `IF`, `ELSEIF`, `WHILE` or `CHECK` line as `<keyword> <operand> BETWEEN <low> AND <high>.`

### Deliberately not reported

- `OR` conditions, negations, and statements with more than one `AND` on the same level.
- Different operands, for example `lv_amount >= lv_min AND lv_quantity <= lv_max`.
- Statements with fewer than eight tokens, typically a single comparison.
- Strict `>` / `<` pairs unless `STRICT_RANGE` is enabled - and even then the suggestion is only a hint, because `BETWEEN` is inclusive on both ends.

Only swap when the original condition really includes its bounds; otherwise keep the explicit comparisons and add `"#EC PREF_BETWEEN`.


## Related Rules

* [Limit Boolean Expression Complexity in Conditional Statements](/rules/max-bool-expr) — <code>#EC MAX_BOOL_EXPR</code>
* [Remove Redundant Parentheses in Boolean and Assignment Expressions](/rules/no-many-parens) — <code>#EC NO_MANY_PARENS</code>
* [Avoid Duplicate Conditions in Branching Statements and Logical Operators](/rules/no-dup-cond) — <code>#EC NO_DUP_COND</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_PREF_BETWEEN`
* **ABAP Implementation:** [/skyl/cl_pref_between.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_pref_between.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 4357)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L4357)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_PREF_BETWEEN&title=%5BBug%5D%3A%20Issue%20in%20pref-between)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20pref-between)**
