# Avoid Explicitly Raising System Exceptions (CX_SY_*)

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="tip" text="Security & Robustness" />
  <Badge type="danger" text="Finding: RAISE_SYS" />
</div>

## Overview

Avoid raising SAP internal system exceptions (cx_sy_*).

> **ATC Finding Message:** `Avoid raising SAP internal system exceptions; use application exceptions`

## Rationale

`cx_sy_*` exceptions are reserved exclusively for the ABAP runtime engine (e.g., divide by zero, null reference). Applications must define and raise their own custom exception hierarchies.

### Non-Compliant

```abap
RAISE EXCEPTION NEW cx_sy_itab_line_not_found( ).
```

### Compliant

```abap
RAISE EXCEPTION NEW cx_item_not_found( ).
```

## Transformation

```diff
- RAISE EXCEPTION NEW cx_sy_itab_line_not_found( ).
+ RAISE EXCEPTION NEW cx_item_not_found( ).
```

## CLI & CI/CD Configuration

```yaml
checks:
  no-raise-cx-sy:
    enabled: true
    severity: warning
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
* **Finding Code:** `RAISE_SYS`
* **Implementation File:** [zcl_skylint_no_raise_cx_sy.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_no_raise_cx_sy.clas.abap)
