---
title: "Avoid Unindexed Nested LOOP AT Statements"
description: "Detect nested LOOP AT statements in ABAP to prevent O(N*M) performance bottlenecks and enforce parallel cursor or GROUP BY patterns."
keywords: "no-nested-loop, nested LOOP AT, parallel cursor, internal table performance, GROUP BY loop"
category: "performance"
ruleId: "no-nested-loop"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L5644"
---

# Avoid Unindexed Nested LOOP AT Statements

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Performance & Database" />
  <Badge type="danger" text="#EC NO_NESTED_LOOP" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L5644" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Disallow nested LOOP AT statements.

> **ATC Finding Message:** `Nested LOOP AT detected; avoid O(N*M) loops or use GROUP BY or parallel cursor`

## Rationale

Nesting unindexed `LOOP AT` statements against standard internal tables creates quadratic O(N*M) algorithmic complexity. As datasets grow in production, nested linear iterations consume excessive CPU time, exhaust work process runtimes, and cause severe performance degradation. Application logic requiring line matching between collections should utilize sorted/hashed secondary keys with targeted reads, modern `LOOP AT ... GROUP BY` constructs, or a parallel cursor approach using `LOOP AT ... FROM index WHERE ...`. The check reports `NO_NEST_LP` on nested table loops that omit grouping or index constraints.

### Non-Compliant

```abap
LOOP AT lt_sales_orders INTO ls_sales_order.
  LOOP AT lt_order_items INTO ls_order_item
    WHERE sales_order = ls_sales_order-sales_order.
    CLEAR ls_order_item.
  ENDLOOP.
ENDLOOP.
```

### Compliant

```abap
LOOP AT lt_sales_orders INTO ls_sales_order.
  LOOP AT lt_order_items INTO ls_order_item
    FROM lv_start_index
    WHERE sales_order = ls_sales_order-sales_order.
    CLEAR ls_order_item.
  ENDLOOP.
ENDLOOP.
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC NO_NESTED_LOOP

" SAP CI_ prefix format:
... "#EC CI_NO_NESTED_LOOP
```

## Exemptions and Performance Alternatives

The check ignores nested loops when either loop employs performance-optimized access patterns:

| Pattern | Detection | Rationale |
|---|---|---|
| Parallel Cursor | `LOOP AT itab FROM index ...` | Restricts inner loop scan start using a binary-search index (`sy-tabix`), avoiding full scans. |
| Grouping Loops | `LOOP AT itab ... GROUP BY ...` and `LOOP AT GROUP` | Native kernel grouping avoids quadratic traversal. |
| Non-table Loops | `DO ... ENDDO` or `WHILE ... ENDWHILE` | Only `LOOP AT <itab>` is evaluated. |
| Screen Loops | `LOOP AT SCREEN` | UI screen loops are explicitly exempted. |

To suppress intentional small-table nested loops, use `"#EC NO_NESTED_LOOP` or `##NO_NESTED_LOOP`.


## Related Rules

* [Filter Internal Tables with LOOP AT WHERE Instead of a CONTINUE Guard](/rules/pref-loop-where) — <code>#EC PREF_LOOP_WHERE</code>
* [Replace READ TABLE with Table Expressions and line_exists](/rules/pref-read-table) — <code>#EC PREF_TAB_EXPR</code>
* [Limit Jump Statements (CONTINUE and EXIT) per Loop](/rules/max-loop-jumps) — <code>#EC MAX_LOOP_JUMPS</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_NO_NESTED_LOOP`
* **ABAP Implementation:** [/skyl/cl_no_nested_loop.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_no_nested_loop.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 5644)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L5644)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_NO_NESTED_LOOP&title=%5BBug%5D%3A%20Issue%20in%20no-nested-loop)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20no-nested-loop)**
