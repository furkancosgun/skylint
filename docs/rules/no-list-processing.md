---
description: "Prohibit classic list processing statements"
---

# Avoid Classic List Processing Statements

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Anti-Patterns & Bad Practices" />
  <Badge type="danger" text="#EC LIST_PROC" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Prohibit classic list processing statements.

> **ATC Finding Message:** `List processing statement is forbidden in OO/Cloud ABAP`

## Rationale

Classic list processing with WRITE, ULINE, FORMAT, and READ LINE only works in SAP GUI list reports and is unavailable in ABAP Cloud. It couples business logic to screen output and makes the code impossible to test independently. Use application logging or a modern UI framework instead of writing directly to a list.

### Non-Compliant

```abap
WRITE / 'Order processed:'.
ULINE.
```

### Compliant

```abap
mo_logger->info( 'Order processed:' ).
```

## Configuration & Thresholds

This check can be fine-tuned directly in the ATC Check Variant Editor (`CHKV`) in Eclipse ADT:

| Parameter Name | Data Type | Default Value |
|---|---|:---:|
| `CHECK_WRITE` | `Boolean` | <code>true</code> |
| `CHECK_ULINE` | `Boolean` | <code>true</code> |
| `CHECK_SKIP` | `Boolean` | <code>true</code> |
| `CHECK_OTHER` | `Boolean` | <code>true</code> |
| `IGN_WRITE_TO` | `Boolean` | <code>true</code> |
| `CHECK_LEAVE` | `Boolean` | <code>true</code> |
| `CHECK_REJECT` | `Boolean` | <code>true</code> |

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC LIST_PROC

" SAP CI_ prefix format:
... "#EC CI_LIST_PROC
```

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_NO_LIST_PROC`
* **Implementation File:** [zcl_skylint_no_list_proc.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_no_list_proc.clas.abap)
