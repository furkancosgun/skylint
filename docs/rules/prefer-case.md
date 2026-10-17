# Prefer CASE over Multiple IF / ELSEIF on the Same Variable

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="danger" text="Finding: USE_CASE" />
</div>

## Overview

Change IF to CASE when checking the same variable against multiple values.

> **ATC Finding Message:** `Multiple ELSEIF branches check the same variable; use CASE instead`

## Rationale

When branching on multiple values of a single variable, `CASE ... WHEN` is more readable, structured, and performant than a chain of `ELSEIF` statements.

## Transformation

```diff
- IF lv_type = 'A'.
-   process_a( ).
- ELSEIF lv_type = 'B'.
-   process_b( ).
- ELSEIF lv_type = 'C'.
-   process_c( ).
- ENDIF.
+ CASE lv_type.
+   WHEN 'A'.
+     process_a( ).
+   WHEN 'B'.
+     process_b( ).
+   WHEN 'C'.
+     process_c( ).
+ ENDCASE.
```

### Non-Compliant

```abap
IF lv_type = 'A'.
  process_a( ).
ELSEIF lv_type = 'B'.
  process_b( ).
ELSEIF lv_type = 'C'.
  process_c( ).
ENDIF.
```

### Compliant

```abap
CASE lv_type.
  WHEN 'A'.
    process_a( ).
  WHEN 'B'.
    process_b( ).
  WHEN 'C'.
    process_c( ).
ENDCASE.
```

## Configuration & Thresholds

This check can be fine-tuned directly in the ATC Check Variant Editor (`CHKV`) in Eclipse ADT:

| Parameter Name | Data Type | Default Value | Description |
|---|---|:---:|---|
| `MIN_BRANCHES` | `Integer / String` | `3` | Configurable attribute for prefer-case |

## CLI & CI/CD Configuration

```yaml
checks:
  prefer-case:
    enabled: true
    severity: warning
    attributes:
      minBranches: 3
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC PREF_CASE

" SAP CI_ prefix format:
... "#EC CI_PREF_CASE
```

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_PREF_CASE`
* **Finding Code:** `USE_CASE`
* **Implementation File:** [zcl_skylint_pref_case.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_pref_case.clas.abap)
