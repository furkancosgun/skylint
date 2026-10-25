---
title: "Limit Method and Constructor Statement Length"
description: "Enforce Clean ABAP method length limits and keep constructors minimal. Prevent God Methods and improve testability in SAP ABAP."
keywords: "Method length limit ABAP, Clean ABAP Method Size, Constructor Logic Antipattern, Single Responsibility ABAP, ATC Code Metrics"
---

# Limit Method and Constructor Statement Length

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Metrics & Complexity Limits" />
  <Badge type="danger" text="#EC MAX_METHOD_LEN" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Method and Constructor Length Limits.

> **ATC Finding Messages:**
> - `Method length exceeds maximum allowed statement limit`
> - `Avoid heavy business logic/loops in constructor; use injection only`

## Rationale

Methods that contain hundreds of statements violate the **Single Responsibility Principle (SRP)**. They are difficult to comprehend, impossible to unit test thoroughly, and conceal copy-pasted business logic branches. Constructors are especially sensitive: heavy business logic or loops in constructors make dependency injection and mock testing impossible.

**Clean ABAP Guideline:** A clean method should do one thing, do it well, and do it only. Keep regular methods under 20-30 statements and keep constructors minimal (dependency assignment only).

### Non-Compliant

```abap
" Anti-pattern: Overly long method combining validation, calculation, DB updates, and logging
METHOD process_sales_order.
  " 150+ lines of mixed concerns...
  " Validation logic
  " Database reads
  " Currency conversion
  " Pricing calculations
  " Direct database updates
  " Email dispatch
ENDMETHOD.
```

### Compliant

```abap
" Clean ABAP: Short, focused methods delegating to dedicated domain services
METHOD process_sales_order.
  validate_order_data( is_order ).
  DATA(ls_pricing) = mo_pricing_service->calculate( is_order ).
  mo_order_repository->save( is_order = is_order is_pricing = ls_pricing ).
  mo_notifier->send_confirmation( is_order-order_id ).
ENDMETHOD.
```

## Configuration & Thresholds

This check can be fine-tuned directly in the ATC Check Variant Editor (`CHKV`) in Eclipse ADT:

| Parameter Name | Data Type | Default Value | Description & Guidance |
|---|---|:---:|---|
| `MAX_STATEMENTS` | `Integer` | <code>5</code> | Maximum executable ABAP statements allowed in regular method bodies |
| `MAX_CTOR_STATEMENTS` | `Integer` | <code>10</code> | Maximum statements allowed in CONSTRUCTOR methods (guards against heavy setup logic) |

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC MAX_METHOD_LEN

" SAP CI_ prefix format:
... "#EC CI_MAX_METHOD_LEN
```

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_MAX_METHOD_LEN`
* **Implementation File:** [zcl_skylint_max_method_len.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_max_method_len.clas.abap)
