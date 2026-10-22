---
description: "Method signature cleanliness (excessive parameter count)"
---

# Limit Method Parameter Count

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Metrics & Complexity Limits" />
  <Badge type="danger" text="#EC MAX_PARAMS" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Method signature cleanliness (excessive parameter count).

> **ATC Finding Message:** `Method signature has too many parameters; consider grouping into structures`

## Rationale

A long parameter list is hard to call correctly because positional order and optional parameters are easy to mix up. It usually means the method has too many responsibilities and must change whenever a new input is needed. Group related inputs into a structure or parameter object so the signature stays small and self-documenting.

### Non-Compliant

```abap
METHODS create_order
  IMPORTING
    iv_customer_id TYPE string
    iv_material    TYPE string
    iv_quantity    TYPE i
    iv_unit        TYPE meins
    iv_plant       TYPE werks_d
    iv_delivery    TYPE datum
    iv_price       TYPE netpr
    iv_currency    TYPE waers
    iv_note        TYPE string.
```

### Compliant

```abap
METHODS create_order
  IMPORTING
    is_order TYPE ty_order_input.
```

## Configuration & Thresholds

This check can be fine-tuned directly in the ATC Check Variant Editor (`CHKV`) in Eclipse ADT:

| Parameter Name | Data Type | Default Value |
|---|---|:---:|
| `MAX_PARAMETERS` | `Integer` | <code>8</code> |

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC MAX_PARAMS

" SAP CI_ prefix format:
... "#EC CI_MAX_PARAMS
```

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_MAX_PARAMS`
* **Implementation File:** [zcl_skylint_max_params.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_max_params.clas.abap)
