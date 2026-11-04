---
title: "Enforce Class, Interface, Type and Object Naming Conventions"
description: "Enforce Class, Interface, Type and Object Naming Conventions - Clean ABAP guidelines, modern SAP syntax rules, and automated ATC code inspection for SAP S/4HANA and ABAP Cloud."
keywords: "Clean ABAP, SAP ATC Check, ABAP Cloud, S/4HANA Readiness, pref-name-objects, clean-abap"
category: "clean-abap"
ruleId: "pref-name-objects"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L3449"
---

# Enforce Class, Interface, Type and Object Naming Conventions

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="danger" text="#EC PREF_NAME_OBJECTS" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L3449" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
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


## Related Rules

* [Enforce Class Attribute and Method Parameter Naming Conventions](/rules/pref-name-members) — <code>#EC PREF_NAME_MEMBERS</code>
* [Enforce Local Variable and Field-Symbol Naming Conventions](/rules/pref-naming-vars) — <code>#EC PREF_NAMING_VARS</code>
* [Use Predicate Naming for Boolean Methods (is_, has_, can_)](/rules/pref-pred-name) — <code>#EC PREF_PRED_NAME</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_PREF_NAME_OBJECTS`
* **ABAP Implementation:** [/skyl/cl_pref_name_objects.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_pref_name_objects.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 3449)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L3449)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_PREF_NAME_OBJECTS&title=%5BBug%5D%3A%20Issue%20in%20pref-name-objects)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20pref-name-objects)**
