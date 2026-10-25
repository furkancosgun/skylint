---
description: "Class Attribute and Parameter Naming Conventions"
---

# Enforce Class Attribute and Method Parameter Naming Conventions

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="danger" text="#EC NAMING_MEM" />
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

| Parameter Name | Data Type | Default Value |
|---|---|:---:|
| `ATTR_IGN_EXC` | `Boolean` | <code>true</code> |
| `ATTR_IGN_LOCAL` | `Boolean` | <code>true</code> |
| `ATTR_IGN_INTF` | `Boolean` | <code>false</code> |
| `ATTR_STATICS` | `String` | <code>^G._.+$</code> |
| `ATTR_INSTANCE` | `String` | <code>^M._.+$</code> |
| `ATTR_CONSTANTS` | `String` | <code></code> |
| `PARAM_IGN_EXC` | `Boolean` | <code>true</code> |
| `PARAM_IMPORTING` | `String` | <code>^I._.+$</code> |
| `PARAM_RETURNING` | `String` | <code>^R._.+$</code> |
| `PARAM_CHANGING` | `String` | <code>^C._.+$</code> |
| `PARAM_EXPORTING` | `String` | <code>^E._.+$</code> |
| `SSCR_PARAM` | `String` | <code>^P_.+$</code> |
| `SSCR_SELOPT` | `String` | <code>^S_.+$</code> |

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC NAMING_MEM

" SAP CI_ prefix format:
... "#EC CI_NAMING_MEM
```

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_NAMING_MEMBERS`
* **Implementation File:** [zcl_skylint_naming_members.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_naming_members.clas.abap)
