# Declare Constructor in PUBLIC SECTION

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="danger" text="Finding: CTOR_PUB" />
</div>

## Overview

Declare Constructor in PUBLIC SECTION.

> **ATC Finding Message:** `Declare constructor in PUBLIC SECTION, even if class is CREATE PRIVATE`

## Rationale

Instance constructors must always be declared in the PUBLIC SECTION, even for classes with CREATE PRIVATE or CREATE PROTECTED, ensuring standard reflection, factory instantiation, and Clean ABAP compliance.

## Transformation

```diff
- CLASS zcl_service DEFINITION PUBLIC CREATE PRIVATE.
-   PRIVATE SECTION.
-     METHODS constructor.
- ENDCLASS.
+ CLASS zcl_service DEFINITION PUBLIC CREATE PRIVATE.
+   PUBLIC SECTION.
+     METHODS constructor.
+ ENDCLASS.
```

### Non-Compliant

```abap
CLASS zcl_service DEFINITION PUBLIC CREATE PRIVATE.
  PRIVATE SECTION.
    METHODS constructor.
ENDCLASS.
```

### Compliant

```abap
CLASS zcl_service DEFINITION PUBLIC CREATE PRIVATE.
  PUBLIC SECTION.
    METHODS constructor.
ENDCLASS.
```

## CLI & CI/CD Configuration

```yaml
checks:
  prefer-public-constructor:
    enabled: true
    severity: warning
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC PUB_CTOR

" SAP CI_ prefix format:
... "#EC CI_PUB_CTOR
```

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_PREF_PUB_CTOR`
* **Finding Code:** `CTOR_PUB`
* **Implementation File:** [zcl_skylint_pref_pub_ctor.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_pref_pub_ctor.clas.abap)
