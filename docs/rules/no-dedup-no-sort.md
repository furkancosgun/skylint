---
title: "Sort Internal Tables Before DELETE ADJACENT DUPLICATES"
description: "Ensure internal table deduplication integrity by requiring a SORT statement prior to DELETE ADJACENT DUPLICATES in ABAP."
keywords: "DELETE ADJACENT DUPLICATES, SORT internal table, ABAP Deduplication Bug, Clean ABAP"
category: "anti-patterns"
ruleId: "no-dedup-no-sort"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L5612"
---

# Sort Internal Tables Before DELETE ADJACENT DUPLICATES

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Anti-Patterns & Bad Practices" />
  <Badge type="danger" text="#EC NO_DEDUP_NO_SORT" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L5612" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
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
* **ABAP Implementation:** [/skyl/cl_no_dedup_no_sort.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_no_dedup_no_sort.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 5612)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L5612)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_NO_DEDUP_NO_SORT&title=%5BBug%5D%3A%20Issue%20in%20no-dedup-no-sort)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20no-dedup-no-sort)**
