---
description: "Maximum Line Length"
---

# Limit Line Length

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Metrics & Complexity Limits" />
  <Badge type="danger" text="#EC LINE_LEN" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Maximum Line Length.

> **ATC Finding Message:** `Line length exceeds configured maximum limit`

## Rationale

Lines longer than the configured limit force horizontal scrolling and hide parts of a statement in review tools. They also encourage dense expressions that are hard to debug. Break statements at logical operators and use short, meaningful names.

### Non-Compliant

```abap
lv_result = lo_service->calculate_total_with_discount_and_tax_for_customer( iv_customer_id = lv_customer_id iv_currency = lv_currency ).
```

### Compliant

```abap
lv_result = lo_service->calculate_total_with_discount_and_tax_for_customer(
  iv_customer_id = lv_customer_id
  iv_currency    = lv_currency ).
```

## Configuration & Thresholds

This check can be fine-tuned directly in the ATC Check Variant Editor (`CHKV`) in Eclipse ADT:

| Parameter Name | Data Type | Default Value |
|---|---|:---:|
| `MAX_LENGTH` | `Integer` | <code>120</code> |

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC LINE_LEN

" SAP CI_ prefix format:
... "#EC CI_LINE_LEN
```

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_MAX_LINE_LEN`
* **Implementation File:** [zcl_skylint_max_line_len.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_max_line_len.clas.abap)
