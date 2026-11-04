---
title: "Avoid SELECT * and Project Columns Explicitly"
description: "Enforce explicit column projection in ABAP Open SQL to optimize SAP HANA column store performance and reduce memory consumption."
keywords: "no-select-star, SELECT star, HANA column store, Clean ABAP SQL, SAP ATC"
category: "performance"
ruleId: "no-select-star"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L1497"
---

# Avoid SELECT * and Project Columns Explicitly

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Performance & Database" />
  <Badge type="danger" text="#EC NO_SELECT_STAR" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L1497" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Avoid SELECT * (specify columns explicitly).

> **ATC Finding Message:** `Avoid SELECT *; specify required columns explicitly`

## Rationale

Using SELECT * or table~* instructs the database interface to retrieve and transmit every column defined on a table or view, including long character strings, BLOBs, and unused administrative timestamps. On modern columnar databases such as SAP HANA, performance is driven by column-store compression and vectorized memory scans; selecting unneeded columns breaks column pruning, inflates network payload between the database and application server, and wastes heap memory in internal table buffers. Clean ABAP requires explicit column projection to fetch only the exact fields required by business logic.

### Non-Compliant

```abap
SELECT *
  FROM zmaterials
  WHERE material_type = 'FERT'
  INTO TABLE @DATA(lt_materials).
```

### Compliant

```abap
SELECT material_number, material_type, base_unit_of_measure, net_weight
  FROM zmaterials
  WHERE material_type = 'FERT'
  INTO TABLE @DATA(lt_materials).
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC NO_SELECT_STAR

" SAP CI_ prefix format:
... "#EC CI_NO_SELECT_STAR
```

### Detection Details

The check scans the field list between `SELECT` (or `FIELDS`) and the subsequent query clauses (`FROM`, `WHERE`, `INTO`). Finding code `NO_SEL_STR` is reported when an unadorned `*` or a qualified `table~*` pattern is detected.

### Architectural Benefits

- **HANA Column Store Optimization:** Vector engines only load columns referenced in the query.
- **Network Reduction:** Dramatically decreases packet payload across the network layer.
- **Resilience to Table Extensions:** Prevents unexpected structure growth or typing conflicts when new append structures are added to database tables.

Suppress specialized full-row retrievals with the pseudo comment `"#EC NO_SELECT_STAR`.


## Related Rules

* [Avoid Database Queries Inside Loops (N+1 Query Antipattern)](/rules/no-db-in-loop) — <code>#EC NO_DB_IN_LOOP</code>
* [Avoid SELECT ... ENDSELECT Row-by-Row Cursor Loops](/rules/no-endselect) — <code>#EC NO_ENDSELECT</code>
* [Require Explicit ORDER BY with UP TO N ROWS Clauses](/rules/pref-order-by) — <code>#EC PREF_ORDER_BY</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_NO_SELECT_STAR`
* **ABAP Implementation:** [/skyl/cl_no_select_star.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_no_select_star.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 1497)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L1497)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_NO_SELECT_STAR&title=%5BBug%5D%3A%20Issue%20in%20no-select-star)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20no-select-star)**
