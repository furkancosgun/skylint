---
title: "Name Static Factory Methods CREATE_* When They Return Their Own Class"
description: "Enforce the CREATE_ prefix on ABAP static factory methods that return their own class, so object creation is recognisable at every call site."
keywords: "ABAP factory method, CREATE_ naming convention, static constructor ABAP, SAP ATC, pref-factory-name"
category: "clean-abap"
ruleId: "pref-factory-name"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L4112"
---

# Name Static Factory Methods CREATE_* When They Return Their Own Class

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="danger" text="#EC PREF_FACTORY_NAME" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L4112" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Factory methods should start with CREATE_.

> **ATC Finding Message:** `Factory method returning own class type should start with prefix`

## Rationale

A CLASS-METHODS declaration that returns TYPE REF TO its own class is a factory, and callers should recognise that from the call site alone. Names such as `build`, `new_instance` or `get_object` hide the instantiation intent, especially when they sit next to real business methods in the same class. The check compares the RETURNING type with the enclosing class name and requires the configured prefix, which keeps `lcl_invoice_service=>create_instance( )` idiomatic, greppable and consistent across packages.

### Non-Compliant

```abap
CLASS lcl_invoice_service DEFINITION.
  PUBLIC SECTION.
    CLASS-METHODS build
      RETURNING VALUE(ro_service) TYPE REF TO lcl_invoice_service.
ENDCLASS.
```

### Compliant

```abap
CLASS lcl_invoice_service DEFINITION.
  PUBLIC SECTION.
    CLASS-METHODS create_instance
      RETURNING VALUE(ro_service) TYPE REF TO lcl_invoice_service.
ENDCLASS.
```

## Configuration & Thresholds

This check can be fine-tuned directly in the ATC Check Variant Editor (`CHKV`) in Eclipse ADT:

| Parameter Name | Data Type | Default Value | Description & Guidance |
|---|---|:---:|---|
| `PREFIX` | `String` | <code>CREATE_</code> | Required name prefix for static factory methods returning the class's own type (default CREATE_, applied as a case-insensitive CP pattern). |

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC PREF_FACTORY_NAME

" SAP CI_ prefix format:
... "#EC CI_PREF_FACTORY_NAME
```

### What is (and is not) reported

The rule only inspects `CLASS-METHODS` declarations directly inside a `CLASS ... DEFINITION` block and raises `PREF_FCTNM` on the declaration when **both** conditions hold:

1. the method has a `RETURNING` parameter typed `TYPE REF TO <enclosing class>`, and
2. the method name does not match the configured prefix pattern (default `CREATE_*`).

| Declaration | Reported |
| --- | --- |
| `CLASS-METHODS build RETURNING VALUE(ro) TYPE REF TO lcl_service.` | yes |
| `CLASS-METHODS create_instance RETURNING VALUE(ro) TYPE REF TO lcl_service.` | no |
| `METHODS build RETURNING VALUE(ro) TYPE REF TO lcl_service.` (instance method) | no |
| `CLASS-METHODS build RETURNING VALUE(ro) TYPE REF TO lif_service.` | no |
| `CLASS-METHODS build RETURNING VALUE(rv_count) TYPE i.` | no |
| `CONSTRUCTOR` | no |

### Tuning the prefix

`PREFIX` is matched as a `CP` wildcard pattern, so the trailing underscore matters: with the default `CREATE_`, a method called `create` is still reported while `create_instance` and `create_from_order` pass. If your guideline uses `NEW_` or `FACTORY_`, change the attribute but keep the separator so that names like `CREATION_DATE` are not accidentally accepted. A deliberate exception (for example a generated factory with a fixed name) can be suppressed with `"#EC PREF_FACTORY_NAME`.


## Related Rules

* [Design for Inheritance or Prohibit It with FINAL](/rules/pref-final-cls) — <code>#EC PREF_FINAL_CLASS</code>
* [Avoid Granting Friendship via FRIENDS in Class Definitions](/rules/no-friends) — <code>#EC NO_FRIENDS</code>
* [Call Static Methods with Class Component Selector (=>)](/rules/no-static-arrow) — <code>#EC NO_STATIC_ARROW</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_PREF_FACTORY_NAME`
* **ABAP Implementation:** [/skyl/cl_pref_factory_name.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_pref_factory_name.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 4112)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L4112)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_PREF_FACTORY_NAME&title=%5BBug%5D%3A%20Issue%20in%20pref-factory-name)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20pref-factory-name)**
