---
description: "Do not mix RETURNING with EXPORTING or CHANGING"
---

# Do Not Mix RETURNING with EXPORTING or CHANGING

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="tip" text="Anti-Patterns & Bad Practices" />
  <Badge type="danger" text="#EC NO_MIX_RETURNING" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Do not mix RETURNING with EXPORTING or CHANGING.

> **ATC Finding Message:** `Do not mix RETURNING with EXPORTING or CHANGING parameters in a single method`

## Rationale

Clean ABAP methods should either be pure functional (RETURNING a single result) or procedures (using EXPORTING/CHANGING). Mixing both in the same signature creates confusing APIs.

### Non-Compliant

```abap
METHODS get_data
  EXPORTING ev_val TYPE i
  RETURNING VALUE(rv_res) TYPE string.
```

### Compliant

```abap
METHODS get_data
  RETURNING VALUE(rv_res) TYPE string.
```

## Transformation

```diff
- METHODS get_data
-   EXPORTING ev_val TYPE i
-   RETURNING VALUE(rv_res) TYPE string.
+ METHODS get_data
+   RETURNING VALUE(rv_res) TYPE string.
```

## CLI & CI/CD Configuration

```yaml
checks:
  mix-returning:
    enabled: true
    severity: warning
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC NO_MIX_RETURNING

" SAP CI_ prefix format:
... "#EC CI_NO_MIX_RETURNING
```

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_NO_MIX_RETURNING`
* **Implementation File:** [zcl_skylint_no_mix_returning.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_no_mix_returning.clas.abap)
