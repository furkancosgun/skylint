---
title: "Limit Class Inheritance Depth (Favor Composition over Inheritance)"
description: "Prevent fragile base class antipatterns in ABAP OOP by limiting inheritance depth and favoring object composition."
keywords: "Inheritance depth limit ABAP, Favor composition over inheritance SAP, Clean ABAP OOP Design, ATC OOP Metrics"
---

# Limit Class Inheritance Depth (Favor Composition over Inheritance)

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Metrics & Complexity Limits" />
  <Badge type="danger" text="#EC MAX_INHERIT" />
  <Badge type="warning" text="Local Only" />
</div>

## Overview

Avoid deep class inheritance hierarchies.

> **ATC Finding Message:** `Avoid deep class inheritance; prefer composition over inheritance`

## Rationale

Deep class inheritance hierarchies (more than 2-3 levels) create tight coupling, brittle base class syndromes, and hidden dependencies. Subclasses inherit private state and side-effects from ancestors, making changes to base classes unpredictable across the entire codebase.

**Clean ABAP Guideline:** Favor **Object Composition** over Class Inheritance. Use interfaces to define contracts and inject dependencies instead of extending deep abstract class hierarchies.

### Non-Compliant

```abap
" Anti-pattern: 5 levels of concrete inheritance
CLASS zcl_entity DEFINITION ...
CLASS zcl_persisted_entity DEFINITION INHERITING FROM zcl_entity ...
CLASS zcl_sales_document DEFINITION INHERITING FROM zcl_persisted_entity ...
CLASS zcl_order DEFINITION INHERITING FROM zcl_sales_document ...
CLASS zcl_rush_order DEFINITION INHERITING FROM zcl_order ...
```

### Compliant

```abap
" Clean ABAP: Shallow hierarchy with composition and role-based interfaces
CLASS zcl_rush_order DEFINITION FINAL.
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
| `MAX_DEPTH` | `Integer` | <code>3</code> | Maximum allowable inheritance depth levels from standard root object |

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC MAX_INHERIT

" SAP CI_ prefix format:
... "#EC CI_MAX_INHERIT
```

## References & Standards

* [Clean ABAP: Favor Composition Over Inheritance](https://github.com/SAP/styleguides/blob/main/clean-abap/CleanABAP.md#favor-composition-over-inheritance)

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_MAX_INHERIT`
* **Implementation File:** [zcl_skylint_max_inherit.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_max_inherit.clas.abap)
