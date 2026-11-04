---
title: "Avoid SELECT ... ENDSELECT Row-by-Row Cursor Loops"
description: "Eliminate SELECT ... ENDSELECT database cursor loops in ABAP. Replace row-by-row fetching with high-performance array operations and PACKAGE SIZE batches."
keywords: "no-endselect, SELECT ENDSELECT, database cursor, array fetch, Clean ABAP"
category: "performance"
ruleId: "no-endselect"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L1525"
---

# Avoid SELECT ... ENDSELECT Row-by-Row Cursor Loops

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Performance & Database" />
  <Badge type="danger" text="#EC NO_ENDSELECT" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L1525" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Avoid SELECT ... ENDSELECT Loops.

> **ATC Finding Message:** `Avoid SELECT ... ENDSELECT loop; use array fetch INTO TABLE`

## Rationale

The SELECT ... ENDSELECT construct opens an active server-side database cursor and streams rows individually across the network on every iteration. This pattern causes continuous network round trips, holds transactional database locks open, and blocks database connection pool resources. If an unhandled exception or early exit occurs within the loop body, the database cursor can leak or delay parallel application tasks. Clean ABAP mandates bulk array fetches (SELECT ... INTO TABLE) to transfer records in high-speed blocks, or using PACKAGE SIZE when processing massive data sets that cannot fit in memory.

### Non-Compliant

```abap
SELECT customer_id, company_name, city
  FROM zcustomers
  WHERE country = 'DE'
  INTO @DATA(ls_customer).
  process_customer_record( ls_customer ).
ENDSELECT.
```

### Compliant

```abap
SELECT customer_id, company_name, city
  FROM zcustomers
  WHERE country = 'DE'
  INTO TABLE @DATA(lt_customers).

LOOP AT lt_customers ASSIGNING FIELD-SYMBOL(<ls_customer>).
  process_customer_record( <ls_customer> ).
ENDLOOP.
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC NO_ENDSELECT

" SAP CI_ prefix format:
... "#EC CI_NO_ENDSELECT
```

### Detection Details

The check evaluates `ENDSELECT` statements. When a `SELECT` loop executes without a `PACKAGE SIZE` clause, finding code `NO_ENDSEL` is reported on the `ENDSELECT` boundary.

### Batch Processing with PACKAGE SIZE

Using `PACKAGE SIZE` within `SELECT ... ENDSELECT` is explicitly permitted by the check. When processing millions of records in batch workloads, streaming package-by-package into an internal table prevents out-of-memory errors while keeping network round trips minimal.

Suppress single-row cursor loops with the pseudo comment `"#EC NO_ENDSELECT`.


## Related Rules

* [Avoid Database Queries Inside Loops (N+1 Query Antipattern)](/rules/no-db-in-loop) — <code>#EC NO_DB_IN_LOOP</code>
* [Avoid SELECT * and Project Columns Explicitly](/rules/no-select-star) — <code>#EC NO_SELECT_STAR</code>
* [Require Explicit ORDER BY with UP TO N ROWS Clauses](/rules/pref-order-by) — <code>#EC PREF_ORDER_BY</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_NO_ENDSELECT`
* **ABAP Implementation:** [/skyl/cl_no_endselect.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_no_endselect.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 1525)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L1525)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_NO_ENDSELECT&title=%5BBug%5D%3A%20Issue%20in%20no-endselect)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20no-endselect)**
