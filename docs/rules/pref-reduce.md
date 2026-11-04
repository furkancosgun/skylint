---
title: "Replace Single-Statement Aggregation LOOP with REDUCE"
description: "Replace a LOOP that only accumulates a running total with a single REDUCE expression and remove mutable accumulator variables."
keywords: "pref-reduce, REDUCE, LOOP AT, aggregation, Clean ABAP"
category: "clean-abap"
ruleId: "pref-reduce"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L238"
---

# Replace Single-Statement Aggregation LOOP with REDUCE

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="danger" text="#EC PREF_REDUCE" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L238" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Prefer REDUCE #( ) expression over simple aggregation LOOP.

> **ATC Finding Message:** `Prefer REDUCE #( ) expression over simple aggregation LOOP`

## Rationale

A LOOP whose body is one self-referential assignment such as total = total + line-amount carries mutable state, an explicit work area and three lines of control flow to express a single calculation. REDUCE states the same aggregation as one expression, cannot leak an uninitialized accumulator and makes the iteration variable local to the expression. The check reports PREF_REDUC only when the loop body is exactly one such assignment, so loops with side effects or filtering stay untouched.

### Non-Compliant

```abap
LOOP AT lt_order_items INTO ls_order_item.
  lv_total_amount = lv_total_amount + ls_order_item-amount.
ENDLOOP.
```

### Compliant

```abap
lv_total_amount = REDUCE #( INIT lv_sum = CONV ty_amount( 0 )
                            FOR ls_order_item IN lt_order_items
                            NEXT lv_sum = lv_sum + ls_order_item-amount ).
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC PREF_REDUCE

" SAP CI_ prefix format:
... "#EC CI_PREF_REDUCE
```

## Narrow Trigger Conditions

A LOOP is reported only when all of the following hold:

- the loop reads `LOOP AT itab INTO ls_line` or `LOOP AT itab ASSIGNING <ls_line>`,
- the body consists of a single assignment with the shape `total = total + ...`,
- that assignment references the loop work area or field symbol,
- no `WHERE` or `GROUP BY` addition is present,
- the loop closes immediately with `ENDLOOP`.

Additional statements, a second accumulator, an `APPEND` or `COLLECT` aggregation, or a filtered loop keep the statement unflagged. Those cases are better served by a dedicated helper method than by squeezing side effects into `REDUCE`.


## Related Rules

* [Use lines( ) Instead of DESCRIBE TABLE LINES](/rules/pref-lines) — <code>#EC PREF_LINES</code>
* [Replace READ TABLE with Table Expressions and line_exists](/rules/pref-read-table) — <code>#EC PREF_TAB_EXPR</code>
* [Prefer ASSIGNING Field Symbols Over LOOP INTO Copy Targets](/rules/no-loop-into) — <code>#EC NO_LOOP_INTO</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_PREF_REDUCE`
* **ABAP Implementation:** [/skyl/cl_pref_reduce.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_pref_reduce.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 238)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L238)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_PREF_REDUCE&title=%5BBug%5D%3A%20Issue%20in%20pref-reduce)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20pref-reduce)**
