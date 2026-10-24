---
description: "Provide FAILED and REPORTED in RAP EML statements"
---

# Provide FAILED and REPORTED in RAP EML Statements

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="danger" text="#EC EML_RESPONSE" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Provide FAILED and REPORTED in RAP EML statements.

> **ATC Finding Message:** `Always provide FAILED and REPORTED in EML statements`

## Rationale

In ABAP RESTful Application Programming Model (RAP), Entity Manipulation Language (EML) statements process transactional data. Omitting FAILED and REPORTED clauses causes silent failures, lost error messages, and unhandled business exceptions. Always provide both response parameters to safely inspect and propagate issues.

### Non-Compliant

```abap
MODIFY ENTITIES OF z_root
  ENTITY travel
  UPDATE FIELDS ( description ) WITH lt_update.
```

### Compliant

```abap
MODIFY ENTITIES OF z_root
  ENTITY travel
  UPDATE FIELDS ( description ) WITH lt_update
  FAILED DATA(lt_failed)
  REPORTED DATA(lt_reported).
```

## Configuration & Thresholds

This check can be fine-tuned directly in the ATC Check Variant Editor (`CHKV`) in Eclipse ADT:

| Parameter Name | Data Type | Default Value |
|---|---|:---:|
| `CHECK_MODIFY` | `Boolean` | <code>true</code> |
| `CHECK_READ` | `Boolean` | <code>true</code> |

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC EML_RESPONSE

" SAP CI_ prefix format:
... "#EC CI_EML_RESPONSE
```

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_NO_UNHANDLED_EML`
* **Implementation File:** [zcl_skylint_no_unhandled_eml.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_no_unhandled_eml.clas.abap)
