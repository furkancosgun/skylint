---
title: "Sort Internal Tables Before DELETE ADJACENT DUPLICATES"
description: "Ensure internal table deduplication integrity by requiring a SORT statement prior to DELETE ADJACENT DUPLICATES in ABAP."
keywords: "DELETE ADJACENT DUPLICATES, SORT internal table, ABAP Deduplication Bug, Clean ABAP"
category: "anti-patterns"
ruleId: "no-dedup-no-sort"
---

# Sort Internal Tables Before DELETE ADJACENT DUPLICATES

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Anti-Patterns & Bad Practices" />
  <Badge type="danger" text="#EC NO_DEDUP_NO_SORT" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Sort internal tables before DELETE ADJACENT DUPLICATES.

> **ATC Finding Message:** `Sort internal table before DELETE ADJACENT DUPLICATES to prevent unexpected results`

## Rationale

`DELETE ADJACENT DUPLICATES` only removes duplicate rows that are physically consecutive. If the table is not sorted beforehand, non-adjacent identical rows are retained, leading to subtle logic errors and incomplete deduplication.

**Standard:** Always issue an explicit `SORT <itab>` statement immediately before `DELETE ADJACENT DUPLICATES`.

### Non-Compliant

```abap
" Flawed deduplication: Unsorted adjacent check misses duplicates
DELETE ADJACENT DUPLICATES FROM lt_data.
```

### Compliant

```abap
" Correct: Explicit sort guarantees consecutive duplicates
SORT lt_data.
DELETE ADJACENT DUPLICATES FROM lt_data.
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC NO_DEDUP_NO_SORT

" SAP CI_ prefix format:
... "#EC CI_NO_DEDUP_NO_SORT
```


## Related Rules

* [Specify an Explicit SORT Key with BY](/rules/pref-sort-key) — <code>#EC PREF_SORT_KEY</code>
* [Explicitly Specify SORT Order](/rules/pref-sort-order) — <code>#EC PREF_SORT_ORDER</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_NO_DEDUP_NO_SORT`
* **Implementation File:** [#skyl#cl_no_dedup_no_sort.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_no_dedup_no_sort.clas.abap)
