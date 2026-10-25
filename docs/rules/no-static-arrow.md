---
title: "Avoid Calling Static Methods via Instance References (->)"
description: "Avoid Calling Static Methods via Instance References (->) - Clean ABAP guidelines, modern SAP syntax rules, and automated ATC code inspection for SAP S/4HANA and ABAP Cloud."
keywords: "Clean ABAP, SAP ATC Check, ABAP Cloud, S/4HANA Readiness, no-static-arrow, anti-patterns"
---

# Avoid Calling Static Methods via Instance References (->)

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Anti-Patterns & Bad Practices" />
  <Badge type="warning" text="QuickFix Ready" />
  <Badge type="danger" text="#EC NO_STATIC_ARROW" />
  <Badge type="warning" text="Local Only" />
</div>

## Overview

Avoid calling static methods via instance arrow (->).

> **ATC Finding Message:** `Call static method using => instead of ->`

## Rationale

Calling a static method through an instance reference uses the instance arrow and suggests polymorphic dispatch that is not happening. It also creates an unnecessary dependency on a live object. Use the class name with => so readers immediately see that the method is static and cannot be overridden.

### Non-Compliant

```abap
DATA lo_helper TYPE REF TO cl_helper.
lo_helper->format_date( lv_date ).
```

### Compliant

```abap
cl_helper=>format_date( lv_date ).
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
... "#EC NO_STATIC_ARROW

" SAP CI_ prefix format:
... "#EC CI_NO_STATIC_ARROW
```

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_NO_STATIC_ARROW`
* **Implementation File:** [zcl_skylint_no_static_arrow.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_no_static_arrow.clas.abap)
