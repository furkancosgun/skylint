# Avoid Public Attributes in Classes

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="tip" text="Anti-Patterns & Bad Practices" />
  <Badge type="danger" text="Finding: NOPUBATTR" />
</div>

## Overview

Avoid mutable public attributes in classes.

> **ATC Finding Message:** `Avoid public attributes; use private/protected with getters or READ-ONLY`

## Rationale

Public attributes violate encapsulation because external consumers can mutate internal state arbitrarily. Encapsulate state using private/protected attributes exposed via methods or `READ-ONLY`.

## Transformation

```diff
- CLASS cl_model DEFINITION PUBLIC.
-   PUBLIC SECTION.
-     DATA mv_state TYPE i.
- ENDCLASS.
+ CLASS cl_model DEFINITION PUBLIC.
+   PUBLIC SECTION.
+     METHODS get_state RETURNING VALUE(rv_state) TYPE i.
+   PRIVATE SECTION.
+     DATA mv_state TYPE i.
+ ENDCLASS.
```

### ✕ Non-Compliant

```abap
CLASS cl_model DEFINITION PUBLIC.
  PUBLIC SECTION.
    DATA mv_state TYPE i.
ENDCLASS.
```

### ✓ Compliant

```abap
CLASS cl_model DEFINITION PUBLIC.
  PUBLIC SECTION.
    METHODS get_state RETURNING VALUE(rv_state) TYPE i.
  PRIVATE SECTION.
    DATA mv_state TYPE i.
ENDCLASS.
```

## CLI & CI/CD Configuration

```yaml
checks:
  no-public-attributes:
    enabled: true
    severity: warning
```

## Suppression

To suppress findings for this rule, append the pseudo-comment or pragma to the statement:

```abap
" Using pseudo-comment:
... "#EC PUBLIC_ATTR
" Or with SAP CI_ prefix:
... "#EC CI_PUBLIC_ATTR

" Using pragma:
... ##PUBLIC_ATTR.
" Or with SAP CI_ prefix:
... ##CI_PUBLIC_ATTR.
```

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_NO_PUBLIC_ATTR`
* **Finding Code:** `NOPUBATTR`
* **Implementation File:** [zcl_skylint_no_public_attr.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_no_public_attr.clas.abap)
