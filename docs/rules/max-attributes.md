---
description: "Limit class member attributes to prevent God Classes"
---

# Limit Member Attributes per Class

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Metrics & Complexity Limits" />
  <Badge type="danger" text="#EC ATTRIBUTES" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Limit class member attributes to prevent God Classes.

> **ATC Finding Message:** `Class has too many member attributes; split into cohesive components`

## Rationale

A class with many member variables tends to own several unrelated responsibilities and becomes a God object. Its state is hard to initialize, test, and reason about, and changes ripple through many methods. Split cohesive fields into smaller domain objects or focused classes.

### Non-Compliant

```abap
CLASS cl_order DEFINITION PUBLIC CREATE PUBLIC.
  PRIVATE SECTION.
    DATA mv_id TYPE string.
    DATA mv_customer TYPE string.
    DATA mv_status TYPE string.
    DATA mv_total TYPE i.
    DATA mv_currency TYPE string.
    DATA mv_created_at TYPE timestamp.
ENDCLASS.
```

### Compliant

```abap
CLASS cl_order DEFINITION PUBLIC CREATE PUBLIC.
  PRIVATE SECTION.
    DATA ms_header TYPE ty_order_header.
    DATA mt_items TYPE ty_order_items.
ENDCLASS.
```

## Configuration & Thresholds

This check can be fine-tuned directly in the ATC Check Variant Editor (`CHKV`) in Eclipse ADT:

| Parameter Name | Data Type | Default Value |
|---|---|:---:|
| `MAX_ATTRIBUTES` | `Integer` | <code>5</code> |

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC ATTRIBUTES

" SAP CI_ prefix format:
... "#EC CI_ATTRIBUTES
```

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_MAX_ATTRIBUTES`
* **Implementation File:** [zcl_skylint_max_attributes.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_max_attributes.clas.abap)
