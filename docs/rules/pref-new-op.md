---
title: "Prefer NEW #( ) over CREATE OBJECT"
description: "Prefer NEW #( ) over CREATE OBJECT - Clean ABAP guidelines, modern SAP syntax rules, and automated ATC code inspection for SAP S/4HANA and ABAP Cloud."
keywords: "Clean ABAP, SAP ATC Check, ABAP Cloud, S/4HANA Readiness, pref-new-op, clean-abap"
---

# Prefer NEW #( ) over CREATE OBJECT

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="warning" text="QuickFix Ready" />
  <Badge type="danger" text="#EC PREF_NEW_OPERATOR" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Prefer NEW operator over CREATE OBJECT and RAISE EXCEPTION.

> **ATC Finding Messages:**
> - `Prefer NEW #( ) expression over CREATE OBJECT`
> - `Prefer RAISE EXCEPTION NEW cx_name( ) over RAISE EXCEPTION TYPE`

## Rationale

CREATE OBJECT is the procedural object-creation statement and requires a separate declaration and assignment. NEW #( ) infers the class from the target, can be used inside expressions, and keeps construction close to where the reference is needed. Use NEW for object creation in modern ABAP and reserve CREATE OBJECT for legacy downport code.

### Non-Compliant

```abap
DATA lo_customer TYPE REF TO cl_customer.
CREATE OBJECT lo_customer EXPORTING iv_name = lv_name.
```

### Compliant

```abap
DATA lo_customer TYPE REF TO cl_customer.
lo_customer = NEW #( iv_name = lv_name ).
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
| `CHECK_CREATE_OBJECT` | `Boolean` | <code>true</code> | Suggest NEW #( ... ) over CREATE OBJECT |
| `CHECK_RAISE_EXCEPTION` | `Boolean` | <code>true</code> | Suggest RAISE EXCEPTION NEW over CREATE OBJECT followed by RAISE |

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC PREF_NEW_OPERATOR

" SAP CI_ prefix format:
... "#EC CI_PREF_NEW_OPERATOR
```

## References & Standards

* [Official SAP Clean ABAP Style Guide](https://github.com/SAP/styleguides/blob/main/clean-abap/CleanABAP.md)
* [SAP ABAP Keyword Documentation](https://help.sap.com/doc/abapdocu_cp_index_htm/CLOUD/en-US/index.htm)

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_PREF_NEW_OP`
* **Implementation File:** [zcl_skylint_pref_new_op.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_pref_new_op.clas.abap)
