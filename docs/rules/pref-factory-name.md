---
title: "Prefer CREATE_* Prefix for Factory Methods Returning Own Class"
description: "Prefer CREATE_* Prefix for Factory Methods Returning Own Class - Clean ABAP guidelines, modern SAP syntax rules, and automated ATC code inspection for SAP S/4HANA and ABAP Cloud."
keywords: "Clean ABAP, SAP ATC Check, ABAP Cloud, S/4HANA Readiness, pref-factory-name, clean-abap"
---

# Prefer CREATE_* Prefix for Factory Methods Returning Own Class

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="danger" text="#EC PREF_FACTORY_NAME" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Factory methods should start with CREATE_.

> **ATC Finding Message:** `Factory method returning own class type should start with prefix`

## Rationale

Static factory methods returning an instance of their enclosing class should clearly communicate instantiation intent by following standard naming conventions starting with CREATE_ (e.g. create, create_instance).

### Non-Compliant

```abap
CLASS-METHODS build RETURNING VALUE(ro_obj) TYPE REF TO lcl_service.
```

### Compliant

```abap
CLASS-METHODS create_instance RETURNING VALUE(ro_obj) TYPE REF TO lcl_service.
```

## Configuration & Thresholds

This check can be fine-tuned directly in the ATC Check Variant Editor (`CHKV`) in Eclipse ADT:

| Parameter Name | Data Type | Default Value | Description & Guidance |
|---|---|:---:|---|
| `PREFIX` | `String` | <code>CREATE_</code> | Required prefix for static factory constructor methods (default: CREATE_) |

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC PREF_FACTORY_NAME

" SAP CI_ prefix format:
... "#EC CI_PREF_FACTORY_NAME
```

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_PREF_FACTORY_NAME`
* **Implementation File:** [zcl_skylint_pref_factory_name.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_pref_factory_name.clas.abap)
