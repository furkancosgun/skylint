# Avoid Deeply Nested TRY ... CATCH Blocks

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="danger" text="Finding: NESTED_TRY" />
</div>

## Overview

Avoid nested TRY blocks; extract inner error handling to helper methods.

> **ATC Finding Message:** `Avoid nested TRY blocks; extract to dedicated method`

## Rationale

Nesting `TRY` blocks inside other `TRY` blocks obfuscates error handling flow. Extract inner protected operations into distinct methods.

## Transformation

```diff
- TRY.
-     step1( ).
-     TRY.
-         step2( ).
-       CATCH cx_step2_err.
-         handle_step2( ).
-     ENDTRY.
-   CATCH cx_step1_err.
-     handle_step1( ).
- ENDTRY.
+ " Extract inner operations into focused helper methods
+ TRY.
+     step1( ).
+     execute_step2( ).
+   CATCH cx_step1_err.
+     handle_step1( ).
+ ENDTRY.
```

### ✕ Non-Compliant

```abap
TRY.
    step1( ).
    TRY.
        step2( ).
      CATCH cx_step2_err.
        handle_step2( ).
    ENDTRY.
  CATCH cx_step1_err.
    handle_step1( ).
ENDTRY.
```

### ✓ Compliant

```abap
" Extract inner operations into focused helper methods
TRY.
    step1( ).
    execute_step2( ).
  CATCH cx_step1_err.
    handle_step1( ).
ENDTRY.
```

## CLI & CI/CD Configuration

```yaml
checks:
  no-nested-try:
    enabled: true
    severity: warning
```

## Suppression

To suppress findings for this rule, append the pseudo-comment or pragma to the statement:

```abap
" Using pseudo-comment:
... "#EC NESTED_TRY
" Or with SAP CI_ prefix:
... "#EC CI_NESTED_TRY

" Using pragma:
... ##NESTED_TRY.
" Or with SAP CI_ prefix:
... ##CI_NESTED_TRY.
```

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_NO_NESTED_TRY`
* **Finding Code:** `NESTED_TRY`
* **Implementation File:** [zcl_skylint_no_nested_try.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_no_nested_try.clas.abap)
