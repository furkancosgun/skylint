---
title: "Design for Inheritance or Prohibit It (FINAL)"
description: "Design for Inheritance or Prohibit It (FINAL) - Clean ABAP guidelines, modern SAP syntax rules, and automated ATC code inspection for SAP S/4HANA and ABAP Cloud."
keywords: "Clean ABAP, SAP ATC Check, ABAP Cloud, S/4HANA Readiness, pref-final-cls, clean-abap"
category: "clean-abap"
ruleId: "pref-final-cls"
---

# Design for Inheritance or Prohibit It (FINAL)

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="warning" text="QuickFix Ready" />
  <Badge type="danger" text="#EC PREF_FINAL_CLASS" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Prefer FINAL classes and methods by default.

> **ATC Finding Messages:**
> - `Classes should be marked FINAL by default unless designed for inheritance`
> - `Declare method as FINAL if it is not intended to be redefined`

## Rationale

A class that is not designed for inheritance can still be subclassed, and subclasses may depend on internal behavior that later changes. Marking the class FINAL prevents fragile base class problems and documents that no extension is intended. Remove FINAL only when the class has documented extension points.

### Non-Compliant

```abap
CLASS cl_customer_service DEFINITION
  PUBLIC CREATE PUBLIC.
  PUBLIC SECTION.
    METHODS execute.
ENDCLASS.
```

### Compliant

```abap
CLASS cl_customer_service DEFINITION
  PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    METHODS execute.
ENDCLASS.
```

## Automated QuickFix

This rule provides an **automated QuickFix** directly in Eclipse ABAP Development Tools (ADT):
1. Position the cursor on the flagged statement.
2. Press <kbd>Ctrl</kbd> + <kbd>1</kbd> (Quick Assist).
3. Select the automated refactoring to apply the clean syntax immediately.

## Configuration & Thresholds

This check can be fine-tuned directly in the ATC Check Variant Editor (`CHKV`) in Eclipse ADT:

| Parameter Name | Data Type | Default Value | Description & Guidance |
|---|---|:---:|---|
| `CHECK_CLASSES` | `Boolean` | <code>true</code> | Enforce FINAL on classes not designed for inheritance |
| `CHECK_METHODS` | `Boolean` | <code>true</code> | Enforce FINAL on methods not designed to be redefined |

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC PREF_FINAL_CLASS

" SAP CI_ prefix format:
... "#EC CI_PREF_FINAL_CLASS
```


## Related Rules

* [Limit Class Inheritance Depth (Favor Composition over Inheritance)](/rules/max-inherit) — <code>#EC MAX_INHERIT</code>
* [Prefer CREATE_* Prefix for Factory Methods Returning Own Class](/rules/pref-factory-name) — <code>#EC PREF_FACTORY_NAME</code>
* [Prefer Composition over Inheritance](/rules/pref-composition) — <code>#EC PREF_COMPOSITION</code>

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_PREF_FINAL_CLS`
* **Implementation File:** [zcl_skylint_pref_final_cls.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_pref_final_cls.clas.abap)
