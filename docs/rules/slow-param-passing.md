# Avoid Unnecessary Pass-by-Value for Large Tables

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="tip" text="Performance & Database" />
  <Badge type="danger" text="Finding: SLOW_PASS" />
</div>

## Overview

Slow Parameter Passing.

> **ATC Finding Message:** `Avoid pass-by-value for importing method parameters`

## Rationale

Passing large internal tables by value creates an in-memory deep copy on every method invocation. Use pass-by-reference (`REFERENCE(it_data)`) or read-only references.

## Transformation

```diff
- METHODS process IMPORTING VALUE(iv_text) TYPE string.
+ METHODS process IMPORTING iv_text TYPE string.
```

### ✕ Non-Compliant

```abap
METHODS process IMPORTING VALUE(iv_text) TYPE string.
```

### ✓ Compliant

```abap
METHODS process IMPORTING iv_text TYPE string.
```

## CLI & CI/CD Configuration

```yaml
checks:
  slow-param-passing:
    enabled: true
    severity: warning
```

## Suppression

To suppress findings for this rule, append the pseudo-comment or pragma to the statement:

```abap
" Using pseudo-comment:
... "#EC SLOW_PARAM
" Or with SAP CI_ prefix:
... "#EC CI_SLOW_PARAM

" Using pragma:
... ##SLOW_PARAM.
" Or with SAP CI_ prefix:
... ##CI_SLOW_PARAM.
```

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_SLOW_PARAM_PASS`
* **Finding Code:** `SLOW_PASS`
* **Implementation File:** [zcl_skylint_slow_param_pass.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_slow_param_pass.clas.abap)
