---
title: "Limit Method Parameter Count and Require Multi-Line Signatures"
description: "Enforce clean method signatures in ABAP. Limit parameter count and format signatures with one parameter per line for readable Git diffs."
keywords: "ABAP Method Parameters Limit, Clean ABAP Signatures, Parameter Object Pattern SAP, ATC Clean Code Metrics"
category: "metrics"
ruleId: "max-params"
---

# Limit Method Parameter Count and Require Multi-Line Signatures

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Metrics & Complexity Limits" />
  <Badge type="danger" text="#EC MAX_PARAMS_COUNT" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Method parameter limits (count and lines).

> **ATC Finding Messages:**
> - `Method signature has too many parameters; consider grouping into structures`
> - `Keep max one method parameter definition per line`

## Rationale

Methods with excessive parameter signatures (more than 3-5 parameters) are a sign of weak abstraction. Callers struggle to remember parameter order, optional flags multiply, and method calls become unreadable. Furthermore, declaring multiple parameters on a single line clutters Git diffs and hinders peer review.

**Clean ABAP Guideline:** Prefer 0 to 3 parameters. If more data is needed, bundle logically related fields into a dedicated parameter structure or options object. Place each parameter on its own line.

### Non-Compliant

```abap
" Anti-pattern: 7 primitive parameters declared on one cramped line
METHODS create_invoice IMPORTING iv_cust TYPE kunnr iv_amt TYPE netpr iv_cur TYPE waers iv_date TYPE datum iv_tax TYPE mwskz iv_type TYPE fkart iv_desc TYPE string.
```

### Compliant

```abap
" Clean ABAP: Clean parameter structure, each parameter on a dedicated line
METHODS create_invoice
  IMPORTING
    is_invoice_request TYPE ty_invoice_request
  RETURNING
    VALUE(rv_invoice_id) TYPE ty_invoice_id.
```

## Configuration & Thresholds

This check can be fine-tuned directly in the ATC Check Variant Editor (`CHKV`) in Eclipse ADT:

| Parameter Name | Data Type | Default Value | Description & Guidance |
|---|---|:---:|---|
| `MAX_PARAMETERS` | `Integer` | <code>8</code> | Maximum allowed total parameters (IMPORTING, EXPORTING, CHANGING, RETURNING) |
| `CHECK_PARAM_LINE` | `Boolean` | <code>true</code> | Enforce one parameter per line in method definitions and invocations |

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC MAX_PARAMS_COUNT

" SAP CI_ prefix format:
... "#EC CI_MAX_PARAMS_COUNT
```

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_MAX_PARAMS`
* **Implementation File:** [zcl_skylint_max_params.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_max_params.clas.abap)
