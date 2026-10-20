---
description: "Method Length Limit (excessive statement count)"
---

# Limit Method Length (Statements)

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="tip" text="Metrics & Complexity Limits" />
  <Badge type="danger" text="#EC METHOD_LEN" />
</div>

## Overview

Method Length Limit (excessive statement count).

> **ATC Finding Message:** `Method length exceeds maximum allowed statement limit`

## Rationale

Long methods violate the Single Responsibility Principle, accumulate side effects, and are notoriously difficult to unit test. Split large methods into small, focused sub-methods.

### Non-Compliant

```abap
" Large method exceeding configured statement threshold (> 50 statements)
METHOD execute.
  " 60+ statements in a single procedure...
ENDMETHOD.
```

### Compliant

```abap
" Split into smaller, single-responsibility helper methods
METHOD execute.
  prepare_data( ).
  process_records( ).
  finalize_result( ).
ENDMETHOD.
```

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

## Configuration & Thresholds

This check can be fine-tuned directly in the ATC Check Variant Editor (`CHKV`) in Eclipse ADT:

| Parameter Name | Data Type | Default Value |
|---|---|:---:|
| `MAX_STATEMENTS` | `Integer / String` | <code>5</code> |

## CLI & CI/CD Configuration

```yaml
checks:
  max-method-length:
    enabled: true
    severity: warning
    attributes:
      maxStatements: 5
```

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
