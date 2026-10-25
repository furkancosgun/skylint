---
title: "Avoid Catching Generic CX_ROOT (Catch Specific Exceptions)"
description: "Eliminate black hole exception handling in SAP ABAP by catching specific domain exceptions instead of generic CX_ROOT."
keywords: "CATCH CX_ROOT ABAP, Black Hole Exception SAP, Clean ABAP Exception Handling"
category: "security"
ruleId: "no-catch-root"
---

# Avoid Catching Generic CX_ROOT (Catch Specific Exceptions)

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Security & Robustness" />
  <Badge type="danger" text="#EC NO_CATCH_ROOT" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Catch specific exceptions instead of generic cx_root.

> **ATC Finding Message:** `Avoid generic CATCH cx_root; catch specific exception classes instead`

## Rationale

Catching the root exception class `CX_ROOT` indiscriminately traps all exceptions, including catastrophic system resource exhaustion (`CX_SY_RESOURCE_FAILURE`), database disconnections, and critical assertion failures. Catching `CX_ROOT` without re-raising creates the "Black Hole Exception Antipattern", masking fatal bugs and allowing corrupted processes to continue running.

**Best Practice:** Always catch specific, expected exception classes (`CATCH zcx_order_not_found zcx_pricing_failed`).

### Non-Compliant

```abap
" Anti-pattern: Swallows fatal database disconnection and memory errors silently
TRY.
    process_order( ).
  CATCH cx_root.
    " Swallowed! Program continues with corrupt state.
ENDTRY.
```

### Compliant

```abap
" Clean ABAP: Catch specific anticipated domain exceptions only
TRY.
    process_order( ).
  CATCH zcx_invalid_order_status INTO DATA(lx_status).
    mo_logger->warn( lx_status->get_text( ) ).
  CATCH zcx_credit_limit_exceeded INTO DATA(lx_credit).
    mo_order_queue->hold( is_order ).
ENDTRY.
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC NO_CATCH_ROOT

" SAP CI_ prefix format:
... "#EC CI_NO_CATCH_ROOT
```


## Related Rules

* [Prefer Class-Based Exceptions over Classic EXCEPTIONS](/rules/pref-class-exc) — <code>#EC PREF_CLASS_EXC</code>
* [Avoid Raising System Exceptions Directly (CX_SY_*)](/rules/no-raise-cx-sy) — <code>#EC NO_RAISE_CX_SY</code>
* [Avoid Deeply Nested TRY ... CATCH Blocks](/rules/no-nested-try) — <code>#EC NO_NESTED_TRY</code>

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_NO_CATCH_ROOT`
* **Implementation File:** [zcl_skylint_no_catch_root.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_no_catch_root.clas.abap)
