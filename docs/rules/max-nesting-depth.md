# Limit Control Flow Nesting Depth

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="tip" text="Metrics & Complexity Limits" />
  <Badge type="danger" text="Finding: NESTING_DP" />
</div>

## Overview

Nesting Depth Limit (excessive control block nesting).

> **ATC Finding Message:** `Control block nesting depth exceeds`

## Rationale

Deeply nested blocks (`IF`, `LOOP`, `TRY`, `CASE`) cause cognitive overload ("arrow antipattern"). Flatten nested code using early exits (`RETURN`), guard clauses, and extracted methods.

### Non-Compliant

```abap
IF cond1.
  IF cond2.
    IF cond3.
      IF cond4.
        execute( ).
      ENDIF.
    ENDIF.
  ENDIF.
ENDIF.
```

### Compliant

```abap
IF NOT cond1 OR NOT cond2 OR NOT cond3 OR NOT cond4.
  RETURN.
ENDIF.
execute( ).
```

## Transformation

```diff
- IF cond1.
-   IF cond2.
-     IF cond3.
-       IF cond4.
-         execute( ).
-       ENDIF.
-     ENDIF.
-   ENDIF.
- ENDIF.
+ IF NOT cond1 OR NOT cond2 OR NOT cond3 OR NOT cond4.
+   RETURN.
+ ENDIF.
+ execute( ).
```

## Configuration & Thresholds

This check can be fine-tuned directly in the ATC Check Variant Editor (`CHKV`) in Eclipse ADT:

| Parameter Name | Data Type | Default Value |
|---|---|:---:|
| `MAX_DEPTH` | `Integer / String` | `3` |

## CLI & CI/CD Configuration

```yaml
checks:
  max-nesting-depth:
    enabled: true
    severity: warning
    attributes:
      maxDepth: 3
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC NESTING

" SAP CI_ prefix format:
... "#EC CI_NESTING
```

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_MAX_NESTING`
* **Finding Code:** `NESTING_DP`
* **Implementation File:** [zcl_skylint_max_nesting.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_max_nesting.clas.abap)
