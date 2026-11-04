---
title: "Avoid Leading Wildcards in SQL LIKE Predicates"
description: "Prevent full table scans in ABAP Open SQL by avoiding leading wildcards in LIKE predicates and utilizing prefix index scans."
keywords: "no-lead-wildcard, LIKE wildcard, full table scan, ABAP SQL performance, database index"
category: "performance"
ruleId: "no-lead-wildcard"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L5786"
---

# Avoid Leading Wildcards in SQL LIKE Predicates

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Performance & Database" />
  <Badge type="danger" text="#EC NO_LEAD_WILDCARD" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L5786" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Avoid leading wildcard (% or +) in LIKE conditions.

> **ATC Finding Message:** `Avoid leading wildcard (% or +) in LIKE; prevents index usage causing full scan`

## Rationale

Using a leading wildcard (`%` or `_`) in an SQL `LIKE` condition (such as `LIKE '%text'` or `LIKE '_text'`) forces a full column or table scan because B-tree and database inverted indexes cannot be searched from the root without a fixed prefix. On high-volume database tables, unindexed substring searches cause severe CPU spikes and excessive disk I/O. Where prefix matching satisfies requirements, anchor searches with a leading character prefix (e.g. `LIKE 'prefix%'`), or leverage SAP HANA full-text search indexes with fuzzy matching for arbitrary substring queries. The check reports `NO_LD_WILD`.

### Non-Compliant

```abap
SELECT customer_id, customer_name, country_code
  FROM zcustomer
  WHERE customer_name LIKE '%CORP'
  INTO TABLE @DATA(lt_customers).
```

### Compliant

```abap
SELECT customer_id, customer_name, country_code
  FROM zcustomer
  WHERE customer_name LIKE 'CORP%'
  INTO TABLE @DATA(lt_customers).
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC NO_LEAD_WILDCARD

" SAP CI_ prefix format:
... "#EC CI_NO_LEAD_WILDCARD
```

## Index Utilization and Search Alternatives

| Search Pattern | Index Usage | Performance Characteristic |
|---|---|---|
| `LIKE 'prefix%'` | **Index Range Scan** | Fast; binary search locates the start position in the index tree. |
| `LIKE '%suffix'` | **Full Table / Index Scan** | Slow; every entry must be inspected to check the suffix. |
| `LIKE '%contains%'` | **Full Table / Index Scan** | Slow; cannot traverse index trees without prefix anchoring. |
| `LIKE '_single'` | **Full Table / Index Scan** | Slow; single-character wildcard at position 1 prevents index lookup. |

### Architectural Recommendations
- **Prefix Anchoring:** Whenever business requirements allow, anchor searches at the beginning of the field.
- **HANA Search:** For flexible substring searches on large master data tables, declare full-text indexes or use the SAP HANA fuzzy search operator `CONTAINS( ... FUZZY( ... ) )`.
- **Suppression:** Suppress unavoidable leading wildcard scans using `"#EC NO_LEAD_WILDCARD` or `##NO_LEAD_WILDCARD`.


## Related Rules

* [Avoid Unfiltered SELECT Statements on Database Tables](/rules/no-full-scan-sel) — <code>#EC NO_FULL_SCAN_SELECT</code>
* [Use BETWEEN for Inclusive Range Checks](/rules/pref-between) — <code>#EC PREF_BETWEEN</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_NO_LEAD_WILDCARD`
* **ABAP Implementation:** [/skyl/cl_no_lead_wildcard.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_no_lead_wildcard.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 5786)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L5786)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_NO_LEAD_WILDCARD&title=%5BBug%5D%3A%20Issue%20in%20no-lead-wildcard)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20no-lead-wildcard)**
