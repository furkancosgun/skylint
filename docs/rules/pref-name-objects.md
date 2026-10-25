---
title: "Enforce Class, Interface, Type and Object Naming Conventions"
description: "Enforce Class, Interface, Type and Object Naming Conventions - Clean ABAP guidelines, modern SAP syntax rules, and automated ATC code inspection for SAP S/4HANA and ABAP Cloud."
keywords: "Clean ABAP, SAP ATC Check, ABAP Cloud, S/4HANA Readiness, pref-name-objects, clean-abap"
---

# Enforce Class, Interface, Type and Object Naming Conventions

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="danger" text="#EC PREF_NAME_OBJECTS" />
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

| Parameter Name | Data Type | Default Value | Description & Guidance |
|---|---|:---:|---|
| `CLASS_LOCAL` | `String` | <code>^LC(L&#124;X)_.+$</code> | Regex pattern for local class names (default: ^LC(L&#124;X)_.+$) |
| `CLASS_TEST` | `String` | <code>^LTCL_.+$</code> | Regex pattern for test class names (default: ^LTCL_.+$) |
| `CLASS_GLOBAL` | `String` | <code>^ZC(L&#124;X)_.+$</code> | Regex pattern for global class names (default: ^ZC(L&#124;X)_.+$) |
| `INTF_LOCAL` | `String` | <code>^LIF_.+$</code> | Regex pattern for local interface names (default: ^LIF_.+$) |
| `INTF_GLOBAL` | `String` | <code>^ZIF_.+$</code> | Regex pattern for global interface names (default: ^ZIF_.+$) |
| `TYPES_PATTERN` | `String` | <code>^TY_.+$</code> | Regex pattern for type definitions (default: ^TY_.+$) |
| `MACRO_PATTERN` | `String` | <code>^_.+$</code> | Regex pattern for macros (default: ^_.+$) |
| `FORM_PATTERN` | `String` | <code>^F_.+$</code> | Regex pattern for form routines (default: ^F_.+$) |
| `FUNCTION_PATTERN` | `String` | <code>^Z.*$</code> | Regex pattern for function modules (default: ^Z.*$) |
| `EVENT_NAME` | `String` | <code>^[A-Z][A-Z0-9_]+$</code> | Regex pattern for event names |
| `EVENT_HANDLER` | `String` | <code>^ON_.+$</code> | Regex pattern for event handlers (default: ^ON_.+$) |
| `TEST_METHOD` | `String` | <code>^(TEST&#124;SHOULD)_.+$</code> | Regex pattern for test method names (default: ^(TEST&#124;SHOULD)_.+$) |
| `PROG_PATTERN` | `String` | <code>^Z.+$</code> | Regex pattern for program names (default: ^Z.+$) |
| `FUGR_PATTERN` | `String` | <code>^Z.+$</code> | Regex pattern for function groups (default: ^Z.+$) |

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC PREF_NAME_OBJECTS

" SAP CI_ prefix format:
... "#EC CI_PREF_NAME_OBJECTS
```

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_PREF_NAME_OBJECTS`
* **Implementation File:** [zcl_skylint_pref_name_objects.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_pref_name_objects.clas.abap)
