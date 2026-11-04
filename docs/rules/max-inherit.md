---
title: "Limit Class Inheritance Depth and Favor Object Composition"
description: "Limit class inheritance depth in ABAP OOP to avoid fragile base classes and promote composition over inheritance."
keywords: "max-inherit, inheritance depth, object composition, Clean ABAP, SAP ATC"
category: "metrics"
ruleId: "max-inherit"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L2274"
---

# Limit Class Inheritance Depth and Favor Object Composition

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Metrics & Complexity Limits" />
  <Badge type="danger" text="#EC MAX_INHERIT" />
  <Badge type="warning" text="Local Only" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L2274" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Avoid deep class inheritance hierarchies.

> **ATC Finding Message:** `Avoid deep class inheritance; prefer composition over inheritance`

## Rationale

Deep class inheritance hierarchies (exceeding 2 to 3 levels) lead to fragile base class antipatterns and tight structural coupling. In modern ABAP Cloud architectures, changes to an ancestor class can cause unforeseen side effects in distant descendant classes. Deep hierarchies also complicate constructor chaining, attribute initialization, and test isolation. Clean ABAP strongly advises favoring object composition and role-based interfaces over inheritance hierarchies, enabling modularity, independent unit testing with test doubles, and resilient software design.

### Non-Compliant

```abap
CLASS zcl_persisted_record DEFINITION PUBLIC ABSTRACT CREATE PUBLIC.
ENDCLASS.
CLASS zcl_sales_document DEFINITION INHERITING FROM zcl_persisted_record CREATE PUBLIC.
ENDCLASS.
CLASS zcl_sales_order DEFINITION INHERITING FROM zcl_sales_document CREATE PUBLIC.
ENDCLASS.
CLASS zcl_rush_order DEFINITION INHERITING FROM zcl_sales_order CREATE PUBLIC.
ENDCLASS.
```

### Compliant

```abap
CLASS zcl_rush_order DEFINITION PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    INTERFACES zif_sales_order.
    METHODS constructor
      IMPORTING
        io_persistence TYPE REF TO zif_order_persistence
        io_pricing     TYPE REF TO zif_pricing_strategy.
ENDCLASS.
```

## Configuration & Thresholds

This check can be fine-tuned directly in the ATC Check Variant Editor (`CHKV`) in Eclipse ADT:

| Parameter Name | Data Type | Default Value | Description & Guidance |
|---|---|:---:|---|
| `MAX_DEPTH` | `Integer` | <code>3</code> | Maximum allowable inheritance depth levels from standard root object before reporting (default: 3). |

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC MAX_INHERIT

" SAP CI_ prefix format:
... "#EC CI_MAX_INHERIT
```

## Detection & RTTI Dependency

The check evaluates class definitions that contain an `INHERITING FROM` clause and inspects inheritance depth via ABAP Run-Time Type Identification (RTTI) using `/skyl/cl_rtti_util=>get_super_classes`.

| Finding Code | Severity | Remote Enabled | Suppression |
|---|---|---|---|
| `MAX_INHRT` | Warning | `abap_false` (local ATC only) | `##MAX_INHERIT` or `"#EC MAX_INHERIT` |

> **Notice:** Because RTTI descriptors are unavailable across RFC connections in remote ATC scenarios, this check sets `remote_enablement = abap_false` and runs strictly in local system inspections.


## Related Rules

* [Limit Class Member Attribute Count to Prevent God Objects](/rules/max-attributes) — <code>#EC MAX_ATTRIBUTES</code>
* [Limit Control Flow Block Nesting Depth](/rules/max-nesting) — <code>#EC MAX_NESTING</code>
* [Favor Object Composition and Delegation Over Class Inheritance](/rules/pref-composition) — <code>#EC PREF_COMPOSITION</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_MAX_INHERIT`
* **ABAP Implementation:** [/skyl/cl_max_inherit.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_max_inherit.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 2274)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L2274)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_MAX_INHERIT&title=%5BBug%5D%3A%20Issue%20in%20max-inherit)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20max-inherit)**
