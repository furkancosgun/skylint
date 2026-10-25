---
title: "Do Not Ignore Return Value of Functional Methods"
description: "Do Not Ignore Return Value of Functional Methods - Clean ABAP guidelines, modern SAP syntax rules, and automated ATC code inspection for SAP S/4HANA and ABAP Cloud."
keywords: "Clean ABAP, SAP ATC Check, ABAP Cloud, S/4HANA Readiness, no-ignored-return, anti-patterns"
---

# Do Not Ignore Return Value of Functional Methods

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Anti-Patterns & Bad Practices" />
  <Badge type="danger" text="#EC NO_IGNORED_RETURN" />
  <Badge type="warning" text="Local Only" />
</div>

## Overview

Disallow ignoring the return value of functional methods.

> **ATC Finding Message:** `Do not ignore return value of functional method; assign or use result`

## Rationale

A functional method is called for its RETURNING value, so discarding that value usually means the call is pointless or the method hides side effects. If the method intentionally has side effects, it should not return a value. Assign or consume the result, or refactor the method into a command.

### Non-Compliant

```abap
lo_calculator->get_total( ).
```

### Compliant

```abap
lv_total = lo_calculator->get_total( ).
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC NO_IGNORED_RETURN

" SAP CI_ prefix format:
... "#EC CI_NO_IGNORED_RETURN
```

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_NO_IGNORED_RETURN`
* **Implementation File:** [zcl_skylint_no_ignored_return.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_no_ignored_return.clas.abap)
