---
title: "Limit Source Code Line Length (Avoid Horizontal Scrolling)"
description: "Ensure clean side-by-side Git diffs in SAP ABAP by enforcing a 120-character line length limit."
keywords: "ABAP Line length limit, Horizontal scrolling code review, Clean ABAP Formatting, Eclipse ADT Formatting Rules"
category: "metrics"
ruleId: "max-line-len"
---

# Limit Source Code Line Length (Avoid Horizontal Scrolling)

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Metrics & Complexity Limits" />
  <Badge type="danger" text="#EC MAX_LINE_LEN" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Maximum Line Length.

> **ATC Finding Message:** `Line length exceeds configured maximum limit`

## Rationale

Excessively long code lines (beyond 120 characters) force developers to scroll horizontally during code reviews and side-by-side Git diff inspections in Eclipse ADT and web repositories. Long lines also obscure trailing conditions and operators.

**Clean ABAP Guideline:** Wrap statements intelligently across multiple lines before reaching 120 characters, indenting subsequent continuation lines under the parent operator or assignment.

### Non-Compliant

```abap
" Anti-pattern: 160+ characters stretching past standard monitor width
DATA(lo_order) = zcl_order_factory=>get_instance( )->create_from_request( is_request = ls_req iv_validate = abap_true iv_commit = abap_false ).
```

### Compliant

```abap
" Clean ABAP: Formatted across logical continuation lines under 120 characters
DATA(lo_order) = zcl_order_factory=>get_instance( )->create_from_request(
  is_request  = ls_req
  iv_validate = abap_true
  iv_commit   = abap_false ).
```

## Configuration & Thresholds

This check can be fine-tuned directly in the ATC Check Variant Editor (`CHKV`) in Eclipse ADT:

| Parameter Name | Data Type | Default Value | Description & Guidance |
|---|---|:---:|---|
| `MAX_LENGTH` | `Integer` | <code>120</code> | Maximum allowed character length per source code line (industry standard: 120) |

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC MAX_LINE_LEN

" SAP CI_ prefix format:
... "#EC CI_MAX_LINE_LEN
```

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_MAX_LINE_LEN`
* **Implementation File:** [zcl_skylint_max_line_len.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_max_line_len.clas.abap)
