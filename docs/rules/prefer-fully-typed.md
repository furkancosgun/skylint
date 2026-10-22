---
description: "Enforce fully typed constant declarations"
---

# Require Fully Typed Variables and Parameters

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="danger" text="#EC FULL_TYPED" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Enforce fully typed constant declarations.

> **ATC Finding Message:** `Constant declaration should explicitly specify TYPE`

## Rationale

Generic types (`ANY`, `DATA`, `TABLE`) bypass compiler type checking and hide runtime type mismatches. Always declare concrete, specific types unless writing truly generic frameworks.

### Non-Compliant

```abap
CONSTANTS c_status VALUE 'A'. " TYPE is omitted; implicitly typed as c length 1
```

### Compliant

```abap
CONSTANTS c_status TYPE c LENGTH 1 VALUE 'A'.
```

## Transformation

```diff
- CONSTANTS c_status VALUE 'A'. " TYPE is omitted; implicitly typed as c length 1
+ CONSTANTS c_status TYPE c LENGTH 1 VALUE 'A'.
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC FULL_TYPED

" SAP CI_ prefix format:
... "#EC CI_FULL_TYPED
```

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_PREF_FULL_TYPED`
* **Implementation File:** [zcl_skylint_pref_full_typed.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_pref_full_typed.clas.abap)
