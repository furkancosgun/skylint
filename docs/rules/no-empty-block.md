# Avoid Empty Control Blocks

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="tip" text="Anti-Patterns & Bad Practices" />
  <Badge type="danger" text="Finding: EMPTYCTRL" />
</div>

## Overview

Avoid empty control blocks (IF, CASE, LOOP, TRY, etc.).

> **ATC Finding Message:** `Empty control block detected; remove redundant control statement`

## Rationale

Empty blocks (such as `IF ... ELSEIF ... ENDIF` with no executable statements) confuse readers and usually represent unfinished business logic or forgotten debug code.

## Transformation

```diff
- IF lv_condition = abap_true.
-   " Empty block
- ELSE.
-   process( ).
- ENDIF.
+ IF lv_condition = abap_false.
+   process( ).
+ ENDIF.
```

### Non-Compliant

```abap
IF lv_condition = abap_true.
  " Empty block
ELSE.
  process( ).
ENDIF.
```

### Compliant

```abap
IF lv_condition = abap_false.
  process( ).
ENDIF.
```

## Configuration & Thresholds

This check can be fine-tuned directly in the ATC Check Variant Editor (`CHKV`) in Eclipse ADT:

| Parameter Name | Data Type | Default Value | Description |
|---|---|:---:|---|
| `CHECK_IF` | `Boolean` | `true` | Configurable attribute for no-empty-block |
| `CHECK_LOOP` | `Boolean` | `true` | Configurable attribute for no-empty-block |
| `CHECK_CASE` | `Boolean` | `true` | Configurable attribute for no-empty-block |
| `CHECK_TRY` | `Boolean` | `true` | Configurable attribute for no-empty-block |
| `CHECK_CATCH` | `Boolean` | `true` | Configurable attribute for no-empty-block |
| `CHECK_TRY_NO_CATCH` | `Boolean` | `true` | Configurable attribute for no-empty-block |
| `CHECK_DO` | `Boolean` | `true` | Configurable attribute for no-empty-block |
| `CHECK_WHILE` | `Boolean` | `true` | Configurable attribute for no-empty-block |

## CLI & CI/CD Configuration

```yaml
checks:
  no-empty-block:
    enabled: true
    severity: warning
    attributes:
      checkIf: true
      checkLoop: true
      checkCase: true
      checkTry: true
      checkCatch: true
      checkTryNoCatch: true
      checkDo: true
      checkWhile: true
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC EMPTY_BLOCK

" SAP CI_ prefix format:
... "#EC CI_EMPTY_BLOCK
```

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_NO_EMPTY_BLOCK`
* **Finding Code:** `EMPTYCTRL`
* **Implementation File:** [zcl_skylint_no_empty_block.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_no_empty_block.clas.abap)
