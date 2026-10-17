# Avoid Modifying System Fields (sy-*)

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="tip" text="Anti-Patterns & Bad Practices" />
  <Badge type="danger" text="Finding: SYS_VAR_MD" />
</div>

## Overview

Avoid sy-* System Variable Modification.

> **ATC Finding Message:** `Avoid modifying system fields (sy-*); system variables are read-only`

## Rationale

System fields like `sy-subrc`, `sy-tabix`, and `sy-index` are managed exclusively by the ABAP runtime. Writing to them manually undermines system integrity and masks actual execution results.

## Transformation

```diff
- sy-subrc = 0.
- sy-tabix = 1.
+ " Pass explicit return values or flags instead of modifying system variables (sy-*)
+ rv_success = abap_true.
```

### Non-Compliant

```abap
sy-subrc = 0.
sy-tabix = 1.
```

### Compliant

```abap
" Pass explicit return values or flags instead of modifying system variables (sy-*)
rv_success = abap_true.
```

## CLI & CI/CD Configuration

```yaml
checks:
  no-sy-modify:
    enabled: true
    severity: warning
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC SY_MODIFY

" SAP CI_ prefix format:
... "#EC CI_SY_MODIFY
```

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_NO_SY_MODIFY`
* **Finding Code:** `SYS_VAR_MD`
* **Implementation File:** [zcl_skylint_no_sy_modify.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_no_sy_modify.clas.abap)
