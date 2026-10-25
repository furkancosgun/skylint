---
title: "Avoid Kernel and Native Database Calls (SYSTEM-CALL, EXEC SQL)"
description: "Ensure cross-platform compatibility and cloud compliance by avoiding SYSTEM-CALL and native EXEC SQL in ABAP."
keywords: "SYSTEM-CALL ABAP, EXEC SQL SAP Security, Clean Core Cloud Compliance"
---

# Avoid Kernel and Native Database Calls (SYSTEM-CALL, EXEC SQL)

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Security & Robustness" />
  <Badge type="danger" text="#EC NO_KERNEL_CALL" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Avoid Kernel and Native Calls.

> **ATC Finding Message:** `Avoid internal kernel calls (CALL, SYSTEM-CALL, EXEC SQL)`

## Rationale

Executing internal SAP kernel commands (`SYSTEM-CALL`) or native database procedures (`EXEC SQL`) bypasses the OpenSQL syntax layer, authorization buffers, and client separation. Kernel calls are undocumented, internal SAP proprietary instructions that break across kernel upgrades and are strictly forbidden in ABAP Cloud.

### Non-Compliant

```abap
" Anti-pattern: Undocumented kernel instruction
SYSTEM-CALL rfc_clone_connection.
```

### Compliant

```abap
" Clean ABAP Cloud: Use official released SAP APIs
cl_rfc_connection_factory=>create( )->clone( ).
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC NO_KERNEL_CALL

" SAP CI_ prefix format:
... "#EC CI_NO_KERNEL_CALL
```

## References & Standards

* [SAP Clean Core Guide for ABAP Cloud](https://help.sap.com)

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_NO_KERNEL_CALL`
* **Implementation File:** [zcl_skylint_no_kernel_call.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_no_kernel_call.clas.abap)
