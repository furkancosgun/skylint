---
title: "Enforce Standard Naming Conventions for Classes, Interfaces, Types and Global Objects"
description: "Standardize naming conventions for ABAP classes, interfaces, types, events, and programs with configurable ATC regex rules."
keywords: "pref-name-objects, class naming, interface naming, types, Clean ABAP, ABAP Cloud"
category: "clean-abap"
ruleId: "pref-name-objects"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L3532"
---

# Enforce Standard Naming Conventions for Classes, Interfaces, Types and Global Objects

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="danger" text="#EC PREF_NAME_OBJECTS" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L3532" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
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

Consistent naming for architectural artifacts—such as classes (zcl_ / lcl_), interfaces (zif_ / lif_), type definitions (ty_), test classes (ltcl_), and event handlers (on_)—provides immediate clarity on object lifecycle, scope, and technical kind across repository trees. A unified naming scheme simplifies cross-package navigation, enhances searchability in ABAP Development Tools (ADT), and reinforces Clean ABAP structural guidelines. Skylint enforces configurable regex patterns for all core ABAP object definitions.

### Non-Compliant

```abap
CLASS order_service DEFINITION.
  PUBLIC SECTION.
    TYPES order_item_type TYPE string.
ENDCLASS.
```

### Compliant

```abap
CLASS lcl_order_service DEFINITION.
  PUBLIC SECTION.
    TYPES ty_order_item TYPE string.
ENDCLASS.
```

## Configuration & Thresholds

This check can be fine-tuned directly in the ATC Check Variant Editor (`CHKV`) in Eclipse ADT:

| Parameter Name | Data Type | Default Value | Description & Guidance |
|---|---|:---:|---|
| `CLASS_LOCAL` | `String` | <code>^LC(L&#124;X)_.+$</code> | Regex pattern for local class names, defaulting to ^LC(L&#124;X)_.+$. |
| `CLASS_TEST` | `String` | <code>^LTCL_.+$</code> | Regex pattern for ABAP Unit test class names, defaulting to ^LTCL_.+$. |
| `CLASS_GLOBAL` | `String` | <code>^ZC(L&#124;X)_.+$</code> | Regex pattern for global class names, defaulting to ^ZC(L&#124;X)_.+$. |
| `INTF_LOCAL` | `String` | <code>^LIF_.+$</code> | Regex pattern for local interface names, defaulting to ^LIF_.+$. |
| `INTF_GLOBAL` | `String` | <code>^ZIF_.+$</code> | Regex pattern for global interface names, defaulting to ^ZIF_.+$. |
| `TYPES_PATTERN` | `String` | <code>^TY_.+$</code> | Regex pattern for local and global type definitions (TYPES), defaulting to ^TY_.+$. |
| `MACRO_PATTERN` | `String` | <code>^_.+$</code> | Regex pattern for legacy DEFINE macros, defaulting to ^_.+$. |
| `FORM_PATTERN` | `String` | <code>^F_.+$</code> | Regex pattern for classic subroutine FORM names, defaulting to ^F_.+$. |
| `FUNCTION_PATTERN` | `String` | <code>^Z.*$</code> | Regex pattern for function module names, defaulting to ^Z.*$. |
| `EVENT_NAME` | `String` | <code>^[A-Z][A-Z0-9_]+$</code> | Regex pattern for class or interface EVENTS definitions, defaulting to ^[A-Z][A-Z0-9_]+$. |
| `EVENT_HANDLER` | `String` | <code>^ON_.+$</code> | Regex pattern for event handler method names (FOR EVENT), defaulting to ^ON_.+$. |
| `TEST_METHOD` | `String` | <code>^(TEST&#124;SHOULD)_.+$</code> | Regex pattern for ABAP Unit test method names, defaulting to ^(TEST&#124;SHOULD)_.+$. |
| `PROG_PATTERN` | `String` | <code>^Z.+$</code> | Regex pattern for executable REPORT and PROGRAM statements, defaulting to ^Z.+$. |
| `FUGR_PATTERN` | `String` | <code>^Z.+$</code> | Regex pattern for function pool definitions (FUNCTION-POOL), defaulting to ^Z.+$. |

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC PREF_NAME_OBJECTS

" SAP CI_ prefix format:
... "#EC CI_PREF_NAME_OBJECTS
```

## Monitored Object Types and Defaults

| Object Kind | Finding Code | Default Pattern | Valid Example |
|---|---|---|---|
| Local Class | `PREF_LCLS` | `^LC(L\|X)_.+$` | `lcl_order_handler` |
| Test Class | `PREF_LCLS` | `^LTCL_.+$` | `ltcl_order_tests` |
| Global Class | `PREF_GCLS` | `^ZC(L\|X)_.+$` | `zcl_invoice_service` |
| Local Interface | `PREF_LINTF` | `^LIF_.+$` | `lif_payment_gateway` |
| Global Interface | `PREF_GINTF` | `^ZIF_.+$` | `zif_payment_gateway` |
| Type Definition | `PREF_TYP` | `^TY_.+$` | `ty_customer_record` |
| Event Name | `PREF_EVT` | `^[A-Z][A-Z0-9_]+$` | `ORDER_CONFIRMED` |
| Event Handler | `PREF_EVT` | `^ON_.+$` | `on_order_confirmed` |
| Test Method | `PREF_TMETH` | `^(TEST\|SHOULD)_.+$` | `test_calculate_tax` |
| Form Routine | `PREF_FORM` | `^F_.+$` | `f_process_legacy` |
| Function Module | `PREF_FUNC` | `^Z.*$` | `z_calculate_pricing` |
| Function Group | `PREF_FUGR` | `^Z.+$` | `z_sales_group` |
| Program / Report | `PREF_PROG` | `^Z.+$` | `z_monthly_accruals` |

Suppress findings with pseudo comment `"#EC PREF_NAME_OBJECTS`.


## Related Rules

* [Enforce Standard Naming Conventions for Class Members, Parameters and Screens](/rules/pref-name-members) — <code>#EC PREF_NAME_MEMBERS</code>
* [Enforce Configured Naming Conventions for Local Variables and Field-Symbols](/rules/pref-naming-vars) — <code>#EC PREF_NAMING_VARS</code>
* [Use Predicate Naming (is_, has_, can_) for Boolean Methods](/rules/pref-pred-name) — <code>#EC PREF_PRED_NAME</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_PREF_NAME_OBJECTS`
* **ABAP Implementation:** [/skyl/cl_pref_name_objects.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_pref_name_objects.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 3532)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L3532)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_PREF_NAME_OBJECTS&title=%5BBug%5D%3A%20Issue%20in%20pref-name-objects)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20pref-name-objects)**
