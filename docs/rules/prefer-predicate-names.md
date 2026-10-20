# Use Predicate Naming for Boolean Methods (is_, has_, can_)

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="danger" text="#EC PRED_NAME" />
</div>

## Overview

Enforce predicate naming (IS_, HAS_) on boolean methods.

> **ATC Finding Message:** `Boolean-returning method should use predicate name (IS_, HAS_, CAN_)`

## Rationale

Methods returning boolean status should read like questions (`is_valid`, `has_children`, `can_execute`) so conditionals read naturally like plain English.

### Non-Compliant

```abap
METHODS check_active RETURNING VALUE(rv_active) TYPE abap_bool.
```

### Compliant

```abap
METHODS is_active RETURNING VALUE(rv_active) TYPE abap_bool.
```

## Transformation

```diff
- METHODS check_active RETURNING VALUE(rv_active) TYPE abap_bool.
+ METHODS is_active RETURNING VALUE(rv_active) TYPE abap_bool.
```

## CLI & CI/CD Configuration

```yaml
checks:
  prefer-predicate-names:
    enabled: true
    severity: warning
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC PRED_NAME

" SAP CI_ prefix format:
... "#EC CI_PRED_NAME
```

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_PREF_PRED_NAME`
* **Implementation File:** [zcl_skylint_pref_pred_name.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_pref_pred_name.clas.abap)
