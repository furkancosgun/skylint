---
description: "Prefer composition over inheritance"
---

# Prefer Composition over Inheritance

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="danger" text="#EC PREF_COMPOSITION" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Prefer composition over inheritance.

> **ATC Finding Message:** `Prefer composition over inheritance; only CX_* classes should inherit`

## Rationale

Inheritance creates tight coupling between subclasses and parent implementations, exposes internal state, and complicates refactoring. With the exception of exception hierarchies (CX_* classes) which require inheritance to participate in ABAP error handling, business objects should favor composition by holding references to collaborating classes and delegating tasks.

### Non-Compliant

```abap
CLASS lcl_order_processor DEFINITION INHERITING FROM lcl_order_validator.
ENDCLASS.
```

### Compliant

```abap
CLASS lcl_order_processor DEFINITION.
  PUBLIC SECTION.
    METHODS constructor IMPORTING io_validator TYPE REF TO lif_order_validator.
ENDCLASS.
```

## Configuration & Thresholds

This check can be fine-tuned directly in the ATC Check Variant Editor (`CHKV`) in Eclipse ADT:

| Parameter Name | Data Type | Default Value |
|---|---|:---:|
| `ALLOW_TEST_CLASSES` | `Boolean` | <code>false</code> |

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC PREF_COMPOSITION

" SAP CI_ prefix format:
... "#EC CI_PREF_COMPOSITION
```

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_PREF_COMPOSITION`
* **Implementation File:** [zcl_skylint_pref_composition.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_pref_composition.clas.abap)
