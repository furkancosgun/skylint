---
title: "Avoid Unfiltered SELECT Statements on Database Tables"
description: "Prevent full database table scans in ABAP SQL by enforcing WHERE conditions on SELECT queries across SAP S/4HANA and ABAP Cloud."
keywords: "no-full-scan-sel, full table scan, SELECT WHERE, ABAP SQL performance, SAP HANA index"
category: "performance"
ruleId: "no-full-scan-sel"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L5672"
---

# Avoid Unfiltered SELECT Statements on Database Tables

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Performance & Database" />
  <Badge type="danger" text="#EC NO_FULL_SCAN_SELECT" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L5672" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Flag SELECT statements on DB tables without a WHERE clause.

> **ATC Finding Message:** `Avoid SELECT without a WHERE condition on database tables (full table scan)`

## Rationale

Executing a `SELECT` statement on a database table without a `WHERE` clause triggers a full table scan, bypassing primary and secondary database indexes. In production environments with millions of records in transactional or master data tables, full table scans saturate SAP HANA memory, exhaust network bandwidth between the database and application server, and cause severe response time degradation. Every database read must be restricted with an index-supported `WHERE` filter or explicitly bound using `UP TO n ROWS` when pagination or sampling is intended. The check reports `NO_FULL_SC` on unfiltered table reads.

### Non-Compliant

```abap
SELECT sales_order, customer_id, net_amount
  FROM zso_header
  INTO TABLE @DATA(lt_orders).
```

### Compliant

```abap
SELECT sales_order, customer_id, net_amount
  FROM zso_header
  WHERE customer_id = @lv_customer_id
    AND order_status = 'OPEN'
  INTO TABLE @DATA(lt_orders).
```

## Configuration & Thresholds

This check can be fine-tuned directly in the ATC Check Variant Editor (`CHKV`) in Eclipse ADT:

| Parameter Name | Data Type | Default Value | Description & Guidance |
|---|---|:---:|---|
| `ALLOW_UP_TO_N` | `Boolean` | <code>false</code> | Allow SELECT statements without an explicit WHERE clause when restricted by an UP TO n ROWS addition (default: false). |

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC NO_FULL_SCAN_SELECT

" SAP CI_ prefix format:
... "#EC CI_NO_FULL_SCAN_SELECT
```

## Configuration and Filtering Guidelines

| Parameter | Type | Default | Description |
|---|---|---|---|
| `ALLOW_UP_TO_N` | Boolean | `false` | When enabled (`true`), queries containing `UP TO n ROWS` are exempted from the `WHERE` requirement. |

### Exceptions and Behavior
- **Internal Table Queries:** Queries selecting from host internal tables (e.g. `SELECT ... FROM @lt_itab AS itab`) are automatically exempted because they do not query the database.
- **Table Buffering:** Even for buffered customizing tables, omitting `WHERE` can trigger full table buffer loads. Always provide key filters when reading specific records.
- **Suppression:** Legitimate administrative full-table extractors (e.g. archiving jobs or migration tools) can be suppressed using `"#EC NO_FULL_SCAN_SELECT` or `##NO_FULL_SCAN_SELECT`.


## Related Rules

* [Enforce WHERE Conditions on Database UPDATE and DELETE Statements](/rules/no-unfilt-dml) — <code>#EC NO_UNFILT_DML</code>
* [Avoid BYPASSING BUFFER in ABAP SQL Queries](/rules/no-bypass-buf) — <code>#EC NO_BYPASS_BUFFER</code>
* [Avoid SELECT * and Project Columns Explicitly](/rules/no-select-star) — <code>#EC NO_SELECT_STAR</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_NO_FULL_SCAN_SEL`
* **ABAP Implementation:** [/skyl/cl_no_full_scan_sel.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_no_full_scan_sel.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 5672)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L5672)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_NO_FULL_SCAN_SEL&title=%5BBug%5D%3A%20Issue%20in%20no-full-scan-sel)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20no-full-scan-sel)**
