---
description: "Enforce declaration order (TYPES, CONSTANTS, DATA, FS)"
---

# Order Declarations (TYPES, CONSTANTS, DATA)

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="danger" text="#EC DECL_ORDER" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Enforce declaration order (TYPES, CONSTANTS, DATA, FS).

> **ATC Finding Message:** `Declare local TYPES before CONSTANTS before DATA before FIELD-SYMBOLS`

## Rationale

Declarations in arbitrary order make dependencies hard to follow and can place a DATA declaration before the TYPE it uses. A stable order of TYPES, CONSTANTS, then DATA gives readers a predictable structure. Group declarations by kind at the top of the routine.

### Non-Compliant

```abap
METHOD execute.
  DATA lv_count TYPE i.
  TYPES ty_status TYPE c LENGTH 1.
  CONSTANTS c_init TYPE ty_status VALUE 'I'.
ENDMETHOD.
```

### Compliant

```abap
METHOD execute.
  TYPES ty_status TYPE c LENGTH 1.
  CONSTANTS c_init TYPE ty_status VALUE 'I'.
  DATA lv_count TYPE i.
ENDMETHOD.
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC DECL_ORDER

" SAP CI_ prefix format:
... "#EC CI_DECL_ORDER
```

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_PREF_DECL_ORDER`
* **Implementation File:** [zcl_skylint_pref_decl_order.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_pref_decl_order.clas.abap)
