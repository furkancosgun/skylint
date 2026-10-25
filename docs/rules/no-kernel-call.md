---
description: "Avoid Kernel and Native Calls"
---

# Avoid Kernel and Native Database Calls

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Security & Robustness" />
  <Badge type="danger" text="#EC KERNEL_CALL" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Avoid Kernel and Native Calls.

> **ATC Finding Message:** `Avoid internal kernel calls (CALL, SYSTEM-CALL, EXEC SQL)`

## Rationale

Direct kernel calls (SYSTEM-CALL, `CALL <literal>`) and native SQL (EXEC SQL) bypass ABAP runtime safety checks, security controls, and database portability layers. They are obsolete, dangerous, and unsupported in modern ABAP Cloud architectures. Use standard Open SQL/ABAP SQL or released kernel APIs instead.

### Non-Compliant

```abap
EXEC SQL.
  SELECT SYSDATE FROM DUAL;
ENDEXEC.
CALL 'C_DIR_READ_FINISH'.
```

### Compliant

```abap
SELECT SINGLE FROM /dmo/connection FIELDS connection_id INTO @DATA(lv_conn).
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC KERNEL_CALL

" SAP CI_ prefix format:
... "#EC CI_KERNEL_CALL
```

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_NO_KERNEL_CALL`
* **Implementation File:** [zcl_skylint_no_kernel_call.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_no_kernel_call.clas.abap)
