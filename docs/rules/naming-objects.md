---
description: "Class, Interface, Type and Object Naming"
---

# Enforce Class, Interface, Type and Object Naming Conventions

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="danger" text="#EC NAMING_OBJ" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Class, Interface, Type and Object Naming.

> **ATC Finding Messages:**
> - `Local class name does not match configured pattern`
> - `Global class name does not match configured pattern`
> - `Local interface name does not match configured pattern`
> - `Global interface name does not match configured pattern`
> - `Type name does not match configured pattern`
> - `Event or event handler name does not match configured pattern`
> - `Test method name does not match configured pattern`
> - `Macro name does not match configured pattern`
> - `Form routine name does not match configured pattern`
> - `Function module name does not match configured pattern`
> - `Function group name does not match configured pattern`
> - `Program name does not match configured pattern`

## Rationale

Object-oriented entities and global artifacts must maintain standardized prefixes (such as zcl_ / lcl_ for classes, zif_ / lif_ for interfaces, ty_ for type definitions, and on_* for event handlers). This standard maintains harmony across packages, enhances IDE searchability, and reinforces Clean ABAP architecture.

### Non-Compliant

```abap
CLASS my_service DEFINITION.
INTERFACE my_contract.
TYPES item_type TYPE string.
```

### Compliant

```abap
CLASS lcl_my_service DEFINITION.
INTERFACE lif_my_contract.
TYPES ty_item TYPE string.
```

## Configuration & Thresholds

This check can be fine-tuned directly in the ATC Check Variant Editor (`CHKV`) in Eclipse ADT:

| Parameter Name | Data Type | Default Value |
|---|---|:---:|
| `CLASS_LOCAL` | `String` | <code>^LC(L&#124;X)_.+$</code> |
| `CLASS_TEST` | `String` | <code>^LTCL_.+$</code> |
| `CLASS_GLOBAL` | `String` | <code>^ZC(L&#124;X)_.+$</code> |
| `INTF_LOCAL` | `String` | <code>^LIF_.+$</code> |
| `INTF_GLOBAL` | `String` | <code>^ZIF_.+$</code> |
| `TYPES_PATTERN` | `String` | <code>^TY_.+$</code> |
| `MACRO_PATTERN` | `String` | <code>^_.+$</code> |
| `FORM_PATTERN` | `String` | <code>^F_.+$</code> |
| `FUNCTION_PATTERN` | `String` | <code>^Z.*$</code> |
| `EVENT_NAME` | `String` | <code>^[A-Z][A-Z0-9_]+$</code> |
| `EVENT_HANDLER` | `String` | <code>^ON_.+$</code> |
| `TEST_METHOD` | `String` | <code>^(TEST&#124;SHOULD)_.+$</code> |
| `PROG_PATTERN` | `String` | <code>^Z.+$</code> |
| `FUGR_PATTERN` | `String` | <code>^Z.+$</code> |

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC NAMING_OBJ

" SAP CI_ prefix format:
... "#EC CI_NAMING_OBJ
```

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_NAMING_OBJECTS`
* **Implementation File:** [zcl_skylint_naming_objects.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_naming_objects.clas.abap)
