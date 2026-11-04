---
title: "Filter Internal Tables with LOOP AT WHERE Instead of a CONTINUE Guard"
description: "Replace leading IF CONTINUE guards with LOOP AT WHERE in ABAP internal table loops - fewer visited rows, less nesting and clearer table filtering."
keywords: "LOOP AT WHERE, ABAP CONTINUE guard, pref-loop-where, internal table filter, Clean ABAP"
category: "clean-abap"
ruleId: "pref-loop-where"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L5296"
---

# Filter Internal Tables with LOOP AT WHERE Instead of a CONTINUE Guard

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="danger" text="#EC PREF_LOOP_WHERE" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L5296" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Filter LOOP AT With a WHERE Clause.

> **ATC Finding Message:** `Loop starts with an IF CONTINUE guard - filter rows with WHERE instead`

## Rationale

Filtering with an initial IF ... CONTINUE guard forces the loop to visit every row of the table: the runtime assigns the row to the work area, the body starts, the condition is evaluated and the iteration is abandoned. With LOOP AT ... WHERE the table is filtered during traversal, so non-matching rows never reach the loop body, which is faster on large tables and much easier to read because the filter appears in the LOOP header instead of the first three lines of the body. The check reports PREF_LOOPW when the statements immediately after LOOP are exactly IF, CONTINUE, ENDIF. Moving the condition to WHERE also removes one nesting level and makes the loop body contain only the real business logic.

### Non-Compliant

```abap
DATA(lv_open_count) = 0.
LOOP AT lt_sales_orders INTO DATA(ls_order).
  IF ls_order-status <> 'OPEN'.
    CONTINUE.
  ENDIF.
  lv_open_count += 1.
ENDLOOP.
```

### Compliant

```abap
DATA(lv_open_count) = 0.
LOOP AT lt_sales_orders INTO DATA(ls_order) WHERE status = 'OPEN'.
  lv_open_count += 1.
ENDLOOP.
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC PREF_LOOP_WHERE

" SAP CI_ prefix format:
... "#EC CI_PREF_LOOP_WHERE
```

## Detected pattern

The finding is raised when the three statements directly after `LOOP` are exactly:

```abap
LOOP AT lt_sales_orders INTO DATA(ls_order).
  IF ls_order-status <> 'OPEN'.
    CONTINUE.
  ENDIF.
  ...
ENDLOOP.
```

## Why the pattern is strict

- Any statement between `LOOP` and the `IF` (even an initialisation) prevents detection, because the guard is no longer a pure loop filter.
- A guard whose body contains more than one `CONTINUE` is not reported - that logic is not a filter.
- Nested loops are analyzed independently, so a guard inside the inner loop is reported on the inner `LOOP`.

## Better alternatives

| Goal | Idiomatic ABAP |
| --- | --- |
| Filter by one component | `LOOP AT lt_sales_orders INTO DATA(ls_order) WHERE status = 'OPEN'.` |
| Filter by a complex condition | `LOOP AT lt_sales_orders INTO DATA(ls_order) WHERE total > 100 AND currency = 'EUR'.` |
| Filter once, reuse the result | `DATA(lt_open) = FILTER #( lt_sales_orders WHERE status = 'OPEN' ).` |
| Direct component access without a work area | `LOOP AT lt_sales_orders ASSIGNING FIELD-SYMBOL(<ls_order>) WHERE status = 'OPEN'.` |

Pseudo-comment: `"#EC PREF_LOOP_WHERE` on the `LOOP` statement.


## Related Rules

* [Merge Redundant Nested IF Blocks](/rules/pref-merge-ifs) — <code>#EC PREF_MERGE_IFS</code>
* [Remove CONTINUE Immediately Before a Loop End](/rules/no-useless-cont) — <code>#EC NO_USELESS_CONT</code>
* [Replace READ TABLE with Table Expressions and line_exists](/rules/pref-read-table) — <code>#EC PREF_TAB_EXPR</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_PREF_LOOP_WHERE`
* **ABAP Implementation:** [/skyl/cl_pref_loop_where.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_pref_loop_where.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 5296)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L5296)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_PREF_LOOP_WHERE&title=%5BBug%5D%3A%20Issue%20in%20pref-loop-where)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20pref-loop-where)**
