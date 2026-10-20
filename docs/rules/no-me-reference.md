# Avoid Redundant ME-> Self Reference

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="tip" text="Anti-Patterns & Bad Practices" />
  <Badge type="danger" text="#EC ME" />
</div>

## Overview

Avoid self-reference ME->.

> **ATC Finding Message:** `Avoid unnecessary ME-> reference`

## Rationale

In ABAP, member variables and methods are automatically accessible within the instance context. Prefixing every member access with `me->` creates visual noise, except when disambiguating parameter shadowing in constructors.

### Non-Compliant

```abap
me->mv_status = c_active.
me->process_order( ).
```

### Compliant

```abap
mv_status = c_active.
process_order( ).
```

## Transformation

```diff
- me->mv_status = c_active.
- me->process_order( ).
+ mv_status = c_active.
+ process_order( ).
```

## Configuration & Thresholds

This check can be fine-tuned directly in the ATC Check Variant Editor (`CHKV`) in Eclipse ADT:

| Parameter Name | Data Type | Default Value |
|---|---|:---:|
| `ALLOW_IN_CONSTRUCTORS` | `Boolean` | <code>true</code> |

## CLI & CI/CD Configuration

```yaml
checks:
  no-me-reference:
    enabled: true
    severity: warning
    attributes:
      allowInConstructors: true
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC ME

" SAP CI_ prefix format:
... "#EC CI_ME
```

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_NO_ME_REFERENCE`
* **Implementation File:** [zcl_skylint_no_me_reference.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_no_me_reference.clas.abap)
