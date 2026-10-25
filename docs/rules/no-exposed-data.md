---
title: "Avoid Exposed Mutable Data in Classes and Interfaces"
description: "Avoid Exposed Mutable Data in Classes and Interfaces - Clean ABAP guidelines, modern SAP syntax rules, and automated ATC code inspection for SAP S/4HANA and ABAP Cloud."
keywords: "Clean ABAP, SAP ATC Check, ABAP Cloud, S/4HANA Readiness, no-exposed-data, anti-patterns"
---

# Avoid Exposed Mutable Data in Classes and Interfaces

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Anti-Patterns & Bad Practices" />
  <Badge type="danger" text="#EC PUBLIC_ATTR" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Avoid mutable data in public classes and interfaces.

> **ATC Finding Messages:**
> - `Avoid public attributes; use private/protected with getters or READ-ONLY`
> - `Avoid mutable DATA in interfaces; declare CONSTANTS or move to class`

## Rationale

Public mutable attributes in classes and DATA declarations in interfaces breach object-oriented encapsulation by allowing external callers to directly mutate internal state without invariant validation. Exposing state leaks implementation details and prevents clean contract evolution. Restrict data to PRIVATE/PROTECTED sections with getters (or READ-ONLY), and keep interfaces strictly stateless with methods and CONSTANTS.

### Non-Compliant

```abap
CLASS cl_model DEFINITION PUBLIC.
  PUBLIC SECTION.
    DATA mv_state TYPE i.
ENDCLASS.
INTERFACE if_customer.
  DATA mv_balance TYPE i.
ENDINTERFACE.
```

### Compliant

```abap
CLASS cl_model DEFINITION PUBLIC.
  PUBLIC SECTION.
    DATA mv_state TYPE i READ-ONLY.
ENDCLASS.
INTERFACE if_customer.
  CONSTANTS c_default_status TYPE i VALUE 1.
  METHODS get_balance RETURNING VALUE(rv_balance) TYPE i.
ENDINTERFACE.
```

## Configuration & Thresholds

This check can be fine-tuned directly in the ATC Check Variant Editor (`CHKV`) in Eclipse ADT:

| Parameter Name | Data Type | Default Value | Description & Guidance |
|---|---|:---:|---|
| `CHECK_PUBLIC_ATTR` | `Boolean` | <code>true</code> | Report public data attributes in classes (encapsulation violation) |
| `CHECK_INTF_DATA` | `Boolean` | <code>true</code> | Report data variable declarations inside interfaces (should contain only types, constants, methods) |

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC PUBLIC_ATTR

" SAP CI_ prefix format:
... "#EC CI_PUBLIC_ATTR
```

## References & Standards

* [Official SAP Clean ABAP Style Guide](https://github.com/SAP/styleguides/blob/main/clean-abap/CleanABAP.md)
* [SAP ABAP Keyword Documentation](https://help.sap.com/doc/abapdocu_cp_index_htm/CLOUD/en-US/index.htm)

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_NO_EXPOSED_DATA`
* **Implementation File:** [zcl_skylint_no_exposed_data.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_no_exposed_data.clas.abap)
