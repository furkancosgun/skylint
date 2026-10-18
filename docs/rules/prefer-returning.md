# Prefer Functional RETURNING Parameters

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="danger" text="Finding: PREFER_RET" />
</div>

## Overview

Prefer RETURNING over single EXPORTING.

> **ATC Finding Message:** `Prefer functional RETURNING parameter over single EXPORTING parameter`

## Rationale

Methods with a `RETURNING` parameter can be used directly within expressions, assignments, and assertions. Prefer `RETURNING` over a single `EXPORTING` parameter.

### Non-Compliant

```abap
METHODS calculate
  EXPORTING ev_result TYPE i.
```

### Compliant

```abap
METHODS calculate
  RETURNING VALUE(rv_result) TYPE i.
```

## Transformation

```diff
- METHODS calculate
-   EXPORTING ev_result TYPE i.
+ METHODS calculate
+   RETURNING VALUE(rv_result) TYPE i.
```

## CLI & CI/CD Configuration

```yaml
checks:
  prefer-returning:
    enabled: true
    severity: warning
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
* **Finding Code:** `PREFER_RET`
* **Implementation File:** [zcl_skylint_pref_returning.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_pref_returning.clas.abap)
