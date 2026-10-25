---
title: "Avoid Redundant ME-> Self Reference"
description: "Avoid Redundant ME-> Self Reference - Clean ABAP guidelines, modern SAP syntax rules, and automated ATC code inspection for SAP S/4HANA and ABAP Cloud."
keywords: "Clean ABAP, SAP ATC Check, ABAP Cloud, S/4HANA Readiness, no-me-reference, anti-patterns"
---

# Avoid Redundant ME-> Self Reference

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Anti-Patterns & Bad Practices" />
  <Badge type="danger" text="#EC NO_ME_REFERENCE" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Avoid self-reference ME->.

> **ATC Finding Message:** `Avoid unnecessary ME-> reference`

## Rationale

Member variables and methods are already accessible inside an instance method, so prefixing every access with me-> only adds noise. Removing the prefix keeps attention on the member itself and makes genuine shadowing easier to spot. Keep me-> only where a parameter or local variable shadows the member, typically in constructors and setters.

### Non-Compliant

```abap
me->mv_order_count = me->mv_order_count + 1.
me->save( ).
```

### Compliant

```abap
mv_order_count = mv_order_count + 1.
save( ).
```

## Configuration & Thresholds

This check can be fine-tuned directly in the ATC Check Variant Editor (`CHKV`) in Eclipse ADT:

| Parameter Name | Data Type | Default Value | Description & Guidance |
|---|---|:---:|---|
| `ALLOW_IN_CONSTRUCTORS` | `Boolean` | <code>true</code> | Allow me-> in CONSTRUCTOR methods when assigning parameters with identical names to attributes |

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC NO_ME_REFERENCE

" SAP CI_ prefix format:
... "#EC CI_NO_ME_REFERENCE
```

## References & Standards

* [Official SAP Clean ABAP Style Guide](https://github.com/SAP/styleguides/blob/main/clean-abap/CleanABAP.md)
* [SAP ABAP Keyword Documentation](https://help.sap.com/doc/abapdocu_cp_index_htm/CLOUD/en-US/index.htm)

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_NO_ME_REFERENCE`
* **Implementation File:** [zcl_skylint_no_me_reference.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_no_me_reference.clas.abap)
