# Avoid DATA Attributes in Interfaces

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="tip" text="Anti-Patterns & Bad Practices" />
  <Badge type="danger" text="#EC INTF_DATA" />
</div>

## Overview

Avoid mutable DATA in interfaces; allow only CONSTANTS.

> **ATC Finding Message:** `Avoid mutable DATA in interfaces; declare CONSTANTS or move to class`

## Rationale

Interfaces should declare behavior (methods) and immutable contracts (constants). Mutable data in interfaces creates hidden global state across all implementers.

### Non-Compliant

```abap
INTERFACE if_customer.
  DATA mv_state TYPE i. " Mutable DATA in interface
ENDINTERFACE.
```

### Compliant

```abap
INTERFACE if_customer.
  CONSTANTS c_default_status TYPE i VALUE 1.
  METHODS get_state RETURNING VALUE(rv_state) TYPE i.
ENDINTERFACE.
```

## Transformation

```diff
- INTERFACE if_customer.
-   DATA mv_state TYPE i. " Mutable DATA in interface
- ENDINTERFACE.
+ INTERFACE if_customer.
+   CONSTANTS c_default_status TYPE i VALUE 1.
+   METHODS get_state RETURNING VALUE(rv_state) TYPE i.
+ ENDINTERFACE.
```

## CLI & CI/CD Configuration

```yaml
checks:
  no-interface-data:
    enabled: true
    severity: warning
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC INTF_DATA

" SAP CI_ prefix format:
... "#EC CI_INTF_DATA
```

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_NO_INTF_DATA`
* **Implementation File:** [zcl_skylint_no_intf_data.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_no_intf_data.clas.abap)
