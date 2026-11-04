---
title: "Guard FOR ALL ENTRIES Against Empty Driving Tables"
description: "Prevent disastrous full table scans and TSV_TNEW_PAGE_ALLOC_FAILED dumps in ABAP by guarding FOR ALL ENTRIES queries with an empty table check."
keywords: "no-empty-fae, FOR ALL ENTRIES, full table scan, Clean ABAP Open SQL, SAP ATC"
category: "performance"
ruleId: "no-empty-fae"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L1469"
---

# Guard FOR ALL ENTRIES Against Empty Driving Tables

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Performance & Database" />
  <Badge type="warning" text="QuickFix Ready" />
  <Badge type="danger" text="#EC NO_EMPTY_FAE" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L1469" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Unsecure FOR ALL ENTRIES (Missing empty itab check).

> **ATC Finding Message:** `FOR ALL ENTRIES without preceding IS NOT INITIAL check causes full table scan`

## Rationale

In SAP Open SQL, if the driving internal table specified in a FOR ALL ENTRIES clause is initial (empty) at runtime, the database interface silently strips the entire WHERE condition. This transforms a targeted query into a catastrophic full-table scan (SELECT * FROM dbtab), retrieving millions of unintended rows, exhausting application server memory with TSV_TNEW_PAGE_ALLOC_FAILED runtime errors, and exhausting database shared locks. In Clean ABAP and ABAP Cloud, every FOR ALL ENTRIES query must be guarded by an explicit empty check on the driving internal table before invoking the database.

### Non-Compliant

```abap
SELECT order_id, item_id, material_number, net_amount
  FROM zorder_items
  FOR ALL ENTRIES IN @lt_orders
  WHERE order_id = @lt_orders-order_id
  INTO TABLE @DATA(lt_items).
```

### Compliant

```abap
IF lt_orders IS NOT INITIAL.
  SELECT order_id, item_id, material_number, net_amount
    FROM zorder_items
    FOR ALL ENTRIES IN @lt_orders
    WHERE order_id = @lt_orders-order_id
    INTO TABLE @DATA(lt_items).
ELSE.
  CLEAR lt_items.
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
... "#EC NO_EMPTY_FAE

" SAP CI_ prefix format:
... "#EC CI_NO_EMPTY_FAE
```

### Detection Details

The check inspects `SELECT` statements containing `FOR ALL ENTRIES IN`, resolves the driving table identifier (handling `@`, `ME->`, and `[]`), and scans preceding statements to confirm an active guard. Finding code `NO_EMPTFAE` is raised when the query is unguarded.

### Recognized Guards

- `IF lt_table IS NOT INITIAL.` enclosing the query.
- `CHECK lt_table IS NOT INITIAL.` prior to the query.
- `IF lines( lt_table ) > 0.` or `IF line_exists( lt_table[ ... ] ).`
- Early exit blocks: `IF lt_table IS INITIAL. RETURN. ENDIF.` (also `EXIT` or `RAISE`).

### Quickfix

The `FAEGUARD` quickfix automatically wraps the offending `SELECT` statement inside an `IF <driving_tab> IS NOT INITIAL.` / `ENDIF.` block with matching indentation.

Suppress intentional full scans with the pseudo comment `"#EC NO_EMPTY_FAE`.


## Related Rules

* [Require Explicit ORDER BY with UP TO N ROWS Clauses](/rules/pref-order-by) — <code>#EC PREF_ORDER_BY</code>
* [Avoid Database Queries Inside Loops (N+1 Query Antipattern)](/rules/no-db-in-loop) — <code>#EC NO_DB_IN_LOOP</code>
* [Avoid SELECT * and Project Columns Explicitly](/rules/no-select-star) — <code>#EC NO_SELECT_STAR</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_NO_EMPTY_FAE`
* **ABAP Implementation:** [/skyl/cl_no_empty_fae.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_no_empty_fae.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 1469)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L1469)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_NO_EMPTY_FAE&title=%5BBug%5D%3A%20Issue%20in%20no-empty-fae)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20no-empty-fae)**
