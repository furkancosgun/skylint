---
title: "Avoid Obsolete Declarations and Table Headers"
description: "Avoid Obsolete Declarations and Table Headers - Clean ABAP guidelines, modern SAP syntax rules, and automated ATC code inspection for SAP S/4HANA and ABAP Cloud."
keywords: "Clean ABAP, SAP ATC Check, ABAP Cloud, S/4HANA Readiness, no-obs-decl, anti-patterns"
---

# Avoid Obsolete Declarations and Table Headers

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Anti-Patterns & Bad Practices" />
  <Badge type="warning" text="QuickFix Ready" />
  <Badge type="danger" text="#EC NO_OBS_DECL" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Obsolete Data and Type Declarations.

> **ATC Finding Message:** `Avoid obsolete declaration constructs (TABLES, RANGES, TYPE-POOLS, etc.)`

## Rationale

Legacy declaration statements like TABLES, RANGES, TYPE-POOLS, and internal tables defined WITH HEADER LINE, OCCURS, or INITIAL SIZE carry significant technical debt and implicit global state. In modern Clean ABAP and ABAP Cloud, use explicit TYPES, DATA statements with modern table types, standard RANGE OF types, and CLEAR instead of REFRESH.

### Non-Compliant

```abap
TABLES mara.
RANGES lr_matnr FOR mara-matnr.
DATA lt_items TYPE STANDARD TABLE OF i WITH HEADER LINE.
```

### Compliant

```abap
DATA lt_items TYPE STANDARD TABLE OF i WITH EMPTY KEY.
DATA lr_matnr TYPE RANGE OF matnr.
```

## Automated QuickFix

This rule provides an **automated QuickFix** directly in Eclipse ABAP Development Tools (ADT):
1. Position the cursor on the flagged statement.
2. Press <kbd>Ctrl</kbd> + <kbd>1</kbd> (Quick Assist).
3. Select the automated refactoring to apply the clean syntax immediately.

## Configuration & Thresholds

This check can be fine-tuned directly in the ATC Check Variant Editor (`CHKV`) in Eclipse ADT:

| Parameter Name | Data Type | Default Value | Description & Guidance |
|---|---|:---:|---|
| `CHECK_TABLES` | `Boolean` | <code>true</code> | Detect obsolete TABLES declaration statement |
| `CHECK_TYPE_POOLS` | `Boolean` | <code>true</code> | Detect obsolete TYPE-POOLS declaration statement |
| `CHECK_RANGES` | `Boolean` | <code>true</code> | Detect obsolete RANGES declaration statement |
| `CHECK_HEADER_LINE` | `Boolean` | <code>true</code> | Detect internal tables with obsolete header lines (WITH HEADER LINE) |
| `CHECK_OCCURS` | `Boolean` | <code>true</code> | Detect obsolete INITIAL SIZE / OCCURS syntax |
| `CHECK_INITIAL_SIZE` | `Boolean` | <code>true</code> | Detect obsolete INITIAL SIZE additions |
| `CHECK_COMMON_PART` | `Boolean` | <code>true</code> | Detect obsolete DATA COMMON PART statements |
| `CHECK_STATICS` | `Boolean` | <code>true</code> | Detect STATICS declarations inside instance methods |
| `CHECK_FS_STRUCTURE` | `Boolean` | <code>true</code> | Detect FIELD-SYMBOLS with obsolete structure typing |
| `CHECK_LOAD` | `Boolean` | <code>true</code> | Detect obsolete LOAD-OF-PROGRAM statements |
| `CHECK_PARAMETER` | `Boolean` | <code>true</code> | Detect obsolete PARAMETER additions in selection screens |
| `CHECK_REFRESH` | `Boolean` | <code>true</code> | Detect obsolete REFRESH statement (prefer CLEAR) |

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC NO_OBS_DECL

" SAP CI_ prefix format:
... "#EC CI_NO_OBS_DECL
```

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_NO_OBS_DECL`
* **Implementation File:** [zcl_skylint_no_obs_decl.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_no_obs_decl.clas.abap)
