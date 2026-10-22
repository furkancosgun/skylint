---
description: "Slow Parameter Passing"
---

# Avoid Unnecessary Pass-by-Value for Large Tables

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Performance & Database" />
  <Badge type="danger" text="#EC SLOW_PARAM" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Slow Parameter Passing.

> **ATC Finding Message:** `Avoid pass-by-value for importing method parameters`

## Rationale

Passing a large internal table by VALUE makes a deep copy before the method body starts, costing memory and CPU on every call. ABAP already protects reference parameters when the method only reads them. Use pass-by-reference for large tables and reserve VALUE for small scalars that need a local copy.

### Non-Compliant

```abap
METHODS process
  IMPORTING VALUE(it_items) TYPE ty_items.
```

### Compliant

```abap
METHODS process
  IMPORTING it_items TYPE ty_items.
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC SLOW_PARAM

" SAP CI_ prefix format:
... "#EC CI_SLOW_PARAM
```

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_PREF_PASS_BY_REF`
* **Implementation File:** [zcl_skylint_pref_pass_by_ref.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_pref_pass_by_ref.clas.abap)
