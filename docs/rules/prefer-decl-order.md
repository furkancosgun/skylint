---
description: "Enforce declaration order (TYPES, CONSTANTS, DATA, FS)"
---

# Order Declarations (TYPES, CONSTANTS, DATA)

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="danger" text="#EC DECL_ORDER" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Enforce declaration order (TYPES, CONSTANTS, DATA, FS).

> **ATC Finding Message:** `Declare local TYPES before CONSTANTS before DATA before FIELD-SYMBOLS`

## Rationale

Declaring types first, then constants, then data variables creates a logical reading flow where subsequent definitions can safely depend on preceding ones.

### Non-Compliant

```abap
METHOD execute.
  DATA lv_count TYPE i.
  TYPES ty_status TYPE c LENGTH 1. " TYPES declared after DATA
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

## Transformation

```diff
- METHOD execute.
-   DATA lv_count TYPE i.
-   TYPES ty_status TYPE c LENGTH 1. " TYPES declared after DATA
-   CONSTANTS c_init TYPE ty_status VALUE 'I'.
- ENDMETHOD.
+ METHOD execute.
+   TYPES ty_status TYPE c LENGTH 1.
+   CONSTANTS c_init TYPE ty_status VALUE 'I'.
+   DATA lv_count TYPE i.
+ ENDMETHOD.
```

## CLI & CI/CD Configuration

```yaml
checks:
  prefer-decl-order:
    enabled: true
    severity: warning
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
