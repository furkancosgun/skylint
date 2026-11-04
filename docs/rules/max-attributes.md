---
title: "Limit Class Member Attribute Count to Prevent God Objects"
description: "Enforce member attribute limits on ABAP classes to avoid God Objects and maintain high cohesion and testability."
keywords: "max-attributes, God Class, member attributes, Clean ABAP, SAP ATC"
category: "metrics"
ruleId: "max-attributes"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L2305"
---

# Limit Class Member Attribute Count to Prevent God Objects

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Metrics & Complexity Limits" />
  <Badge type="danger" text="#EC MAX_ATTRIBUTES" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L2305" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Limit class member attributes to prevent God Classes.

> **ATC Finding Message:** `Class has too many member attributes; split into cohesive components`

## Rationale

Classes declaring an excessive number of instance or static attributes (`DATA` and `CLASS-DATA`) almost invariably suffer from low cohesion and violate the Single Responsibility Principle. Such classes tend to become stateful 'God Objects' that handle disparate operational domains—from persistence and UI formatting to business validation. High attribute counts introduce mutation race conditions, make state transitions hard to follow, and complicate ABAP Unit test fixture setup. Grouping cohesive attributes into structured data types or delegating responsibilities to specialized collaborator classes produces clean, maintainable object designs.

### Non-Compliant

```abap
CLASS zcl_customer_manager DEFINITION PUBLIC FINAL CREATE PUBLIC.
  PRIVATE SECTION.
    DATA mv_customer_id TYPE string.
    DATA mv_customer_name TYPE string.
    DATA mv_billing_address TYPE string.
    DATA mv_credit_limit TYPE p LENGTH 8 DECIMALS 2.
    DATA mv_payment_terms TYPE string.
    DATA mv_tax_number TYPE string.
    DATA mv_risk_category TYPE string.
ENDCLASS.
```

### Compliant

```abap
CLASS zcl_customer_manager DEFINITION PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    TYPES:
      BEGIN OF ty_customer_profile,
        customer_id   TYPE string,
        customer_name TYPE string,
        credit_limit  TYPE p LENGTH 8 DECIMALS 2,
        tax_number    TYPE string,
      END OF ty_customer_profile.
  PRIVATE SECTION.
    DATA ms_profile     TYPE ty_customer_profile.
    DATA mo_risk_engine TYPE REF TO zif_risk_evaluator.
ENDCLASS.
```

## Configuration & Thresholds

This check can be fine-tuned directly in the ATC Check Variant Editor (`CHKV`) in Eclipse ADT:

| Parameter Name | Data Type | Default Value | Description & Guidance |
|---|---|:---:|---|
| `MAX_ATTRIBUTES` | `Integer` | <code>5</code> | Maximum allowable member attributes (DATA and CLASS-DATA) in a class definition before reporting (default: 5). |

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC MAX_ATTRIBUTES

" SAP CI_ prefix format:
... "#EC CI_MAX_ATTRIBUTES
```

## Scope and Attribute Counting

The check inspects class definition blocks (`procedure_kinds-class_definition`). Every `DATA` and `CLASS-DATA` statement across all visibility sections (`PUBLIC`, `PROTECTED`, `PRIVATE`) increments the attribute count. Note that chained declarations (`DATA: ...`) are unrolled into individual `DATA` statements by Skylint's AST parser.

| Finding Code | Severity | Default Limit | Suppression |
|---|---|---|---|
| `MAX_ATTR` | Warning | `MAX_ATTRIBUTES` (5 attributes) | `##MAX_ATTRIBUTES` or `"#EC MAX_ATTRIBUTES` |

### Refactoring Strategy
Bundle related scalar fields into flat structures or extract independent subsystems into dedicated collaborator classes injected via constructor parameters.


## Related Rules

* [Limit Class Inheritance Depth and Favor Object Composition](/rules/max-inherit) — <code>#EC MAX_INHERIT</code>
* [Limit Method Parameter Count and Keep One Parameter per Line](/rules/max-params) — <code>#EC MAX_PARAMS_COUNT</code>
* [Limit Method and Constructor Statement Length](/rules/max-method-len) — <code>#EC MAX_METHOD_LEN</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_MAX_ATTRIBUTES`
* **ABAP Implementation:** [/skyl/cl_max_attributes.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_max_attributes.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 2305)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L2305)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_MAX_ATTRIBUTES&title=%5BBug%5D%3A%20Issue%20in%20max-attributes)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20max-attributes)**
