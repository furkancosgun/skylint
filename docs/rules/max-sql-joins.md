---
title: "Limit Number of Table JOINs in OpenSQL Queries"
description: "Limit table JOINs in ABAP OpenSQL queries to prevent SAP HANA optimizer bottlenecks and memory saturation. Encourage CDS View data modeling."
keywords: "Max SQL JOINs ABAP, OpenSQL Performance HANA, CDS View Data Modeling, Database Optimizer Bottleneck"
category: "performance"
ruleId: "max-sql-joins"
---

# Limit Number of Table JOINs in OpenSQL Queries

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Performance & Database" />
  <Badge type="danger" text="#EC MAX_SQL_JOINS" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Limit number of JOINs in OpenSQL queries.

> **ATC Finding Message:** `Too many table JOINs in SQL query; consider CDS View or query decomposition`

## Rationale

Queries joining more than 4 database tables degrade database optimizer join-graph planning, create expensive intermediate temporary tables, and saturate memory on SAP HANA and relational databases. Complex multi-table entity graphs should be encapsulated in Core Data Services (CDS) Views or decomposed into targeted queries.

**Best Practice:** Model multi-table join hierarchies as reusable CDS Analytical or Transactional Views.

### Non-Compliant

```abap
" Anti-pattern: Excessive table joins in single OpenSQL query (5 joins)
SELECT a~id, b~val, c~text, d~status, e~curr, f~amt
  FROM ztab_a AS a
  INNER JOIN ztab_b AS b ON a~id = b~id
  LEFT JOIN ztab_c AS c ON b~id = c~id
  INNER JOIN ztab_d AS d ON c~id = d~id
  INNER JOIN ztab_e AS e ON d~id = e~id
  INNER JOIN ztab_f AS f ON e~id = f~id
  INTO TABLE @DATA(lt_data).
```

### Compliant

```abap
" Clean ABAP: Encapsulate join graph in reusable CDS view or decompose
SELECT id, val, text, status, curr, amt
  FROM zc_order_analytics
  INTO TABLE @DATA(lt_data).
```

## Configuration & Thresholds

This check can be fine-tuned directly in the ATC Check Variant Editor (`CHKV`) in Eclipse ADT:

| Parameter Name | Data Type | Default Value | Description & Guidance |
|---|---|:---:|---|
| `MAX_JOINS` | `Integer` | <code>4</code> | Maximum number of table JOINs allowed per query (default: 4) |

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC MAX_SQL_JOINS

" SAP CI_ prefix format:
... "#EC CI_MAX_SQL_JOINS
```


## Related Rules

* [Prefer an Explicit JOIN Type](/rules/pref-join-type) — <code>#EC PREF_JOIN_TYPE</code>
* [Avoid SELECT * in OpenSQL Queries (Minimize Memory & Network Overhead)](/rules/no-select-star) — <code>#EC NO_SELECT_STAR</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_MAX_SQL_JOINS`
* **Implementation File:** [#skyl#cl_max_sql_joins.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_max_sql_joins.clas.abap)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_MAX_SQL_JOINS&title=%5BBug%5D%3A%20Issue%20in%20max-sql-joins)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20max-sql-joins)**
