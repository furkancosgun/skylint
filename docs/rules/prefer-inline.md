# Prefer Modern Inline Declarations in ABAP 7.40+

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="danger" text="Finding: PREF_INL" />
</div>

## Overview

Prefer Inline Declarations.

> **ATC Finding Message:** `Prefer inline declaration over separate DATA and assignment`

## Rationale

In versions supporting inline declarations, declaring variables at the point of first use reduces variable lifetime scope and removes top-of-method variable clutter.

## Transformation

```diff
- DATA lv_count TYPE i.
- lv_count = 10.
+ DATA(lv_count) = 10.
```

### ✕ Non-Compliant

```abap
DATA lv_count TYPE i.
lv_count = 10.
```

### ✓ Compliant

```abap
DATA(lv_count) = 10.
```

## CLI & CI/CD Configuration

```yaml
checks:
  prefer-inline:
    enabled: true
    severity: warning
```

## Suppression

To suppress findings for this rule, append the pseudo-comment or pragma to the statement:

```abap
" Using pseudo-comment:
... "#EC PREFER_INLINE
" Or with SAP CI_ prefix:
... "#EC CI_PREFER_INLINE

" Using pragma:
... ##PREFER_INLINE.
" Or with SAP CI_ prefix:
... ##CI_PREFER_INLINE.
```

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_PREF_INLINE`
* **Finding Code:** `PREF_INL`
* **Implementation File:** [zcl_skylint_pref_inline.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_pref_inline.clas.abap)
