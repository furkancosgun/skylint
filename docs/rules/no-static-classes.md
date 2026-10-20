---
description: "Avoid static-only classes; use instantiable classes"
---

# Avoid Purely Static Utility Classes

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="danger" text="#EC STATIC_CLS" />
</div>

## Overview

Avoid static-only classes; use instantiable classes.

> **ATC Finding Message:** `Avoid static-only classes; declare instance methods and interfaces`

## Rationale

Classes consisting entirely of static methods cannot be mocked via interfaces or subclassing during unit tests, creating rigid coupling throughout the application.

### Non-Compliant

```abap
CLASS cl_math_util DEFINITION PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    CLASS-METHODS add IMPORTING a TYPE i b TYPE i RETURNING VALUE(r) TYPE i.
    CLASS-METHODS sub IMPORTING a TYPE i b TYPE i RETURNING VALUE(r) TYPE i.
ENDCLASS.
```

### Compliant

```abap
CLASS cl_math_util DEFINITION PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    INTERFACES if_math_util.
    METHODS add IMPORTING a TYPE i b TYPE i RETURNING VALUE(r) TYPE i.
ENDCLASS.
```

## Transformation

```diff
- CLASS cl_math_util DEFINITION PUBLIC FINAL CREATE PUBLIC.
-   PUBLIC SECTION.
-     CLASS-METHODS add IMPORTING a TYPE i b TYPE i RETURNING VALUE(r) TYPE i.
-     CLASS-METHODS sub IMPORTING a TYPE i b TYPE i RETURNING VALUE(r) TYPE i.
- ENDCLASS.
+ CLASS cl_math_util DEFINITION PUBLIC FINAL CREATE PUBLIC.
+   PUBLIC SECTION.
+     INTERFACES if_math_util.
+     METHODS add IMPORTING a TYPE i b TYPE i RETURNING VALUE(r) TYPE i.
+ ENDCLASS.
```

## CLI & CI/CD Configuration

```yaml
checks:
  no-static-classes:
    enabled: true
    severity: warning
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC STATIC_CLS

" SAP CI_ prefix format:
... "#EC CI_STATIC_CLS
```

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_NO_STATIC_CLS`
* **Implementation File:** [zcl_skylint_no_static_cls.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_no_static_cls.clas.abap)
