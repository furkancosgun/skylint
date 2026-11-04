---
title: "Avoid UPDATE or DELETE Without a WHERE Condition (Catastrophic Data Wipe Prevention)"
description: "Prevent catastrophic full-table deletion and modification in SAP ABAP by requiring WHERE clauses on all OpenSQL UPDATE and DELETE statements."
keywords: "Unfiltered UPDATE ABAP, DELETE without WHERE SAP, Catastrophic Data Loss Prevention, OpenSQL Data Integrity"
category: "security"
ruleId: "no-unfilt-dml"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L3692"
---

# Avoid UPDATE or DELETE Without a WHERE Condition (Catastrophic Data Wipe Prevention)

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Security & Robustness" />
  <Badge type="danger" text="#EC NO_UNFILT_DML" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L3692" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Flag DML without WHERE on database tables.

> **ATC Finding Message:** `Filter database writes with a WHERE condition`

## Rationale

Executing an `UPDATE` or `DELETE` statement targeting a database table without an explicit `WHERE` clause modifies or truncates every single record in the entire table. In production environments, this causes catastrophic data loss, brings business operations to a halt, and requires emergency point-in-time database restoration.

**Safety Standard:** Always provide a restrictive `WHERE` condition on every database DML statement. If a full-table operation is genuinely required (e.g., in staging tables), enforce it through explicit administrative procedures.

### Non-Compliant

```abap
" Disaster: Wipes all customer purchase history in the entire system!
DELETE FROM zorder_items.
```

### Compliant

```abap
" Safe: Scoped deletion with mandatory WHERE condition
DELETE FROM zorder_items
  WHERE order_id = @iv_order_id.
IF sy-subrc <> 0.
  " Handle not found or log
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


## Related Rules

* [Avoid Database Access Inside Loops (N+1 Query Antipattern)](/rules/no-db-in-loop) — <code>#EC NO_DB_IN_LOOP</code>
* [Avoid SELECT * in OpenSQL Queries (Minimize Memory & Network Overhead)](/rules/no-select-star) — <code>#EC NO_SELECT_STAR</code>
* [Verify sy-subrc Promptly After Data Retrieval and Search](/rules/pref-check-subrc) — <code>#EC PREF_CHECK_SUBRC</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_NO_UNFILT_DML`
* **ABAP Implementation:** [/skyl/cl_no_unfilt_dml.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_no_unfilt_dml.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 3692)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L3692)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_NO_UNFILT_DML&title=%5BBug%5D%3A%20Issue%20in%20no-unfilt-dml)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20no-unfilt-dml)**
