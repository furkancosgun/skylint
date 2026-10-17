# Limit Method Length (Statements)

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="tip" text="Metrics & Complexity Limits" />
  <Badge type="danger" text="Finding: METHOD_LEN" />
</div>

## Overview

Method Length Limit (excessive statement count).

> **ATC Finding Message:** `Method length exceeds maximum allowed statement limit`

## Rationale

Long methods violate the Single Responsibility Principle, accumulate side effects, and are notoriously difficult to unit test. Split large methods into small, focused sub-methods.

## Transformation

```diff
- " Large method exceeding configured statement threshold (> 50 statements)
- METHOD execute.
-   " 60+ statements in a single procedure...
- ENDMETHOD.
+ " Split into smaller, single-responsibility helper methods
+ METHOD execute.
+   prepare_data( ).
+   process_records( ).
+   finalize_result( ).
+ ENDMETHOD.
```

### ✕ Non-Compliant

```abap
" Large method exceeding configured statement threshold (> 50 statements)
METHOD execute.
  " 60+ statements in a single procedure...
ENDMETHOD.
```

### ✓ Compliant

```abap
" Split into smaller, single-responsibility helper methods
METHOD execute.
  prepare_data( ).
  process_records( ).
  finalize_result( ).
ENDMETHOD.
```

## Configuration & Thresholds

This check can be fine-tuned directly in the ATC Check Variant Editor (`CHKV`) in Eclipse ADT:

| Parameter Name | Data Type | Default Value | Description |
|---|---|:---:|---|
| `MAX_STATEMENTS` | `Integer / String` | `5` | Configurable attribute for max-method-length |

## CLI & CI/CD Configuration

```yaml
checks:
  max-method-length:
    enabled: true
    severity: warning
    attributes:
      MAX_STATEMENTS: 5
```

## Suppression

To suppress findings for this rule, append the pseudo-comment or pragma to the statement:

```abap
" Using pseudo-comment:
... "#EC METHOD_LEN
" Or with SAP CI_ prefix:
... "#EC CI_METHOD_LEN

" Using pragma:
... ##METHOD_LEN.
" Or with SAP CI_ prefix:
... ##CI_METHOD_LEN.
```

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_MAX_METHOD_LEN`
* **Finding Code:** `METHOD_LEN`
* **Implementation File:** [zcl_skylint_max_method_len.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_max_method_len.clas.abap)
