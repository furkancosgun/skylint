---
description: "Avoid calling static methods via instance arrow (->)"
---

# Avoid Calling Static Methods via Instance References (->)

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="tip" text="Anti-Patterns & Bad Practices" />
  <Badge type="warning" text="⚡ QuickFix Ready" />
  <Badge type="danger" text="#EC STATIC_ARROW" />
  <Badge type="warning" text="Local Only" />
</div>

## Overview

Avoid calling static methods via instance arrow (->).

> **ATC Finding Message:** `Call static method using => instead of ->`

## Rationale

Calling a static method via an object reference arrow `lo_instance->static_method( )` gives the false impression that polymorphic instance dispatch is occurring. Use `cl_class=>static_method( )`.

### Non-Compliant

```abap
DATA lo_instance TYPE REF TO cl_helper.
lo_instance->static_method( ).
```

### Compliant

```abap
cl_helper=>static_method( ).
```

## Automated QuickFix

This rule provides an **automated QuickFix** directly in Eclipse ABAP Development Tools (ADT):
1. Position the cursor on the flagged statement.
2. Press <kbd>Ctrl</kbd> + <kbd>1</kbd> (Quick Assist).
3. Select the automated refactoring to apply the clean syntax immediately.

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC STATIC_ARROW

" SAP CI_ prefix format:
... "#EC CI_STATIC_ARROW
```

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_NO_STATIC_ARROW`
* **Implementation File:** [zcl_skylint_no_static_arrow.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_no_static_arrow.clas.abap)
