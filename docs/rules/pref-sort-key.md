---
title: "Specify an Explicit SORT Key with BY"
description: "Specify an explicit SORT key with BY in ABAP instead of relying on the implicit standard key. Deterministic internal table sorting, parallel sort safety, and automated ATC inspection for SAP S/4HANA and ABAP Cloud."
keywords: "SORT BY ABAP, Implicit Sort Key, Internal Table Sorting, Clean ABAPSORT, ATC Code Review"
category: "performance"
ruleId: "pref-sort-key"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L5150"
---

# Specify an Explicit SORT Key with BY

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Performance & Database" />
  <Badge type="danger" text="#EC PREF_SORT_KEY" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L5150" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Sort With an Explicit Sort Key.

> **ATC Finding Message:** `SORT statement has no explicit BY key - implicit standard key is used`

## Rationale

SORT without BY sorts an internal table using its implicit standard key, which depends on the table definition (character-type components for standard tables). This makes the sort result fragile: key changes ripple into sort behavior, character field shortening alters comparisons, and unsorted parallel sorts become unpredictable. Specify the sort key explicitly with SORT ... BY so the statement is robust and self-documenting.

### Non-Compliant

```abap
SORT lt_data.
```

### Compliant

```abap
SORT lt_data BY field1 field2.
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC PREF_SORT_KEY

" SAP CI_ prefix format:
... "#EC CI_PREF_SORT_KEY
```


## Related Rules

* [Explicitly Specify SORT Order](/rules/pref-sort-order) — <code>#EC PREF_SORT_ORDER</code>
* [Prefer TYPE STANDARD TABLE OF over TYPE TABLE OF](/rules/pref-std-table) — <code>#EC PREF_STD_TABLE</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_PREF_SORT_KEY`
* **ABAP Implementation:** [/skyl/cl_pref_sort_key.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_pref_sort_key.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 5150)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L5150)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_PREF_SORT_KEY&title=%5BBug%5D%3A%20Issue%20in%20pref-sort-key)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20pref-sort-key)**
