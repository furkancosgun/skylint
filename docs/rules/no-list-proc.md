---
title: "Avoid Classic List Processing Statements"
description: "Avoid Classic List Processing Statements - Clean ABAP guidelines, modern SAP syntax rules, and automated ATC code inspection for SAP S/4HANA and ABAP Cloud."
keywords: "Clean ABAP, SAP ATC Check, ABAP Cloud, S/4HANA Readiness, no-list-proc, anti-patterns"
category: "anti-patterns"
ruleId: "no-list-proc"
---

# Avoid Classic List Processing Statements

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Anti-Patterns & Bad Practices" />
  <Badge type="danger" text="#EC NO_LIST_PROC" />
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

| Parameter Name | Data Type | Default Value | Description & Guidance |
|---|---|:---:|---|
| `CHECK_WRITE` | `Boolean` | <code>true</code> | Detect classic list processing WRITE statements |
| `CHECK_ULINE` | `Boolean` | <code>true</code> | Detect classic ULINE statements |
| `CHECK_SKIP` | `Boolean` | <code>true</code> | Detect classic SKIP statements |
| `CHECK_OTHER` | `Boolean` | <code>true</code> | Detect BACK, FORMAT, and classic print formatting statements |
| `IGN_WRITE_TO` | `Boolean` | <code>true</code> | Ignore WRITE ... TO ... string formatting statements (use string templates instead) |
| `CHECK_LEAVE` | `Boolean` | <code>true</code> | Detect LEAVE LIST-PROCESSING statements |
| `CHECK_REJECT` | `Boolean` | <code>true</code> | Detect REJECT statements in logical databases |

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC NO_LIST_PROC

" SAP CI_ prefix format:
... "#EC CI_NO_LIST_PROC
```


## Related Rules

* [Avoid Obsolete Arithmetic and Assignment Statements](/rules/no-obs-arith) — <code>#EC NO_OBS_ARITH</code>
* [Avoid Obsolete Control Flow and Procedural Forms](/rules/no-obs-control) — <code>#EC NO_OBS_CONTROL</code>
* [Avoid Obsolete Declarations and Table Headers](/rules/no-obs-decl) — <code>#EC NO_OBS_DECL</code>

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_NO_LIST_PROC`
* **Implementation File:** [zcl_skylint_no_list_proc.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_no_list_proc.clas.abap)
