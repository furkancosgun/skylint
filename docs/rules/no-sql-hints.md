---
title: "Avoid Database Hints (%_HINTS) in ABAP SQL Queries"
description: "Eliminate database hints (%_HINTS) in ABAP SQL to ensure database portability, ABAP Cloud compliance, and cost-based optimizer adaptability."
keywords: "no-sql-hints, %_HINTS, database hints, ABAP SQL performance, ABAP Cloud Contract C1"
category: "performance"
ruleId: "no-sql-hints"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L5759"
---

# Avoid Database Hints (%_HINTS) in ABAP SQL Queries

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Performance & Database" />
  <Badge type="danger" text="#EC NO_SQL_HINTS" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L5759" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Avoid database hints (%_HINTS) in ABAP SQL queries.

> **ATC Finding Message:** `Avoid %_HINTS; hints bypass query optimizer and break DB portability`

## Rationale

Hardcoding database hints via `%_HINTS` overrides the database cost-based optimizer and couples application code to specific database platforms (such as SAP HANA, Oracle, or IBM DB6). Proprietary hints break database portability, fail syntax validation in modern ABAP Cloud (Contract C1), and prevent the database engine from adapting query plans when data volume or distribution evolves. Query performance must instead be tuned through proper index design, index-aligned `WHERE` filtering, CDS view pushdown, and query restructuring. The check flags `%_HINTS` tokens with `NO_SQL_HNT`.

### Non-Compliant

```abap
SELECT sales_order, order_type, net_amount
  FROM zso_header
  INTO TABLE @DATA(lt_orders)
  %_HINTS HDB 'INDEX_SEARCH'.
```

### Compliant

```abap
SELECT sales_order, order_type, net_amount
  FROM zso_header
  WHERE customer_id = @lv_customer_id
  INTO TABLE @DATA(lt_orders).
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC NO_SQL_HINTS

" SAP CI_ prefix format:
... "#EC CI_NO_SQL_HINTS
```

## Portability and ABAP Cloud Contract C1

| Aspect | Detail |
|---|---|
| Finding Code | `NO_SQL_HNT` |
| Default Severity | Warning |
| Pseudo Comment | `"#EC NO_SQL_HINTS` |
| Cloud Readiness | `%_HINTS` is strictly prohibited in ABAP Cloud / Steampunk development contracts |

### Tuning Strategies without Hints
- **Secondary Indexes:** Ensure the database table has secondary indexes covering the leading fields of your `WHERE` condition.
- **Selective Projections:** Select only required columns rather than `*` to enable index-only or column-store scan optimizations.
- **CDS Data Modeling:** Push complex calculations, joins, and aggregations into CDS views where SAP HANA can leverage optimized calculation engines automatically.


## Related Rules

* [Avoid Unfiltered SELECT Statements on Database Tables](/rules/no-full-scan-sel) — <code>#EC NO_FULL_SCAN_SELECT</code>
* [Escape ABAP SQL Host Variables and Table Targets with @](/rules/pref-strict-sql) — <code>#EC PREF_STRICT_SQL</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_NO_SQL_HINTS`
* **ABAP Implementation:** [/skyl/cl_no_sql_hints.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_no_sql_hints.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 5759)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L5759)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_NO_SQL_HINTS&title=%5BBug%5D%3A%20Issue%20in%20no-sql-hints)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20no-sql-hints)**
