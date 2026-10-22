---
description: "Avoid empty control blocks (IF, CASE, LOOP, TRY, etc.)"
---

# Avoid Empty Control Blocks

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="tip" text="Anti-Patterns & Bad Practices" />
  <Badge type="danger" text="#EC EMPTY_BLOCK" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Avoid empty control blocks (IF, CASE, LOOP, TRY, etc.).

> **ATC Finding Messages:**
> - `Empty control block detected; remove redundant control statement`
> - `TRY block without CATCH is superfluous`

## Rationale

Empty blocks (such as `IF ... ELSEIF ... ENDIF` with no executable statements) confuse readers and usually represent unfinished business logic or forgotten debug code.

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

| Parameter Name | Data Type | Default Value |
|---|---|:---:|
| `CHECK_IF` | `Boolean` | <code>true</code> |
| `CHECK_LOOP` | `Boolean` | <code>true</code> |
| `CHECK_CASE` | `Boolean` | <code>true</code> |
| `CHECK_TRY` | `Boolean` | <code>true</code> |
| `CHECK_CATCH` | `Boolean` | <code>true</code> |
| `CHECK_TRY_NO_CATCH` | `Boolean` | <code>true</code> |
| `CHECK_DO` | `Boolean` | <code>true</code> |
| `CHECK_WHILE` | `Boolean` | <code>true</code> |

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
* **Implementation File:** [zcl_skylint_no_empty_block.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_no_empty_block.clas.abap)
