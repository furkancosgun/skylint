---
description: "Catch specific exceptions instead of generic cx_root"
---

# Avoid Catching Generic CX_ROOT

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Security & Robustness" />
  <Badge type="danger" text="#EC CATCH_ROOT" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Catch specific exceptions instead of generic cx_root.

> **ATC Finding Message:** `Avoid generic CATCH cx_root; catch specific exception classes instead`

## Rationale

Catching CX_ROOT catches programming errors, resource shortages, and runtime failures together with expected business exceptions. The handler cannot respond correctly to all of them and may hide serious defects. Catch only the specific exception types you can handle and let everything else propagate.

### Non-Compliant

```abap
TRY.
  process_order( ).
CATCH cx_root.
  " swallowed
ENDTRY.
```

### Compliant

```abap
TRY.
  process_order( ).
CATCH cx_order_failed INTO DATA(lx_order).
  logger->record( lx_order ).
ENDTRY.
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC CATCH_ROOT

" SAP CI_ prefix format:
... "#EC CI_CATCH_ROOT
```

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_NO_CATCH_ROOT`
* **Implementation File:** [zcl_skylint_no_catch_root.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_no_catch_root.clas.abap)
