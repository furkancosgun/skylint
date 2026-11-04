---
title: "Limit Database Table JOINs in ABAP SQL Queries"
description: "Limit the number of database table JOINs in ABAP SQL to prevent SAP HANA optimizer bottlenecks and encourage CDS view modeling."
keywords: "max-sql-joins, SQL JOIN, CDS view, SAP HANA, ABAP SQL performance"
category: "performance"
ruleId: "max-sql-joins"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L5266"
---

# Limit Database Table JOINs in ABAP SQL Queries

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Performance & Database" />
  <Badge type="danger" text="#EC MAX_SQL_JOINS" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L5266" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Limit number of JOINs in OpenSQL queries.

> **ATC Finding Message:** `Too many table JOINs in SQL query; consider CDS View or query decomposition`

## Rationale

Executing ABAP SQL queries with excessive table JOINs (more than 4 by default) complicates query execution plans, creates expensive intermediate spool results, and saturates SAP HANA memory buffers. Large join graphs make statements brittle to schema evolutions and significantly hinder maintainability. Under the ABAP RESTful Application Programming Model (RAP) and Clean ABAP principles, complex data models should be modeled as reusable Core Data Services (CDS) analytical or transactional views with associations, or broken down into focused, staged queries. The check inspects `SELECT` statements and reports `MAX_SQLJN` whenever the join count exceeds the configured `MAX_JOINS` threshold.

### Non-Compliant

```abap
SELECT header~sales_order,
       item~order_item,
       customer~customer_name,
       material~material_desc,
       status~status_text,
       currency~currency_code
  FROM zso_header AS header
  INNER JOIN zso_item AS item ON header~sales_order = item~sales_order
  LEFT OUTER JOIN zcustomer AS customer ON header~customer_id = customer~customer_id
  LEFT OUTER JOIN zmaterial AS material ON item~material_id = material~material_id
  LEFT OUTER JOIN zso_status AS status ON header~status_code = status~status_code
  LEFT OUTER JOIN zcurrency AS currency ON header~currency_code = currency~currency_code
  INTO TABLE @DATA(lt_order_details).
```

### Compliant

```abap
SELECT sales_order,
       order_item,
       customer_name,
       material_desc,
       status_text,
       currency_code
  FROM zi_sales_order_analytics
  INTO TABLE @DATA(lt_order_details).
```

## Configuration & Thresholds

This check can be fine-tuned directly in the ATC Check Variant Editor (`CHKV`) in Eclipse ADT:

| Parameter Name | Data Type | Default Value | Description & Guidance |
|---|---|:---:|---|
| `MAX_JOINS` | `Integer` | <code>4</code> | Maximum number of table JOIN occurrences allowed in a single ABAP SQL statement before reporting a finding (default: 4). |

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC MAX_SQL_JOINS

" SAP CI_ prefix format:
... "#EC CI_MAX_SQL_JOINS
```

## Configuration and Best Practices

| Setting | Default | Description |
|---|---|---|
| `MAX_JOINS` | `4` | Maximum permissible `JOIN` keywords per `SELECT` statement |

### Architectural Recommendations
- **Encapsulate in CDS Views:** Model complex multi-table graphs in Core Data Services (CDS) entity views with lazy associations (`_Association`) instead of writing long Open SQL JOIN chains in procedural code.
- **Query Decomposition:** If data comes from disparate business domains, split queries into targeted fetches using `FOR ALL ENTRIES` or separate service calls.
- **Suppression:** Suppress false positives on necessary reporting queries using `"#EC MAX_SQL_JOINS` or `##MAX_SQL_JOINS`.


## Related Rules

* [Specify Explicit Join Types in ABAP SQL SELECT Statements](/rules/pref-join-type) — <code>#EC PREF_JOIN_TYPE</code>
* [Avoid SELECT * and Project Columns Explicitly](/rules/no-select-star) — <code>#EC NO_SELECT_STAR</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_MAX_SQL_JOINS`
* **ABAP Implementation:** [/skyl/cl_max_sql_joins.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_max_sql_joins.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 5266)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L5266)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_MAX_SQL_JOINS&title=%5BBug%5D%3A%20Issue%20in%20max-sql-joins)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20max-sql-joins)**
