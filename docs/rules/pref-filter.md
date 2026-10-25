---
title: "Prefer FILTER for a Simple LOOP with IF and APPEND"
description: "Prefer FILTER for a Simple LOOP with IF and APPEND - Clean ABAP guidelines, modern SAP syntax rules, and automated ATC code inspection for SAP S/4HANA and ABAP Cloud."
keywords: "Clean ABAP, SAP ATC Check, ABAP Cloud, S/4HANA Readiness, pref-filter, clean-abap"
category: "clean-abap"
ruleId: "pref-filter"
---

# Prefer FILTER for a Simple LOOP with IF and APPEND

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="danger" text="#EC PREF_FILTER" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Prefer FILTER for simple LOOP/IF/APPEND.

> **ATC Finding Message:** `Replace the simple filter loop with FILTER`

## Rationale

A LOOP that only copies rows matching one condition into another table is a filter expressed as imperative control flow. FILTER builds the result directly and states the intent without a work area. This rule only targets the simple LOOP AT, IF, APPEND pattern; keep loops that contain extra logic, indexes, or multiple statements.

### Non-Compliant

```abap
LOOP AT lt_orders INTO ls_order.
  IF ls_order-status = 'O'.
    APPEND ls_order TO lt_open.
  ENDIF.
ENDLOOP.
```

### Compliant

```abap
lt_open = FILTER #( lt_orders USING KEY primary_key WHERE status = 'O' ).
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC PREF_FILTER

" SAP CI_ prefix format:
... "#EC CI_PREF_FILTER
```


## Related Rules

* [Prefer REDUCE #( ) Expression over Simple Aggregation LOOP](/rules/pref-reduce) — <code>#EC PREF_REDUCE</code>
* [Prefer INSERT ... INTO TABLE over APPEND](/rules/pref-insert) — <code>#EC PREF_INSERT</code>
* [Specify TRANSPORTING in Internal Table MODIFY and READ Operations](/rules/pref-transport) — <code>#EC PREF_TRANSPORT</code>

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_PREF_FILTER`
* **Implementation File:** [zcl_skylint_pref_filter.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_pref_filter.clas.abap)
