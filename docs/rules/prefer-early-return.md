# Prefer Early Return to Reduce Nesting (Guard Clauses)

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="danger" text="Finding: GUARD_METH" />
</div>

## Overview

Prefer early exit (RETURN or CONTINUE) instead of nested IF blocks.

> **ATC Finding Message:** `Invert IF condition and use RETURN to reduce nesting in method`

## Rationale

Check preconditions and invalid states at the start of the method and return immediately. This eliminates deeply nested `IF ... ELSE` ladders.

## Transformation

```diff
- METHOD process_order.
-   IF is_valid( ).
-     " Entire method logic deeply nested
-     execute_order( ).
-   ENDIF.
- ENDMETHOD.
+ METHOD process_order.
+   IF NOT is_valid( ).
+     RETURN.
+   ENDIF.
+   execute_order( ).
+ ENDMETHOD.
```

### Non-Compliant

```abap
METHOD process_order.
  IF is_valid( ).
    " Entire method logic deeply nested
    execute_order( ).
  ENDIF.
ENDMETHOD.
```

### Compliant

```abap
METHOD process_order.
  IF NOT is_valid( ).
    RETURN.
  ENDIF.
  execute_order( ).
ENDMETHOD.
```

## Configuration & Thresholds

This check can be fine-tuned directly in the ATC Check Variant Editor (`CHKV`) in Eclipse ADT:

| Parameter Name | Data Type | Default Value | Description |
|---|---|:---:|---|
| `CHECK_METHOD_RETURN` | `Boolean` | `true` | Configurable attribute for prefer-early-return |
| `CHECK_LOOP_CONTINUE` | `Boolean` | `true` | Configurable attribute for prefer-early-return |

## CLI & CI/CD Configuration

```yaml
checks:
  prefer-early-return:
    enabled: true
    severity: warning
    attributes:
      checkMethodReturn: true
      checkLoopContinue: true
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC EARLY_RETURN

" SAP CI_ prefix format:
... "#EC CI_EARLY_RETURN
```

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_PREF_EARLY_RET`
* **Finding Code:** `GUARD_METH`
* **Implementation File:** [zcl_skylint_pref_early_ret.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_pref_early_ret.clas.abap)
