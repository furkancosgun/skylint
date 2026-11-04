---
title: "Prefer Distinct UNION over UNION ALL in SQL Queries"
description: "Ensure distinct SQL query results and prevent duplicate data processing by using UNION instead of UNION ALL in SAP ABAP Cloud applications."
keywords: "pref-union, UNION ALL, ABAP SQL, Clean ABAP, database performance"
category: "performance"
ruleId: "pref-union"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L5081"
---

# Prefer Distinct UNION over UNION ALL in SQL Queries

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Performance & Database" />
  <Badge type="danger" text="#EC PREF_UNION" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L5081" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Prefer UNION over UNION ALL in SQL queries.

> **ATC Finding Message:** `Prefer UNION over UNION ALL in SQL queries`

## Rationale

Combining query result sets with `UNION ALL` retains duplicate records from all participating branches, which can lead to accidental double-counting in business reports, inaccurate metric aggregations, and excessive network transport from the database. In contrast, standard `UNION` performs set deduplication directly within the database engine before rows are sent to the application server. The check detects `UNION ALL` sequences in ABAP SQL and reports `PREF_UNION`. Unless duplicate records are explicitly expected and handled, use standard `UNION` to ensure deterministic, distinct dataset retrieval and lower application memory consumption.

### Non-Compliant

```abap
SELECT company_code, customer_number
  FROM zsales_order_hist
  UNION ALL
  SELECT company_code, customer_number
  FROM zsales_order_curr
  INTO TABLE @DATA(lt_active_customers).
```

### Compliant

```abap
SELECT company_code, customer_number
  FROM zsales_order_hist
  UNION
  SELECT company_code, customer_number
  FROM zsales_order_curr
  INTO TABLE @DATA(lt_active_customers).
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC PREF_UNION

" SAP CI_ prefix format:
... "#EC CI_PREF_UNION
```

## Detection and Intent

The check inspects `SELECT` statements for the token sequence `UNION ALL`. If duplicate records across queries are genuinely intended (e.g. for complete audit event logs or union of pre-partitioned disjoint datasets where duplicates are mathematically impossible), suppress the finding with the pseudo-comment.

| Aspect | Details |
|---|---|
| Finding Code | `PREF_UNION` |
| Default Severity | Warning |
| Pseudo Comment | `"#EC PREF_UNION` |
| Detected Pattern | Consecutive keywords `UNION ALL` within an ABAP SQL `SELECT` statement |


## Related Rules

* [Specify Explicit Join Types in ABAP SQL SELECT Statements](/rules/pref-join-type) — <code>#EC PREF_JOIN_TYPE</code>
* [Escape ABAP SQL Host Variables and Table Targets with @](/rules/pref-strict-sql) — <code>#EC PREF_STRICT_SQL</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_PREF_UNION`
* **ABAP Implementation:** [/skyl/cl_pref_union.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_pref_union.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 5081)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L5081)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_PREF_UNION&title=%5BBug%5D%3A%20Issue%20in%20pref-union)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20pref-union)**
