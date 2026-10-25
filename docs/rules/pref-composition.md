---
title: "Prefer Composition over Inheritance"
description: "Prefer Composition over Inheritance - Clean ABAP guidelines, modern SAP syntax rules, and automated ATC code inspection for SAP S/4HANA and ABAP Cloud."
keywords: "Clean ABAP, SAP ATC Check, ABAP Cloud, S/4HANA Readiness, pref-composition, clean-abap"
category: "clean-abap"
ruleId: "pref-composition"
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

| Parameter Name | Data Type | Default Value | Description & Guidance |
|---|---|:---:|---|
| `ALLOW_TEST_CLASSES` | `Boolean` | <code>false</code> | Allow class inheritance inside ABAP Unit test includes |

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC PREF_COMPOSITION

" SAP CI_ prefix format:
... "#EC CI_PREF_COMPOSITION
```


## Related Rules

* [Limit Class Inheritance Depth (Favor Composition over Inheritance)](/rules/max-inherit) — <code>#EC MAX_INHERIT</code>
* [Design for Inheritance or Prohibit It (FINAL)](/rules/pref-final-cls) — <code>#EC PREF_FINAL_CLASS</code>
* [Prefer NEW #( ) over CREATE OBJECT](/rules/pref-new-op) — <code>#EC PREF_NEW_OPERATOR</code>

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_PREF_COMPOSITION`
* **Implementation File:** [zcl_skylint_pref_composition.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_pref_composition.clas.abap)
