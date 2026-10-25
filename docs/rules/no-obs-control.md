---
description: "Obsolete Control Flow and Procedural Statements"
---

# Avoid Obsolete Control Flow and Procedural Forms

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Anti-Patterns & Bad Practices" />
  <Badge type="danger" text="#EC OBSOLETE_CTRL" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Obsolete Control Flow and Procedural Statements.

> **ATC Finding Message:** `Avoid obsolete control flow (FORM, AT NEW, BREAK, DEFINE, etc.)`

## Rationale

Subroutines (FORM / PERFORM), macro definitions (DEFINE), hardcoded break points (BREAK-POINT / BREAK), control break statements (AT NEW, AT END, ON CHANGE OF, SUM), and SET EXTENDED CHECK belong to legacy procedural programming. They lack proper scope isolation, cause unpredictable side effects, and are completely prohibited in modern ABAP Cloud. Encapsulate all logic within methods, modern LOOP GROUP BY syntax, and unit tests.

### Non-Compliant

```abap
PERFORM calculate_total USING lv_subtotal.
AT NEW order_id.
  SUM.
ENDAT.
```

### Compliant

```abap
calculate_total( iv_subtotal = lv_subtotal ).
LOOP AT lt_orders INTO DATA(ls_order) GROUP BY ls_order-order_id ...
```

## Configuration & Thresholds

This check can be fine-tuned directly in the ATC Check Variant Editor (`CHKV`) in Eclipse ADT:

| Parameter Name | Data Type | Default Value |
|---|---|:---:|
| `CHECK_FORM` | `Boolean` | <code>true</code> |
| `CHECK_LOOP_CTL` | `Boolean` | <code>true</code> |
| `CHECK_BREAK` | `Boolean` | <code>true</code> |
| `CHECK_DEFINE` | `Boolean` | <code>true</code> |
| `CHECK_TEST_SEAMS` | `Boolean` | <code>true</code> |
| `CHECK_CATCH_SYSTEM` | `Boolean` | <code>true</code> |
| `CHECK_SET_EXT_CHECK` | `Boolean` | <code>true</code> |
| `CHECK_SELECT_NO_INTO` | `Boolean` | <code>true</code> |
| `CHECK_EXIT_SQL` | `Boolean` | <code>true</code> |
| `CHECK_SORT_BY_FS` | `Boolean` | <code>true</code> |

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC OBSOLETE_CTRL

" SAP CI_ prefix format:
... "#EC CI_OBSOLETE_CTRL
```

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_NO_OBS_CONTROL`
* **Implementation File:** [zcl_skylint_no_obs_control.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_no_obs_control.clas.abap)
