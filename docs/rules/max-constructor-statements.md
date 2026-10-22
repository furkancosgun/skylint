---
description: "Keep constructors clean; avoid heavy logic and DB"
---

# Keep Constructors Clean & Lightweight

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Metrics & Complexity Limits" />
  <Badge type="danger" text="#EC CLEAN_CTOR" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Keep constructors clean; avoid heavy logic and DB.

> **ATC Finding Message:** `Avoid heavy business logic/loops in constructor; use injection only`

## Rationale

A constructor overloaded with business logic, database access, or I/O is hard to instantiate in tests and hides its dependencies. Construction should be cheap and predictable, with failures handled by explicit factory or service logic. Limit constructors to dependency injection and simple state initialization.

### Non-Compliant

```abap
METHOD constructor.
  super->constructor( ).
  mv_id = iv_id.
  mv_name = iv_name.
  mv_status = c_new.
  mv_created_at = utclong_current( ).
  mv_created_by = sy-uname.
  mv_total = 0.
  mv_currency = c_currency.
  mv_language = sy-langu.
  mv_country = iv_country.
  mv_note = iv_note.
  load_defaults( ).
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
| `MAX_STATEMENTS` | `Integer` | <code>10</code> |

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC CLEAN_CTOR

" SAP CI_ prefix format:
... "#EC CI_CLEAN_CTOR
```

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_MAX_CTOR_STMTS`
* **Implementation File:** [zcl_skylint_max_ctor_stmts.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_max_ctor_stmts.clas.abap)
