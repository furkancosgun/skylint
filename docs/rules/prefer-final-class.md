---
description: "Prefer FINAL classes and methods by default"
---

# Design for Inheritance or Prohibit It (FINAL)

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="warning" text="⚡ QuickFix Ready" />
  <Badge type="danger" text="#EC FINAL_CLS" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Prefer FINAL classes and methods by default.

> **ATC Finding Messages:**
> - `Classes should be marked FINAL by default unless designed for inheritance`
> - `Declare method as FINAL if it is not intended to be redefined`

## Rationale

Classes not explicitly designed and documented for inheritance should be declared `FINAL`. This prevents subclassing that relies on fragile base-class implementation details.

### Non-Compliant

```abap
CLASS cl_customer_service DEFINITION PUBLIC CREATE PUBLIC.
  " Class not intended for inheritance
ENDCLASS.
```

### Compliant

```abap
CLASS cl_customer_service DEFINITION PUBLIC FINAL CREATE PUBLIC.
ENDCLASS.
```

## Transformation

```diff
- CLASS cl_customer_service DEFINITION PUBLIC CREATE PUBLIC.
-   " Class not intended for inheritance
- ENDCLASS.
+ CLASS cl_customer_service DEFINITION PUBLIC FINAL CREATE PUBLIC.
+ ENDCLASS.
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
| `CHECK_CLASSES` | `Boolean` | <code>true</code> |
| `CHECK_METHODS` | `Boolean` | <code>true</code> |

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC FINAL_CLS

" SAP CI_ prefix format:
... "#EC CI_FINAL_CLS
```

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_PREF_FINAL_CLS`
* **Implementation File:** [zcl_skylint_pref_final_cls.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_pref_final_cls.clas.abap)
