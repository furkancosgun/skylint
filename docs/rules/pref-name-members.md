---
title: "Enforce Standard Naming Conventions for Class Members, Parameters and Screens"
description: "Enforce naming rules for ABAP class attributes, method parameters, and selection screen parameters with configurable regex patterns in SAP ATC."
keywords: "pref-name-members, member naming, method parameters, class attributes, Clean ABAP"
category: "clean-abap"
ruleId: "pref-name-members"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L3489"
---

# Enforce Standard Naming Conventions for Class Members, Parameters and Screens

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="danger" text="#EC PREF_NAME_MEMBERS" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L3489" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Class Attribute and Parameter Naming Conventions.

> **ATC Finding Messages:**
> - `Class attribute name does not match configured pattern`
> - `Method parameter name does not match configured pattern`
> - `Selection screen element name does not match configured pattern`

## Rationale

Member attributes and method signatures form the primary contract of object-oriented ABAP components. Enforcing conventional Hungarian prefixes (such as mv_ for instance attributes, gv_ for class data, iv_ for importing, ev_ for exporting, cv_ for changing, and rv_ for returning parameters) communicates parameter direction and attribute scope unambiguously to callers. Selection screen elements similarly require standard prefixes (p_ and s_) in classic reporting. Skylint validates class definitions and screen statements against customizable regex patterns, raising PREF_NMATR, PREF_NMPAR, or PREF_NAMSS on violations.

### Non-Compliant

```abap
CLASS zcl_customer_manager DEFINITION PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    DATA customer_status TYPE string.
    METHODS update_status
      IMPORTING new_status TYPE string
      RETURNING VALUE(is_ok) TYPE abap_bool.
ENDCLASS.
```

### Compliant

```abap
CLASS zcl_customer_manager DEFINITION PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    DATA mv_customer_status TYPE string.
    METHODS update_status
      IMPORTING iv_new_status TYPE string
      RETURNING VALUE(rv_is_ok) TYPE abap_bool.
ENDCLASS.
```

## Configuration & Thresholds

This check can be fine-tuned directly in the ATC Check Variant Editor (`CHKV`) in Eclipse ADT:

| Parameter Name | Data Type | Default Value | Description & Guidance |
|---|---|:---:|---|
| `ATTR_IGN_EXC` | `Boolean` | <code>true</code> | Bypass attribute naming checks in exception classes (classes inheriting from CX_*). |
| `ATTR_IGN_LOCAL` | `Boolean` | <code>false</code> | Bypass attribute naming checks in local classes, restricting checks to global definitions. |
| `ATTR_IGN_INTF` | `Boolean` | <code>false</code> | Bypass attribute naming checks within interface definitions. |
| `ATTR_STATICS` | `String` | <code>^G._.+$</code> | Regex pattern for static class attributes (CLASS-DATA), defaulting to ^G._.+$. |
| `ATTR_INSTANCE` | `String` | <code>^M._.+$</code> | Regex pattern for instance class attributes (DATA), defaulting to ^M._.+$. |
| `ATTR_CONSTANTS` | `String` | <code></code> | Regex pattern for class constants; left empty by default to allow any naming style. |
| `PARAM_IGN_EXC` | `Boolean` | <code>true</code> | Bypass method parameter naming checks for exception class constructors and methods. |
| `PARAM_IMPORTING` | `String` | <code>^I._.+$</code> | Regex pattern for method IMPORTING parameters, defaulting to ^I._.+$. |
| `PARAM_RETURNING` | `String` | <code>^R._.+$</code> | Regex pattern for method RETURNING parameters, defaulting to ^R._.+$. |
| `PARAM_CHANGING` | `String` | <code>^C._.+$</code> | Regex pattern for method CHANGING parameters, defaulting to ^C._.+$. |
| `PARAM_EXPORTING` | `String` | <code>^E._.+$</code> | Regex pattern for method EXPORTING parameters, defaulting to ^E._.+$. |
| `SSCR_PARAM` | `String` | <code>^P_.+$</code> | Regex pattern for classic selection screen PARAMETERS, defaulting to ^P_.+$. |
| `SSCR_SELOPT` | `String` | <code>^S_.+$</code> | Regex pattern for classic selection screen SELECT-OPTIONS, defaulting to ^S_.+$. |

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC PREF_NAME_MEMBERS

" SAP CI_ prefix format:
... "#EC CI_PREF_NAME_MEMBERS
```

## Configuration and Monitored Constructs

| Element | Finding Code | Default Regex Pattern | Example |
|---|---|---|---|
| Instance Attribute (`DATA`) | `PREF_NMATR` | `^M._.+$` | `mv_order_id`, `mt_items` |
| Static Attribute (`CLASS-DATA`) | `PREF_NMATR` | `^G._.+$` | `gv_instance_counter` |
| Importing Parameter | `PREF_NMPAR` | `^I._.+$` | `iv_customer_id`, `it_orders` |
| Exporting Parameter | `PREF_NMPAR` | `^E._.+$` | `ev_error_message` |
| Changing Parameter | `PREF_NMPAR` | `^C._.+$` | `cv_status_flag` |
| Returning Parameter | `PREF_NMPAR` | `^R._.+$` | `rv_is_valid` |
| Selection Screen Parameter | `PREF_NAMSS` | `^P_.+$` | `p_bukrs` |
| Selection Screen Select-Option | `PREF_NAMSS` | `^S_.+$` | `s_kunnr` |

Suppress findings with pseudo comment `"#EC PREF_NAME_MEMBERS`.


## Related Rules

* [Enforce Standard Naming Conventions for Classes, Interfaces, Types and Global Objects](/rules/pref-name-objects) — <code>#EC PREF_NAME_OBJECTS</code>
* [Enforce Configured Naming Conventions for Local Variables and Field-Symbols](/rules/pref-naming-vars) — <code>#EC PREF_NAMING_VARS</code>
* [Use Predicate Naming (is_, has_, can_) for Boolean Methods](/rules/pref-pred-name) — <code>#EC PREF_PRED_NAME</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_PREF_NAME_MEMBERS`
* **ABAP Implementation:** [/skyl/cl_pref_name_members.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_pref_name_members.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 3489)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L3489)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_PREF_NAME_MEMBERS&title=%5BBug%5D%3A%20Issue%20in%20pref-name-members)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20pref-name-members)**
