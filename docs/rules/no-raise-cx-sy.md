---
description: "Avoid raising SAP internal system exceptions (cx_sy_*)"
---

# Avoid Explicitly Raising System Exceptions (CX_SY_*)

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Security & Robustness" />
  <Badge type="danger" text="#EC RAISE_CX_SY" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Avoid raising SAP internal system exceptions (cx_sy_*).

> **ATC Finding Message:** `Avoid raising SAP internal system exceptions; use application exceptions`

## Rationale

CX_SY_* exceptions describe failures detected by the ABAP runtime, such as invalid table access or division by zero. Applications should not fabricate those conditions because callers cannot distinguish them from real runtime faults. Define and raise a custom exception class for application errors instead.

### Non-Compliant

```abap
RAISE EXCEPTION NEW cx_sy_zerodivide( ).
```

### Compliant

```abap
RAISE EXCEPTION NEW cx_invalid_amount( ).
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC RAISE_CX_SY

" SAP CI_ prefix format:
... "#EC CI_RAISE_CX_SY
```

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_NO_RAISE_CX_SY`
* **Implementation File:** [zcl_skylint_no_raise_cx_sy.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_no_raise_cx_sy.clas.abap)
