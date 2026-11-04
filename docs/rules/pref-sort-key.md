---
title: "Specify Explicit Sort Fields with SORT BY"
description: "Enforce explicit sort keys using SORT BY on ABAP internal tables to guarantee deterministic order and prevent implicit standard key defects."
keywords: "pref-sort-key, SORT BY, internal table, Clean ABAP, deterministic sorting"
category: "performance"
ruleId: "pref-sort-key"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L5324"
---

# Specify Explicit Sort Fields with SORT BY

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Performance & Database" />
  <Badge type="danger" text="#EC PREF_SORT_KEY" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L5324" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Sort With an Explicit Sort Key.

> **ATC Finding Message:** `SORT statement has no explicit BY key - implicit standard key is used`

## Rationale

Using `SORT itab` without an explicit `BY` clause sorts an internal table using its implicit standard key. In ABAP, the standard key of standard tables consists of all non-numeric and character-like fields, which can change silently whenever table components are added, reordered, or modified. Furthermore, tables declared with `WITH EMPTY KEY` cannot be safely sorted without an explicit key. Specifying explicit sort criteria via `SORT itab BY field1 ASCENDING field2 DESCENDING` makes sorting deterministic, prevents subtle ordering bugs, and documents developer intent clearly. The check reports `PREF_SORTK` when a `SORT` statement omits the `BY` keyword.

### Non-Compliant

```abap
SORT lt_sales_orders.
```

### Compliant

```abap
SORT lt_sales_orders BY creation_date DESCENDING sales_order ASCENDING.
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC PREF_SORT_KEY

" SAP CI_ prefix format:
... "#EC CI_PREF_SORT_KEY
```

## Why Implicit Standard Key Sorting Is Fragile

| Declaration Type | Behavior with `SORT itab.` |
|---|---|
| `STANDARD TABLE WITH DEFAULT KEY` | Sorts by all character-like and byte-like components, ignoring integers, packed decimals, and timestamps. Changing structure layout alters sort behavior. |
| `STANDARD TABLE WITH EMPTY KEY` | Runtime behavior is non-deterministic or sorts across all components depending on kernel version. |
| `SORT itab BY comp1 comp2` | Explicit, robust, and independent of dictionary type alterations. |

Suppress single occurrences where table definition keys are strictly intended using `"#EC PREF_SORT_KEY` or `##PREF_SORT_KEY`.


## Related Rules

* [Specify ASCENDING or DESCENDING on Every Sort Key](/rules/pref-sort-order) — <code>#EC PREF_SORT_ORDER</code>
* [Declare Standard Internal Tables Explicitly with TYPE STANDARD TABLE OF](/rules/pref-std-table) — <code>#EC PREF_STD_TABLE</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_PREF_SORT_KEY`
* **ABAP Implementation:** [/skyl/cl_pref_sort_key.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_pref_sort_key.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 5324)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L5324)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_PREF_SORT_KEY&title=%5BBug%5D%3A%20Issue%20in%20pref-sort-key)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20pref-sort-key)**
