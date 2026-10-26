---
title: "Ensure Opened Datasets and Cursors are Closed"
description: "Prevent resource leaks in ABAP by ensuring all OPEN DATASET and OPEN CURSOR statements have guaranteed CLOSE counterparts."
keywords: "OPEN DATASET CLOSE DATASET ABAP, OPEN CURSOR CLOSE CURSOR ABAP, DBSQL_TOO_MANY_OPEN_CURSOR, ABAP resource leak ATC check, Clean ABAP resource management"
category: "security"
ruleId: "no-unclosed-res"
---

# Ensure Opened Datasets and Cursors are Closed

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Security & Robustness" />
  <Badge type="danger" text="#EC NO_UNCLOSED_RES" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Ensure opened datasets and cursors are closed.

> **ATC Finding Messages:**
> - `OPEN DATASET is not closed; resource leak risk`
> - `OPEN CURSOR is not closed; database cursor leak risk`

## Rationale

Resources opened on the application server (OPEN DATASET) or database (OPEN CURSOR) must always be explicitly closed (CLOSE DATASET, CLOSE CURSOR). Leaving resources open causes operating system file descriptor leaks, persistent file locks, and can trigger the fatal runtime error DBSQL_TOO_MANY_OPEN_CURSOR (maximum 17 open database cursors session limit).

### Non-Compliant

```abap
OPEN CURSOR @DATA(dbcur) FOR SELECT * FROM t100.
" Cursor remains open without CLOSE CURSOR!
```

### Compliant

```abap
OPEN CURSOR @DATA(dbcur) FOR SELECT * FROM t100.
FETCH NEXT CURSOR @dbcur INTO TABLE @DATA(lt_data).
CLOSE CURSOR @dbcur.
```

## Configuration & Thresholds

This check can be fine-tuned directly in the ATC Check Variant Editor (`CHKV`) in Eclipse ADT:

| Parameter Name | Data Type | Default Value | Description & Guidance |
|---|---|:---:|---|
| `CHECK_DATASET` | `Boolean` | <code>true</code> | Check unclosed OPEN DATASET statements |
| `CHECK_CURSOR` | `Boolean` | <code>true</code> | Check unclosed OPEN CURSOR statements |

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC NO_UNCLOSED_RES

" SAP CI_ prefix format:
... "#EC CI_NO_UNCLOSED_RES
```


## Related Rules

* [Avoid Database Access Inside Loops (N+1 Query Antipattern)](/rules/no-db-in-loop) — <code>#EC NO_DB_IN_LOOP</code>
* [Avoid Obsolete ABAP Memory and Context Statements](/rules/no-obs-memory) — <code>#EC NO_OBS_MEMORY</code>

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_NO_UNCLOSED_RES`
* **Implementation File:** [zcl_skylint_no_unclosed_res.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_no_unclosed_res.clas.abap)
