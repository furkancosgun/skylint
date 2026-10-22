---
description: "Maximum Line Length"
---

# Limit Line Length

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="tip" text="Metrics & Complexity Limits" />
  <Badge type="danger" text="#EC LINE_LEN" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Maximum Line Length.

> **ATC Finding Message:** `Line length exceeds configured maximum limit`

## Rationale

Long lines reduce readability, force horizontal scrolling, and complicate code review. Keep source lines within a configurable limit (typically 120 characters) by breaking statements and using expression-based ABAP.

### Non-Compliant

```abap
DATA lv_extremely_long_variable_name_created_specifically_to_exceed_the_maximum_allowed_line_length_of_one_hundred_twenty_chars TYPE i.
```

### Compliant

```abap
DATA lv_compact_name TYPE i.
```

## Transformation

```diff
- DATA lv_extremely_long_variable_name_created_specifically_to_exceed_the_maximum_allowed_line_length_of_one_hundred_twenty_chars TYPE i.
+ DATA lv_compact_name TYPE i.
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
