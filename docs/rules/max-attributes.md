---
title: "Limit Class Member Attribute Count (Prevent God Classes)"
description: "Prevent God Object antipatterns in ABAP by restricting member attribute counts and promoting cohesive domain class design."
keywords: "God Class ABAP, Class member attributes limit, Clean ABAP Cohesion, Single Responsibility Principle SAP"
category: "metrics"
ruleId: "max-attributes"
---

# Limit Class Member Attribute Count (Prevent God Classes)

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Metrics & Complexity Limits" />
  <Badge type="danger" text="#EC MAX_ATTRIBUTES" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Limit class member attributes to prevent God Classes.

> **ATC Finding Message:** `Class has too many member attributes; split into cohesive components`

## Rationale

Classes with dozens of member variables (`DATA mv_*`) almost always suffer from low cohesion. Such classes become stateful "God Objects" that manage unrelated responsibilities, leading to concurrency race conditions and untraceable state mutations.

**Clean ABAP Guideline:** Classes should have a small number of instance attributes that directly represent the core identity or essential collaborators of the object. Split bloated classes into focused domain components.

### Non-Compliant

```abap
" Anti-pattern: Class holding 40+ attributes for UI, DB, configuration, and logging
CLASS zcl_invoice_manager DEFINITION.
  PRIVATE SECTION.
    DATA mv_inv_id TYPE string.
    DATA mv_cust_name TYPE string.
    DATA mv_ui_theme TYPE string.
    DATA mv_db_connection TYPE string.
    DATA mv_log_handle TYPE balloghndl.
    " ... 35 more attributes ...
ENDCLASS.
```

### Compliant

```abap
" Clean ABAP: Small, cohesive class delegating to specialized services
CLASS zcl_invoice_processor DEFINITION FINAL.
  PRIVATE SECTION.
    DATA mv_invoice_id   TYPE ty_invoice_id.
    DATA mo_repository   TYPE REF TO zif_invoice_repo.
    DATA mo_tax_service  TYPE REF TO zif_tax_calculator.
ENDCLASS.
```

## Configuration & Thresholds

This check can be fine-tuned directly in the ATC Check Variant Editor (`CHKV`) in Eclipse ADT:

| Parameter Name | Data Type | Default Value | Description & Guidance |
|---|---|:---:|---|
| `MAX_ATTRIBUTES` | `Integer` | <code>5</code> | Maximum allowed instance and static attributes per class |

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC MAX_ATTRIBUTES

" SAP CI_ prefix format:
... "#EC CI_MAX_ATTRIBUTES
```

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_MAX_ATTRIBUTES`
* **Implementation File:** [zcl_skylint_max_attributes.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_max_attributes.clas.abap)
