---
title: "Use Predicate Naming (is_, has_, can_) for Boolean Methods"
description: "Name boolean-returning methods with is_, has_ or can_ prefixes so predicates read as questions at every ABAP call site."
keywords: "pref-pred-name, predicate naming, abap_bool method, Clean ABAP, SAP ATC"
category: "clean-abap"
ruleId: "pref-pred-name"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L2246"
---

# Use Predicate Naming (is_, has_, can_) for Boolean Methods

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="danger" text="#EC PREF_PRED_NAME" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L2246" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Enforce predicate naming (IS_, HAS_) on boolean methods.

> **ATC Finding Message:** `Boolean-returning method should use predicate name (IS_, HAS_, CAN_)`

## Rationale

A boolean method reads best as a yes/no question, especially when it appears inside an IF condition or a COND expression. Names such as check_active or get_valid imply a status value or a side effect and force readers to look up the return type, while is_active or has_entries make the meaning obvious at the call site. The check inspects the RETURNING type, so only genuine flag methods are renamed and data-returning getters stay untouched.

### Non-Compliant

```abap
CLASS zcl_access_control DEFINITION PUBLIC CREATE PUBLIC.
  PUBLIC SECTION.
    METHODS check_authorization
      IMPORTING iv_user_id      TYPE i
      RETURNING VALUE(rv_is_allowed) TYPE abap_bool.
ENDCLASS.
```

### Compliant

```abap
CLASS zcl_access_control DEFINITION PUBLIC CREATE PUBLIC.
  PUBLIC SECTION.
    METHODS is_authorized
      IMPORTING iv_user_id      TYPE i
      RETURNING VALUE(rv_is_allowed) TYPE abap_bool.
ENDCLASS.
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC PREF_PRED_NAME

" SAP CI_ prefix format:
... "#EC CI_PREF_PRED_NAME
```

### Accepted predicate prefixes

Boolean methods pass when the name starts with one of:

`IS_`, `HAS_`, `CAN_`, `ARE_`, `WAS_`, `WERE_`, `SHOULD_`, `MUST_`, `EXISTS`, `CONTAINS`, `SUPPORTS`, `MATCHES`, `EQUALS`.

Only `RETURNING` parameters typed `abap_bool`, `abap_boolean`, `xsdbool`, `flag`, `xfeld`, `boolean` or `boole_d` are inspected. A method returning a status structure or an object reference is never reported, so `get_status` stays valid in that case. Use `"#EC PREF_PRED_NAME` to keep a legacy flag name.


## Related Rules

* [Enforce Standard Naming Conventions for Class Members, Parameters and Screens](/rules/pref-name-members) — <code>#EC PREF_NAME_MEMBERS</code>
* [Enforce Standard Naming Conventions for Classes, Interfaces, Types and Global Objects](/rules/pref-name-objects) — <code>#EC PREF_NAME_OBJECTS</code>
* [Enforce Configured Naming Conventions for Local Variables and Field-Symbols](/rules/pref-naming-vars) — <code>#EC PREF_NAMING_VARS</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_PREF_PRED_NAME`
* **ABAP Implementation:** [/skyl/cl_pref_pred_name.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_pref_pred_name.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 2246)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L2246)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_PREF_PRED_NAME&title=%5BBug%5D%3A%20Issue%20in%20pref-pred-name)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20pref-pred-name)**
