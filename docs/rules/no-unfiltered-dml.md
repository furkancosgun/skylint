---
description: "Flag DML without WHERE on database tables"
---

# Avoid UPDATE or DELETE Without a WHERE Condition

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Performance & Database" />
  <Badge type="danger" text="#EC NO_UNFILT_DML" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Flag DML without WHERE on database tables.

> **ATC Finding Message:** `Filter database writes with a WHERE condition`

## Rationale

An UPDATE or DELETE that targets a database table without a top-level WHERE condition affects every row in the table. Such statements are dangerous in production and often indicate a missing restriction. Add a WHERE condition, or use the matching internal-table statement when no database table is intended.

### Non-Compliant

```abap
DELETE FROM zorders.
UPDATE zorders SET status = 'X'.
```

### Compliant

```abap
DELETE FROM zorders WHERE status = 'C'.
UPDATE zorders SET status = 'X' WHERE order_id = lv_id.
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC NO_UNFILT_DML

" SAP CI_ prefix format:
... "#EC CI_NO_UNFILT_DML
```

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_NO_UNFILT_DML`
* **Implementation File:** [zcl_skylint_no_unfilt_dml.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_no_unfilt_dml.clas.abap)
