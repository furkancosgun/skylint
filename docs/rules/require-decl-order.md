# Order Declarations (TYPES, CONSTANTS, DATA)

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="danger" text="Finding: DECL_ORDER" />
</div>

## Overview

Enforce local declaration order (TYPES -> CONSTANTS -> DATA -> FIELD-SYMBOLS).

> **ATC Finding Message:** `Declare local TYPES before CONSTANTS before DATA before FIELD-SYMBOLS`

## Rationale

Declaring types first, then constants, then data variables creates a logical reading flow where subsequent definitions can safely depend on preceding ones.

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

### ✕ Non-Compliant

```abap
METHOD execute.
  DATA lv_count TYPE i.
  TYPES ty_status TYPE c LENGTH 1. " TYPES declared after DATA
  CONSTANTS c_init TYPE ty_status VALUE 'I'.
ENDMETHOD.
```

### ✓ Compliant

```abap
METHOD execute.
  TYPES ty_status TYPE c LENGTH 1.
  CONSTANTS c_init TYPE ty_status VALUE 'I'.
  DATA lv_count TYPE i.
ENDMETHOD.
```

## CLI & CI/CD Configuration

```yaml
checks:
  require-decl-order:
    enabled: true
    severity: warning
```

## Suppression

To suppress findings for this rule, append the pseudo-comment or pragma to the statement:

```abap
" Using pseudo-comment:
... "#EC DECL_ORDER
" Or with SAP CI_ prefix:
... "#EC CI_DECL_ORDER

" Using pragma:
... ##DECL_ORDER.
" Or with SAP CI_ prefix:
... ##CI_DECL_ORDER.
```

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_PREF_DECL_ORDER`
* **Finding Code:** `DECL_ORDER`
* **Implementation File:** [zcl_skylint_pref_decl_order.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_pref_decl_order.clas.abap)
