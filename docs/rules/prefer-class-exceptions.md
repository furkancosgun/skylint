---
description: "Prefer Class-Based Exceptions over Classic EXCEPTIONS"
---

# Prefer Class-Based Exceptions over Classic EXCEPTIONS

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="danger" text="#EC CLASS_EXC" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Prefer Class-Based Exceptions over Classic EXCEPTIONS.

> **ATC Finding Message:** `Prefer class-based exceptions (RAISING) over classic EXCEPTIONS`

## Rationale

Classic exceptions report failure through sy-subrc and cannot carry a message object, stack trace, or context data. They are easy to ignore and do not propagate cleanly through call stacks. Use CX_ROOT subclasses with RAISING and CATCH so errors are explicit, typed, and carry useful information.

### Non-Compliant

```abap
METHODS execute
  EXCEPTIONS not_found failed.
```

### Compliant

```abap
METHODS execute
  RAISING cx_not_found cx_failed.
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC CLASS_EXC

" SAP CI_ prefix format:
... "#EC CI_CLASS_EXC
```

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_PREF_CLASS_EXC`
* **Implementation File:** [zcl_skylint_pref_class_exc.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_pref_class_exc.clas.abap)
