---
title: "Specify an Explicit SORT Key with BY"
description: "Specify an explicit SORT key with BY in ABAP instead of relying on the implicit standard key. Deterministic internal table sorting, parallel sort safety, and automated ATC inspection for SAP S/4HANA and ABAP Cloud."
keywords: "SORT BY ABAP, Implicit Sort Key, Internal Table Sorting, Clean ABAPSORT, ATC Code Review"
category: "performance"
ruleId: "pref-sort-key"
---

# Specify an Explicit SORT Key with BY

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Performance & Database" />
  <Badge type="danger" text="#EC PREF_SORT_KEY" />
  <Badge type="info" text="Remote Enabled" />
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
* **Implementation File:** [#skyl#cl_pref_sort_key.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_pref_sort_key.clas.abap)
