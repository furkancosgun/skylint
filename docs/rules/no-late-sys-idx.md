---
title: "Avoid Late Access to sy-tabix or sy-index Outside Loops"
description: "Avoid Late Access to sy-tabix or sy-index Outside Loops - Clean ABAP guidelines, modern SAP syntax rules, and automated ATC code inspection for SAP S/4HANA and ABAP Cloud."
keywords: "Clean ABAP, SAP ATC Check, ABAP Cloud, S/4HANA Readiness, no-late-sys-idx, anti-patterns"
---

# Avoid Late Access to sy-tabix or sy-index Outside Loops

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Anti-Patterns & Bad Practices" />
  <Badge type="danger" text="#EC NO_LATE_SYS_IDX" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Avoid late access to sy-tabix or sy-index inside loops.

> **ATC Finding Message:** `Copy sy-tabix or sy-index immediately at loop start`

## Rationale

System fields sy-tabix and sy-index are global and mutable. Reading them outside their originating LOOP, DO, or WHILE blocks creates fragile temporal coupling that breaks easily when refactoring. Inside loops, capture index into an explicit local variable, or use line_index( ) instead of relying on sy-tabix outside.

### Non-Compliant

```abap
LOOP AT lt_items INTO ls_item.
ENDLOOP.
lv_last_idx = sy-tabix.
```

### Compliant

```abap
DATA lv_last_idx TYPE i.
LOOP AT lt_items INTO ls_item.
  lv_last_idx = sy-tabix.
ENDLOOP.
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC NO_LATE_SYS_IDX

" SAP CI_ prefix format:
... "#EC CI_NO_LATE_SYS_IDX
```

## References & Standards

* [Official SAP Clean ABAP Style Guide](https://github.com/SAP/styleguides/blob/main/clean-abap/CleanABAP.md)
* [SAP ABAP Keyword Documentation](https://help.sap.com/doc/abapdocu_cp_index_htm/CLOUD/en-US/index.htm)

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_NO_LATE_SYS_IDX`
* **Implementation File:** [zcl_skylint_no_late_sys_idx.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_no_late_sys_idx.clas.abap)
