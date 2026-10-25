---
description: "Method and Constructor Length Limits"
---

# Limit Method and Constructor Statement Counts

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Metrics & Complexity Limits" />
  <Badge type="danger" text="#EC METHOD_LEN" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Method and Constructor Length Limits.

> **ATC Finding Messages:**
> - `Method length exceeds maximum allowed statement limit`
> - `Avoid heavy business logic/loops in constructor; use injection only`

## Rationale

A routine with excessive statements usually carries multiple responsibilities and accumulates hard-to-follow local state. Similarly, constructors overloaded with business logic or database queries impair testability. Keep methods focused on a single responsibility (max 5 statements) and constructors dedicated to lightweight dependency injection (max 10 statements).

### Non-Compliant

```abap
METHOD constructor.
  super->constructor( ).
  mv_id = iv_id.
  " 10+ initialization statements and business queries...
ENDMETHOD.
```

### Compliant

```abap
METHOD constructor.
  super->constructor( ).
  mo_gateway = io_gateway.
  mv_id = iv_id.
ENDMETHOD.
```

## Configuration & Thresholds

This check can be fine-tuned directly in the ATC Check Variant Editor (`CHKV`) in Eclipse ADT:

| Parameter Name | Data Type | Default Value |
|---|---|:---:|
| `MAX_STATEMENTS` | `Integer` | <code>5</code> |
| `MAX_CTOR_STATEMENTS` | `Integer` | <code>10</code> |

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC METHOD_LEN

" SAP CI_ prefix format:
... "#EC CI_METHOD_LEN
```

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_MAX_METHOD_LEN`
* **Implementation File:** [zcl_skylint_max_method_len.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_max_method_len.clas.abap)
