---
title: "Explicitly Specify SORT Order"
description: "Explicitly specify ASCENDING or DESCENDING sort order in ABAP SORT statements to avoid implicit default sorting behavior."
keywords: "ABAP SORT order, ABAP SORT ASCENDING DESCENDING, Clean ABAP SORT BY, SAP ATC check sort order, pref-sort-order"
category: "clean-abap"
ruleId: "pref-sort-order"
---

# Explicitly Specify SORT Order

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="danger" text="#EC PREF_SORT_ORDER" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Explicitly specify ASCENDING or DESCENDING sort order.

> **ATC Finding Message:** `Specify ASCENDING or DESCENDING sort order explicitly`

## Rationale

When sorting internal tables by components using the BY addition, no implicit sorting order should be assumed. Developers should explicitly specify ASCENDING or DESCENDING for each field, or specify the default order before BY, making the intended order clear and resilient to future modifications.

### Non-Compliant

```abap
SORT lt_table BY field1 field2.
```

### Compliant

```abap
SORT lt_table BY field1 ASCENDING field2 DESCENDING.
SORT lt_table ASCENDING BY field1 field2.
```

## Configuration & Thresholds

This check can be fine-tuned directly in the ATC Check Variant Editor (`CHKV`) in Eclipse ADT:

| Parameter Name | Data Type | Default Value | Description & Guidance |
|---|---|:---:|---|
| `CHECK_BY_ONLY` | `Boolean` | <code>true</code> | Only enforce explicit order when the BY addition is used (defaults to true) |

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC PREF_SORT_ORDER

" SAP CI_ prefix format:
... "#EC CI_PREF_SORT_ORDER
```


## Related Rules

* [Do Not Mutate the Internal Table Currently Being Looped (Iterator Invalidation)](/rules/no-mod-loop-tab) — <code>#EC NO_MOD_LOOP_TAB</code>
* [Avoid Obsolete Control Flow and Procedural Forms](/rules/no-obs-control) — <code>#EC NO_OBS_CONTROL</code>

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_PREF_SORT_ORDER`
* **Implementation File:** [zcl_skylint_pref_sort_order.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_pref_sort_order.clas.abap)
