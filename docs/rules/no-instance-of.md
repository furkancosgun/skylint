---
title: "Avoid IS INSTANCE OF and CASE TYPE OF Type Tests"
description: "Avoid IS INSTANCE OF and CASE TYPE OF Type Tests - Clean ABAP guidelines, modern SAP syntax rules, and automated ATC code inspection for SAP S/4HANA and ABAP Cloud."
keywords: "Clean ABAP, SAP ATC Check, ABAP Cloud, S/4HANA Readiness, no-instance-of, clean-abap"
---

# Avoid IS INSTANCE OF and CASE TYPE OF Type Tests

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="danger" text="#EC NO_INSTANCE_OF" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Avoid IS INSTANCE OF / CASE TYPE OF checks.

> **ATC Finding Message:** `Avoid runtime type checks via IS INSTANCE OF; use polymorphism`

## Rationale

Checking concrete object types at runtime via IS INSTANCE OF or CASE TYPE OF breaks polymorphism, violates the Open-Closed Principle, and introduces fragile type coupling. Instead of conditional type inspection, introduce polymorphic methods on common interfaces.

### Non-Compliant

```abap
IF io_shape IS INSTANCE OF cl_circle.
  render_circle( ).
ENDIF.
```

### Compliant

```abap
io_shape->render( ).
```

## Configuration & Thresholds

This check can be fine-tuned directly in the ATC Check Variant Editor (`CHKV`) in Eclipse ADT:

| Parameter Name | Data Type | Default Value | Description & Guidance |
|---|---|:---:|---|
| `CHECK_CASE_TYPE` | `Boolean` | <code>true</code> | Report CASE TYPE OF type tests in addition to IS INSTANCE OF |

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC NO_INSTANCE_OF

" SAP CI_ prefix format:
... "#EC CI_NO_INSTANCE_OF
```

## References & Standards

* [Official SAP Clean ABAP Style Guide](https://github.com/SAP/styleguides/blob/main/clean-abap/CleanABAP.md)
* [SAP ABAP Keyword Documentation](https://help.sap.com/doc/abapdocu_cp_index_htm/CLOUD/en-US/index.htm)

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_NO_INSTANCE_OF`
* **Implementation File:** [zcl_skylint_no_instance_of.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_no_instance_of.clas.abap)
