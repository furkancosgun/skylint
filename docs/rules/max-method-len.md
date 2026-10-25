---
description: "Method Length Limit (excessive statement count)"
---

# Limit Method Length (Statements)

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Metrics & Complexity Limits" />
  <Badge type="danger" text="#EC METHOD_LEN" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Method Length Limit (excessive statement count).

> **ATC Finding Message:** `Method length exceeds maximum allowed statement limit`

## Rationale

A method with many statements usually carries several responsibilities and accumulates local state that is hard to follow. Long methods are difficult to unit test, review, and reuse, and they tend to change for unrelated reasons. Extract cohesive steps into small named methods so each one has a single purpose.

### Non-Compliant

```abap
METHOD post_order.
  DATA lv_total TYPE i.
  lv_total = ls_order-quantity * ls_order-price.
  check_credit( ls_order-customer_id ).
  save_header( ls_order ).
  save_items( ls_order ).
  update_status( ls_order ).
  log_created( ls_order ).
ENDMETHOD.
```

### Compliant

```abap
METHOD post_order.
  prepare_order( ls_order ).
  save_order( ls_order ).
  log_created( ls_order ).
ENDMETHOD.
```

## Configuration & Thresholds

This check can be fine-tuned directly in the ATC Check Variant Editor (`CHKV`) in Eclipse ADT:

| Parameter Name | Data Type | Default Value |
|---|---|:---:|
| `MAX_STATEMENTS` | `Integer` | <code>5</code> |

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC METHOD_LEN

" SAP CI_ prefix format:
... "#EC CI_METHOD_LEN
```

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_MAX_METHOD_LEN`
* **Implementation File:** [zcl_skylint_max_method_len.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_max_method_len.clas.abap)
