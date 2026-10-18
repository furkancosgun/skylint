# Avoid Catching Generic CX_ROOT

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="tip" text="Security & Robustness" />
  <Badge type="danger" text="Finding: CATCH_ROOT" />
</div>

## Overview

Catch specific exceptions instead of generic cx_root.

> **ATC Finding Message:** `Avoid generic CATCH cx_root; catch specific exception classes instead`

## Rationale

Catching `cx_root` indiscriminately swallows system runtime errors, resource exhaustion errors, and programming bugs, masking critical defects from developers.

### Non-Compliant

```abap
TRY.
    process_order( ).
  CATCH cx_root.
    " Indiscriminately catches all exceptions, masking unexpected bugs
ENDTRY.
```

### Compliant

```abap
TRY.
    process_order( ).
  CATCH cx_order_failed INTO DATA(lx_order).
    logger->record( lx_order ).
ENDTRY.
```

## Transformation

```diff
- TRY.
-     process_order( ).
-   CATCH cx_root.
-     " Indiscriminately catches all exceptions, masking unexpected bugs
- ENDTRY.
+ TRY.
+     process_order( ).
+   CATCH cx_order_failed INTO DATA(lx_order).
+     logger->record( lx_order ).
+ ENDTRY.
```

## CLI & CI/CD Configuration

```yaml
checks:
  no-catch-cx-root:
    enabled: true
    severity: warning
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC CATCH_ROOT

" SAP CI_ prefix format:
... "#EC CI_CATCH_ROOT
```

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_NO_CATCH_ROOT`
* **Finding Code:** `CATCH_ROOT`
* **Implementation File:** [zcl_skylint_no_catch_root.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_no_catch_root.clas.abap)
