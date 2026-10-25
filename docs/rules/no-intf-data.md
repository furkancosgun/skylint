---
description: "Avoid mutable DATA in interfaces; allow only CONSTANTS"
---

# Avoid DATA Attributes in Interfaces

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Anti-Patterns & Bad Practices" />
  <Badge type="danger" text="#EC INTF_DATA" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Avoid mutable DATA in interfaces; allow only CONSTANTS.

> **ATC Finding Message:** `Avoid mutable DATA in interfaces; declare CONSTANTS or move to class`

## Rationale

Interfaces describe behavior and should not introduce mutable state into their contract. A DATA attribute in an interface exposes implementation details and can create shared state across all implementers. Use methods to expose state and constants for immutable values.

### Non-Compliant

```abap
INTERFACE if_customer.
  DATA mv_state TYPE i.
ENDINTERFACE.
```

### Compliant

```abap
INTERFACE if_customer.
  CONSTANTS c_default_status TYPE i VALUE 1.
  METHODS get_state RETURNING VALUE(rv_state) TYPE i.
ENDINTERFACE.
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
