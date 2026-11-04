---
title: "Disallow Nested LOOP AT Statements Without FROM or GROUP BY"
description: "Disallow nested LOOP AT statements without FROM or GROUP BY in ABAP to prevent O(N*M) performance degradation."
keywords: "ABAP Nested LOOP, Parallel Cursor, Internal Table Performance, Clean ABAP, GROUP BY loop"
category: "performance"
ruleId: "no-nested-loop"
---

# Disallow Nested LOOP AT Statements Without FROM or GROUP BY

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Performance & Database" />
  <Badge type="danger" text="#EC NO_NESTED_LOOP" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Disallow nested LOOP AT statements.

> **ATC Finding Message:** `Nested LOOP AT detected; avoid O(N*M) loops or use GROUP BY or parallel cursor`

## Rationale

Nesting internal table loops (LOOP AT within LOOP AT) creates O(N*M) Cartesian complexity that scales poorly with larger datasets and degrades application performance. Use GROUP BY loops, hashed/sorted secondary keys, or parallel cursor (LOOP AT itab FROM sy-tabix) instead.

### Non-Compliant

```abap
LOOP AT lt_orders INTO ls_order.
  LOOP AT lt_items INTO ls_item.
    " O(N*M) quadratic loop
  ENDLOOP.
ENDLOOP.
```

### Compliant

```abap
LOOP AT lt_orders INTO ls_order.
  LOOP AT lt_items INTO ls_item FROM lv_start WHERE order_id = ls_order-order_id.
    " Parallel cursor or filtered loop
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


## Related Rules

* [Prefer LOOP AT WHERE over IF CONTINUE Guards](/rules/pref-loop-where) — <code>#EC PREF_LOOP_WHERE</code>
* [Modernize READ TABLE (Table Expressions & line_exists)](/rules/pref-read-table) — <code>#EC PREF_TAB_EXPR</code>
* [Limit Jump Statements (CONTINUE, EXIT) per Loop](/rules/max-loop-jumps) — <code>#EC MAX_LOOP_JUMPS</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_NO_NESTED_LOOP`
* **Implementation File:** [#skyl#cl_no_nested_loop.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_no_nested_loop.clas.abap)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_NO_NESTED_LOOP&title=%5BBug%5D%3A%20Issue%20in%20no-nested-loop)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20no-nested-loop)**
