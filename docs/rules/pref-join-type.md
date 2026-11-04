---
title: "Specify Explicit Join Types in ABAP SQL SELECT Statements"
description: "Require explicit join types such as INNER JOIN or LEFT OUTER JOIN in ABAP SQL SELECT queries for clear cardinality and readability."
keywords: "pref-join-type, INNER JOIN, ABAP SQL, Open SQL, Clean ABAP"
category: "clean-abap"
ruleId: "pref-join-type"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L3665"
---

# Specify Explicit Join Types in ABAP SQL SELECT Statements

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="warning" text="QuickFix Ready" />
  <Badge type="danger" text="#EC PREF_JOIN_TYPE" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L3665" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Prefer an explicit JOIN type such as INNER JOIN.

> **ATC Finding Message:** `Specify the JOIN type explicitly, for example INNER JOIN`

## Rationale

In ABAP SQL, writing a bare JOIN defaults implicitly to an INNER JOIN, but the implicit behavior is invisible at the call site and frequently misread during code reviews as an outer join. Explicitly qualifying joins as INNER JOIN, LEFT OUTER JOIN, RIGHT OUTER JOIN, or CROSS JOIN documents intended data cardinality and eliminates ambiguity. Skylint flags any bare JOIN token in SELECT statements with PREF_JOINT and provides the ADD_INNER quickfix to insert the explicit INNER keyword.

### Non-Compliant

```abap
SELECT sales_order~sales_order, item~material
  FROM zsales_order AS sales_order
  JOIN zsales_item AS item ON sales_order~sales_order = item~sales_order
  WHERE sales_order~order_type = 'SO'
  INTO TABLE @DATA(lt_order_details).
```

### Compliant

```abap
SELECT sales_order~sales_order, item~material
  FROM zsales_order AS sales_order
  INNER JOIN zsales_item AS item ON sales_order~sales_order = item~sales_order
  WHERE sales_order~order_type = 'SO'
  INTO TABLE @DATA(lt_order_details).
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
... "#EC PREF_JOIN_TYPE

" SAP CI_ prefix format:
... "#EC CI_PREF_JOIN_TYPE
```

## Detection and Quickfix Details

The check evaluates tokens in `SELECT` statements. When a `JOIN` keyword is encountered without an immediate preceding qualifier (`INNER`, `LEFT`, `RIGHT`, `OUTER`, or `CROSS`), finding `PREF_JOINT` is reported. The `ADD_INNER` quickfix replaces the bare `JOIN` token with `INNER JOIN` in-place while retaining statement formatting.

Suppress findings using pseudo comment `"#EC PREF_JOIN_TYPE`.


## Related Rules

* [Require Explicit ORDER BY with UP TO N ROWS Clauses](/rules/pref-order-by) — <code>#EC PREF_ORDER_BY</code>
* [Avoid Database Queries Inside Loops (N+1 Query Antipattern)](/rules/no-db-in-loop) — <code>#EC NO_DB_IN_LOOP</code>
* [Guard FOR ALL ENTRIES Against Empty Driving Tables](/rules/no-empty-fae) — <code>#EC NO_EMPTY_FAE</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_PREF_JOIN_TYPE`
* **ABAP Implementation:** [/skyl/cl_pref_join_type.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_pref_join_type.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 3665)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L3665)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_PREF_JOIN_TYPE&title=%5BBug%5D%3A%20Issue%20in%20pref-join-type)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20pref-join-type)**
