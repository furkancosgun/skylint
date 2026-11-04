---
title: "Require Explicit ORDER BY with UP TO N ROWS Clauses"
description: "Enforce deterministic Open SQL queries in SAP ABAP by requiring an explicit ORDER BY clause whenever UP TO N ROWS is used."
keywords: "pref-order-by, ORDER BY, UP TO 1 ROWS, deterministic SQL, Clean ABAP"
category: "performance"
ruleId: "pref-order-by"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L2009"
---

# Require Explicit ORDER BY with UP TO N ROWS Clauses

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Performance & Database" />
  <Badge type="danger" text="#EC PREF_ORDER_BY" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L2009" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

SELECT UP TO 1 ROWS requires ORDER BY.

> **ATC Finding Message:** `SELECT UP TO 1 ROWS requires an explicit ORDER BY clause for determinism`

## Rationale

Relational database engines, especially distributed column stores like SAP HANA, do not guarantee physical row ordering without an explicit ORDER BY clause. Executing a query with UP TO n ROWS without sorting produces non-deterministic results: identical queries with identical inputs can return completely different records across executions depending on parallel execution threads, memory cache states, or index selection. In financial calculations, status lookups, and audit trails, this causes subtle, non-reproducible defects. Clean ABAP requires an explicit ORDER BY clause whenever restricting query result sets with UP TO.

### Non-Compliant

```abap
SELECT price, currency_code, valid_from
  FROM zprice_conditions
  WHERE product_id = @lv_product_id
  INTO TABLE @DATA(lt_latest_prices)
  UP TO 1 ROWS.
```

### Compliant

```abap
SELECT price, currency_code, valid_from
  FROM zprice_conditions
  WHERE product_id = @lv_product_id
  ORDER BY valid_from DESCENDING
  INTO TABLE @DATA(lt_latest_prices)
  UP TO 1 ROWS.
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC PREF_ORDER_BY

" SAP CI_ prefix format:
... "#EC CI_PREF_ORDER_BY
```

### Detection Details

The check inspects `SELECT` statements that contain the token sequence `UP TO` and verifies whether an `ORDER BY` clause is present. If `ORDER BY` is missing, finding code `PREF_ORDBY` is reported.

### SAP HANA Determinism

Unlike traditional disk-based row engines, SAP HANA distributes queries across multiple CPU cores and memory partitions. Results are assembled dynamically in parallel, meaning row order is never guaranteed unless explicitly requested via `ORDER BY PRIMARY KEY` or specific sort attributes.

Suppress queries where arbitrary record selection is truly acceptable with the pseudo comment `"#EC PREF_ORDER_BY`.


## Related Rules

* [Avoid SELECT * and Project Columns Explicitly](/rules/no-select-star) — <code>#EC NO_SELECT_STAR</code>
* [Guard FOR ALL ENTRIES Against Empty Driving Tables](/rules/no-empty-fae) — <code>#EC NO_EMPTY_FAE</code>
* [Avoid SELECT ... ENDSELECT Row-by-Row Cursor Loops](/rules/no-endselect) — <code>#EC NO_ENDSELECT</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_PREF_ORDER_BY`
* **ABAP Implementation:** [/skyl/cl_pref_order_by.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_pref_order_by.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 2009)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L2009)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_PREF_ORDER_BY&title=%5BBug%5D%3A%20Issue%20in%20pref-order-by)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20pref-order-by)**
