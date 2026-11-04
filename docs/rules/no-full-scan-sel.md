---
title: "Avoid Unfiltered SELECT on Database Tables (Full Table Scan Prevention)"
description: "Prevent full table scans in ABAP SQL by enforcing WHERE conditions on database SELECT statements."
keywords: "ABAP Full Table Scan, SELECT without WHERE, Database Index Optimization, HANA Performance"
category: "performance"
ruleId: "no-full-scan-sel"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L5481"
---

# Avoid Unfiltered SELECT on Database Tables (Full Table Scan Prevention)

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Performance & Database" />
  <Badge type="danger" text="#EC NO_FULL_SCAN_SELECT" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L5481" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Flag SELECT statements on DB tables without a WHERE clause.

> **ATC Finding Message:** `Avoid SELECT without a WHERE condition on database tables (full table scan)`

## Rationale

Executing a `SELECT` statement on a database table without an explicit `WHERE` clause reads every single row in the table, bypassing database indexes and causing full table scans. On large transactional or master data tables, this exhausts database memory, saturates network bandwidth, and leads to critical system performance degradation.

**Standard:** Always filter database reads with an index-backed `WHERE` condition. For paging or sampling, use `UP TO n ROWS`.

### Non-Compliant

```abap
" Critical: Scans millions of database rows
SELECT * FROM t000 INTO TABLE @DATA(lt_data).
```

### Compliant

```abap
" Optimized: Targeted read with WHERE filter
SELECT * FROM t000
  WHERE mandt = '100'
  INTO TABLE @DATA(lt_data).
```

## Configuration & Thresholds

This check can be fine-tuned directly in the ATC Check Variant Editor (`CHKV`) in Eclipse ADT:

| Parameter Name | Data Type | Default Value | Description & Guidance |
|---|---|:---:|---|
| `ALLOW_UP_TO_N` | `Boolean` | <code>false</code> | Allow SELECT statements without a WHERE clause when restricted by UP TO n ROWS |

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC NO_FULL_SCAN_SELECT

" SAP CI_ prefix format:
... "#EC CI_NO_FULL_SCAN_SELECT
```


## Related Rules

* [Avoid UPDATE or DELETE Without a WHERE Condition (Catastrophic Data Wipe Prevention)](/rules/no-unfilt-dml) — <code>#EC NO_UNFILT_DML</code>
* [Avoid BYPASSING BUFFER in SELECT Statements](/rules/no-bypass-buf) — <code>#EC NO_BYPASS_BUFFER</code>
* [Avoid SELECT * in OpenSQL Queries (Minimize Memory & Network Overhead)](/rules/no-select-star) — <code>#EC NO_SELECT_STAR</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_NO_FULL_SCAN_SEL`
* **ABAP Implementation:** [/skyl/cl_no_full_scan_sel.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_no_full_scan_sel.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 5481)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L5481)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_NO_FULL_SCAN_SEL&title=%5BBug%5D%3A%20Issue%20in%20no-full-scan-sel)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20no-full-scan-sel)**
