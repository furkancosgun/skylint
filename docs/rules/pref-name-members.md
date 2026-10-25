---
title: "Enforce Class Attribute and Method Parameter Naming Conventions"
description: "Enforce Class Attribute and Method Parameter Naming Conventions - Clean ABAP guidelines, modern SAP syntax rules, and automated ATC code inspection for SAP S/4HANA and ABAP Cloud."
keywords: "Clean ABAP, SAP ATC Check, ABAP Cloud, S/4HANA Readiness, pref-name-members, clean-abap"
category: "clean-abap"
ruleId: "pref-name-members"
---

# Enforce Class Attribute and Method Parameter Naming Conventions

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="danger" text="#EC PREF_NAME_MEMBERS" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Class Attribute and Parameter Naming Conventions.

> **ATC Finding Messages:**
> - `Class attribute name does not match configured pattern`
> - `Method parameter name does not match configured pattern`
> - `Selection screen element name does not match configured pattern`

## Rationale

Member variables and method signatures communicate the contract of object-oriented components. Enforcing prefixes (mv_* for instance attributes, gv_* for static attributes, iv_* for importing, ev_* for exporting, cv_* for changing, and rv_* for returning parameters) clarifies usage semantics across callers.

### Non-Compliant

```abap
METHODS execute
  IMPORTING data TYPE i
  RETURNING VALUE(result) TYPE i.
```

### Compliant

```abap
METHODS execute
  IMPORTING iv_data TYPE i
  RETURNING VALUE(rv_result) TYPE i.
```

## Configuration & Thresholds

This check can be fine-tuned directly in the ATC Check Variant Editor (`CHKV`) in Eclipse ADT:

| Parameter Name | Data Type | Default Value | Description & Guidance |
|---|---|:---:|---|
| `ATTR_IGN_EXC` | `Boolean` | <code>true</code> | Ignore exception class attributes (cx_*) |
| `ATTR_IGN_LOCAL` | `Boolean` | <code>true</code> | Ignore attributes in local test classes |
| `ATTR_IGN_INTF` | `Boolean` | <code>false</code> | Ignore interface component naming |
| `ATTR_STATICS` | `String` | <code>^G._.+$</code> | Regex pattern for static class attributes (default: ^G._.+$) |
| `ATTR_INSTANCE` | `String` | <code>^M._.+$</code> | Regex pattern for instance class attributes (default: ^M._.+$) |
| `ATTR_CONSTANTS` | `String` | <code></code> | Regex pattern for class constants (default: ^C._.+$) |
| `PARAM_IGN_EXC` | `Boolean` | <code>true</code> | Ignore parameter naming in exception classes |
| `PARAM_IMPORTING` | `String` | <code>^I._.+$</code> | Regex pattern for importing parameters (default: ^I._.+$) |
| `PARAM_RETURNING` | `String` | <code>^R._.+$</code> | Regex pattern for returning parameters (default: ^R._.+$) |
| `PARAM_CHANGING` | `String` | <code>^C._.+$</code> | Regex pattern for changing parameters (default: ^C._.+$) |
| `PARAM_EXPORTING` | `String` | <code>^E._.+$</code> | Regex pattern for exporting parameters (default: ^E._.+$) |
| `SSCR_PARAM` | `String` | <code>^P_.+$</code> | Regex pattern for selection screen parameters (default: ^P_.+$) |
| `SSCR_SELOPT` | `String` | <code>^S_.+$</code> | Regex pattern for select-options (default: ^S_.+$) |

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC PREF_NAME_MEMBERS

" SAP CI_ prefix format:
... "#EC CI_PREF_NAME_MEMBERS
```


## Related Rules

* [Enforce Class, Interface, Type and Object Naming Conventions](/rules/pref-name-objects) — <code>#EC PREF_NAME_OBJECTS</code>
* [Enforce Local Variable and Field-Symbol Naming Conventions](/rules/pref-naming-vars) — <code>#EC PREF_NAMING_VARS</code>
* [Use Predicate Naming for Boolean Methods (is_, has_, can_)](/rules/pref-pred-name) — <code>#EC PREF_PRED_NAME</code>

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_PREF_NAME_MEMBERS`
* **Implementation File:** [zcl_skylint_pref_name_members.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_pref_name_members.clas.abap)
