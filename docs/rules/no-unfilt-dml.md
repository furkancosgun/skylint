---
title: "Avoid UPDATE or DELETE Without a WHERE Condition (Catastrophic Data Wipe Prevention)"
description: "Prevent catastrophic full-table deletion and modification in SAP ABAP by requiring WHERE clauses on all OpenSQL UPDATE and DELETE statements."
keywords: "Unfiltered UPDATE ABAP, DELETE without WHERE SAP, Catastrophic Data Loss Prevention, OpenSQL Data Integrity"
---

# Avoid UPDATE or DELETE Without a WHERE Condition (Catastrophic Data Wipe Prevention)

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Security & Robustness" />
  <Badge type="danger" text="#EC NO_UNFILT_DML" />
  <Badge type="info" text="Remote Enabled" />
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

## References & Standards

* [Clean ABAP: Safe DML Operations](https://github.com/SAP/styleguides/blob/main/clean-abap/CleanABAP.md)

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_NO_UNFILT_DML`
* **Implementation File:** [zcl_skylint_no_unfilt_dml.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_no_unfilt_dml.clas.abap)
