---
description: "Prefer RETURNING over single EXPORTING"
---

# Prefer Functional RETURNING Parameters

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="danger" text="#EC RETURNING" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Prefer RETURNING over single EXPORTING.

> **ATC Finding Message:** `Prefer functional RETURNING parameter over single EXPORTING parameter`

## Rationale

A single EXPORTING parameter forces callers to declare a target and invoke the method as a statement. A RETURNING parameter makes the method usable directly in assignments, expressions, and assertions. Prefer RETURNING for value-producing methods and reserve EXPORTING for methods that genuinely return several outputs.

### Non-Compliant

```abap
METHODS get_total
  EXPORTING ev_total TYPE i.
```

### Compliant

```abap
METHODS get_total
  RETURNING VALUE(rv_total) TYPE i.
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC RETURNING

" SAP CI_ prefix format:
... "#EC CI_RETURNING
```

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_PREF_RETURNING`
* **Implementation File:** [zcl_skylint_pref_returning.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_pref_returning.clas.abap)
