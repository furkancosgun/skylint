---
title: "Avoid Unconstrained CROSS JOIN in ABAP SQL Queries"
description: "Avoid Cartesian products in ABAP SQL by prohibiting unconstrained CROSS JOIN queries to protect SAP HANA memory and query runtimes."
keywords: "no-cross-join, CROSS JOIN, Cartesian product, ABAP SQL performance, SAP HANA"
category: "performance"
ruleId: "no-cross-join"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L5731"
---

# Avoid Unconstrained CROSS JOIN in ABAP SQL Queries

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Performance & Database" />
  <Badge type="danger" text="#EC NO_CROSS_JOIN" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L5731" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Avoid CROSS JOIN in ABAP SQL queries.

> **ATC Finding Message:** `Avoid CROSS JOIN; cartesian products cause heavy database and memory load`

## Rationale

A `CROSS JOIN` computes the full Cartesian product (M * N rows) between two database tables without an `ON` join condition. When executed on non-trivial business tables, Cartesian products produce exponential row proliferation, exhausting SAP HANA memory limits and triggering database out-of-memory (OOM) aborts or critical query timeouts. In modern Clean ABAP and relational modeling, table relationships must always be explicitly defined using `INNER JOIN` or `LEFT OUTER JOIN` with strict `ON` predicate conditions, or generated through structured domain views. The check reports `NO_CROSS_J`.

### Non-Compliant

```abap
SELECT FROM zplant CROSS JOIN zstorage_loc
  FIELDS zplant~plant_id, zstorage_loc~storage_loc_id
  INTO TABLE @DATA(lt_locations).
```

### Compliant

```abap
SELECT FROM zplant
  INNER JOIN zstorage_loc ON zplant~plant_id = zstorage_loc~plant_id
  FIELDS zplant~plant_id, zstorage_loc~storage_loc_id
  INTO TABLE @DATA(lt_locations).
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC NO_CROSS_JOIN

" SAP CI_ prefix format:
... "#EC CI_NO_CROSS_JOIN
```

## Cartesian Product Risks

| Join Type | Relationship | Complexity | HANA Memory Impact |
|---|---|---|---|
| `CROSS JOIN` | Unbounded Cartesian product | $O(M \times N)$ | Exponential row growth, risk of out-of-memory abort |
| `INNER JOIN ... ON` | Key-constrained intersection | $O(M)$ with index | Controlled, index-accelerated join |
| `LEFT OUTER JOIN ... ON` | Key-constrained outer join | $O(M)$ with index | Controlled, null-padded match |

### Mitigations
- Connect all joined sources with explicit `ON` conditions matching foreign key relationships.
- In rare scenarios where a Cartesian combination of small fixed lookup tables (e.g. matrix of calendar months and currencies) is mathematically required, suppress the finding with `"#EC NO_CROSS_JOIN` or `##NO_CROSS_JOIN`.


## Related Rules

* [Avoid Unfiltered SELECT Statements on Database Tables](/rules/no-full-scan-sel) — <code>#EC NO_FULL_SCAN_SELECT</code>
* [Specify Explicit Join Types in ABAP SQL SELECT Statements](/rules/pref-join-type) — <code>#EC PREF_JOIN_TYPE</code>
* [Escape ABAP SQL Host Variables and Table Targets with @](/rules/pref-strict-sql) — <code>#EC PREF_STRICT_SQL</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_NO_CROSS_JOIN`
* **ABAP Implementation:** [/skyl/cl_no_cross_join.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_no_cross_join.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 5731)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L5731)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_NO_CROSS_JOIN&title=%5BBug%5D%3A%20Issue%20in%20no-cross-join)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20no-cross-join)**
