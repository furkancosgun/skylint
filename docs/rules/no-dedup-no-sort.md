---
title: "Sort Internal Tables Before DELETE ADJACENT DUPLICATES"
description: "Require explicit SORT before DELETE ADJACENT DUPLICATES on ABAP internal tables to prevent incomplete deduplication bugs."
keywords: "DELETE ADJACENT DUPLICATES, SORT internal table, ABAP deduplication, Clean ABAP, SAP ATC check, no-dedup-no-sort"
category: "anti-patterns"
ruleId: "no-dedup-no-sort"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L5813"
---

# Sort Internal Tables Before DELETE ADJACENT DUPLICATES

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Anti-Patterns & Bad Practices" />
  <Badge type="danger" text="#EC NO_DEDUP_NO_SORT" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L5813" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Sort internal tables before DELETE ADJACENT DUPLICATES.

> **ATC Finding Message:** `Sort internal table before DELETE ADJACENT DUPLICATES to prevent unexpected results`

## Rationale

In ABAP, DELETE ADJACENT DUPLICATES only checks immediately adjacent rows in internal table sequence. If the table is not sorted beforehand, identical entries separated by other rows are retained, leading to incomplete deduplication and corrupt business data. Unless the table is defined as SORTED TABLE, always precede DELETE ADJACENT DUPLICATES with a SORT statement referencing matching sort keys.

### Non-Compliant

```abap
DELETE ADJACENT DUPLICATES FROM lt_business_partners COMPARING partner_id.
```

### Compliant

```abap
SORT lt_business_partners BY partner_id ASCENDING.
DELETE ADJACENT DUPLICATES FROM lt_business_partners COMPARING partner_id.
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC NO_DEDUP_NO_SORT

" SAP CI_ prefix format:
... "#EC CI_NO_DEDUP_NO_SORT
```

### Verification mechanism

The rule verifies that every `DELETE ADJACENT DUPLICATES FROM <itab>` statement is preceded by an explicit `SORT <itab>` statement in the same procedure, matching the target internal table symbol.

| Statement Sequence | Finding Raised |
| --- | --- |
| `DELETE ADJACENT DUPLICATES FROM lt_data.` | yes (`NO_DEDUP_S`) |
| `SORT lt_other. DELETE ADJACENT DUPLICATES FROM lt_data.` | yes (`NO_DEDUP_S`, sorted wrong table) |
| `SORT lt_data. DELETE ADJACENT DUPLICATES FROM lt_data.` | no |

### Key Consistency

Ensure that the fields specified in `SORT itab BY ...` match the fields in `COMPARING ...`. If `COMPARING` is omitted, the default table key is used for both operations.

### Suppression

For tables inherently sorted by construction or database query order, suppress with `"#EC NO_DEDUP_NO_SORT`.


## Related Rules

* [Specify Explicit Sort Fields with SORT BY](/rules/pref-sort-key) — <code>#EC PREF_SORT_KEY</code>
* [Specify ASCENDING or DESCENDING on Every Sort Key](/rules/pref-sort-order) — <code>#EC PREF_SORT_ORDER</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_NO_DEDUP_NO_SORT`
* **ABAP Implementation:** [/skyl/cl_no_dedup_no_sort.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_no_dedup_no_sort.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 5813)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L5813)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_NO_DEDUP_NO_SORT&title=%5BBug%5D%3A%20Issue%20in%20no-dedup-no-sort)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20no-dedup-no-sort)**
