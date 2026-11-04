---
title: "Enforce WHERE Conditions on Database UPDATE and DELETE Statements"
description: "Prevent catastrophic full-table data deletion or corruption in ABAP OpenSQL by requiring WHERE clauses on UPDATE and DELETE."
keywords: "no-unfilt-dml, DELETE without WHERE, OpenSQL DML Security, UPDATE SET WHERE, Clean ABAP, SAP ATC"
category: "security"
ruleId: "no-unfilt-dml"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L3777"
---

# Enforce WHERE Conditions on Database UPDATE and DELETE Statements

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Security & Robustness" />
  <Badge type="danger" text="#EC NO_UNFILT_DML" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L3777" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Flag DML without WHERE on database tables.

> **ATC Finding Message:** `Filter database writes with a WHERE condition`

## Rationale

Executing OpenSQL UPDATE ... SET or DELETE FROM statements on database tables without an explicit WHERE clause mutates or truncates every record in the entire database table. In enterprise production systems, an unfiltered DML statement leads to catastrophic data destruction or widespread corruption, bringing core business processes to an immediate halt and requiring emergency database restorations. Clean ABAP, SAP ATC robustness checks, and ABAP Cloud Contract C1 require all OpenSQL database writes to be strictly bounded by explicit top-level WHERE conditions to guarantee precise transaction boundaries.

### Non-Compliant

```abap
DELETE FROM zorder_items.
```

### Compliant

```abap
DELETE FROM zorder_items
  WHERE order_id = @lv_order_id.

IF sy-subrc <> 0.
  " Record not found or already deleted
ENDIF.
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC NO_UNFILT_DML

" SAP CI_ prefix format:
... "#EC CI_NO_UNFILT_DML
```

## Scope of DML Inspection

The check inspects OpenSQL statements that modify persistent database tables:

| OpenSQL Statement | Condition Checked | Action Taken |
|---|---|---|
| `DELETE FROM <dbtab>` | Absence of top-level `WHERE` | Flagged with finding `NO_UNF_DML` |
| `UPDATE <dbtab> SET ...` | Absence of top-level `WHERE` | Flagged with finding `NO_UNF_DML` |
| `DELETE FROM <dbtab> WHERE ...` | Presence of `WHERE` at parenthesis depth 0 | Passed (compliant) |
| `UPDATE <dbtab> SET ... WHERE ...` | Presence of `WHERE` at parenthesis depth 0 | Passed (compliant) |
| `DELETE itab` (internal table) | In-memory table operation | Ignored (non-database access) |

Note that subquery `WHERE` clauses inside `SET` expressions do not count as top-level table filters. Suppress legitimate mass cleanup operations on temporary staging tables with `"#EC NO_UNFILT_DML` or `##NO_UNFILT_DML`.


## Related Rules

* [Avoid Database Queries Inside Loops (N+1 Query Antipattern)](/rules/no-db-in-loop) — <code>#EC NO_DB_IN_LOOP</code>
* [Avoid SELECT * and Project Columns Explicitly](/rules/no-select-star) — <code>#EC NO_SELECT_STAR</code>
* [Verify sy-subrc Promptly After Data Retrieval and Search](/rules/pref-check-subrc) — <code>#EC PREF_CHECK_SUBRC</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_NO_UNFILT_DML`
* **ABAP Implementation:** [/skyl/cl_no_unfilt_dml.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_no_unfilt_dml.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 3777)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L3777)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_NO_UNFILT_DML&title=%5BBug%5D%3A%20Issue%20in%20no-unfilt-dml)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20no-unfilt-dml)**
