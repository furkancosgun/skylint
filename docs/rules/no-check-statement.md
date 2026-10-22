---
description: "Avoid CHECK statements; prefer IF with RETURN or CONTINUE"
---

# Avoid CHECK Statements

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Anti-Patterns & Bad Practices" />
  <Badge type="warning" text="QuickFix Ready" />
  <Badge type="danger" text="#EC CHECK_STMT" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Avoid CHECK statements; prefer IF with RETURN or CONTINUE.

> **ATC Finding Messages:**
> - `Avoid CHECK inside loop; use IF ... CONTINUE instead`
> - `Avoid CHECK outside loop; use IF ... RETURN instead`

## Rationale

CHECK behaves like CONTINUE inside a loop but like RETURN outside a loop, so moving the statement between contexts silently changes control flow. That dual meaning makes refactoring and reviews hazardous. Replace it with an explicit IF ... CONTINUE or IF ... RETURN that states the intended behavior.

### Non-Compliant

```abap
LOOP AT lt_orders INTO ls_order.
  CHECK ls_order-status = 'OPEN'.
  process_order( ls_order ).
ENDLOOP.
```

### Compliant

```abap
LOOP AT lt_orders INTO ls_order.
  IF ls_order-status <> 'OPEN'.
    CONTINUE.
  ENDIF.
  process_order( ls_order ).
ENDLOOP.
```

## Automated QuickFix

This rule provides an **automated QuickFix** directly in Eclipse ABAP Development Tools (ADT):
1. Position the cursor on the flagged statement.
2. Press <kbd>Ctrl</kbd> + <kbd>1</kbd> (Quick Assist).
3. Select the automated refactoring to apply the clean syntax immediately.

## Configuration & Thresholds

This check can be fine-tuned directly in the ATC Check Variant Editor (`CHKV`) in Eclipse ADT:

| Parameter Name | Data Type | Default Value |
|---|---|:---:|
| `CHECK_IN_LOOP` | `Boolean` | <code>true</code> |
| `CHECK_OUTSIDE_LOOP` | `Boolean` | <code>true</code> |

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC CHECK_STMT

" SAP CI_ prefix format:
... "#EC CI_CHECK_STMT
```

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_NO_CHECK_STMT`
* **Implementation File:** [zcl_skylint_no_check_stmt.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_no_check_stmt.clas.abap)
