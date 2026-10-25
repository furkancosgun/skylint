---
description: "Prefer FILTER for simple LOOP/IF/APPEND"
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

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_PREF_FILTER`
* **Implementation File:** [zcl_skylint_pref_filter.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_pref_filter.clas.abap)
