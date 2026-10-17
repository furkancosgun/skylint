# Require Fully Typed Variables and Parameters

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="danger" text="Finding: FULLYTYPED" />
</div>

## Overview

Enforce fully typed constant declarations.

> **ATC Finding Message:** `Constant declaration should explicitly specify TYPE`

## Rationale

Generic types (`ANY`, `DATA`, `TABLE`) bypass compiler type checking and hide runtime type mismatches. Always declare concrete, specific types unless writing truly generic frameworks.

## Transformation

```diff
- CONSTANTS c_status VALUE 'A'. " TYPE is omitted; implicitly typed as c length 1
+ CONSTANTS c_status TYPE c LENGTH 1 VALUE 'A'.
```

### ✕ Non-Compliant

```abap
CONSTANTS c_status VALUE 'A'. " TYPE is omitted; implicitly typed as c length 1
```

### ✓ Compliant

```abap
CONSTANTS c_status TYPE c LENGTH 1 VALUE 'A'.
```

## CLI & CI/CD Configuration

```yaml
checks:
  require-fully-typed:
    enabled: true
    severity: warning
```

## Suppression

To suppress findings for this rule, append the pseudo-comment or pragma to the statement:

```abap
" Using pseudo-comment:
... "#EC FULL_TYPED
" Or with SAP CI_ prefix:
... "#EC CI_FULL_TYPED

" Using pragma:
... ##FULL_TYPED.
" Or with SAP CI_ prefix:
... ##CI_FULL_TYPED.
```

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_PREF_FULL_TYPED`
* **Finding Code:** `FULLYTYPED`
* **Implementation File:** [zcl_skylint_pref_full_typed.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_pref_full_typed.clas.abap)
