# Keep Constructors Clean & Lightweight

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="danger" text="Finding: CTOR_LOGIC" />
</div>

## Overview

Keep constructors clean; avoid heavy logic and DB.

> **ATC Finding Message:** `Avoid heavy business logic/loops in constructor; use injection only`

## Rationale

Constructors should only initialize state and inject dependencies. Heavy business logic, database queries, or network I/O in constructors make test mocking and instantiation brittle.

## Transformation

```diff
- METHOD constructor.
-   super->constructor( ).
-   " 15+ statements initializing complex states and reading DB...
- ENDMETHOD.
+ METHOD constructor.
+   super->constructor( ).
+   mo_gateway = io_gateway. " Simple dependency assignment only
+ ENDMETHOD.
```

### Non-Compliant

```abap
METHOD constructor.
  super->constructor( ).
  " 15+ statements initializing complex states and reading DB...
ENDMETHOD.
```

### Compliant

```abap
METHOD constructor.
  super->constructor( ).
  mo_gateway = io_gateway. " Simple dependency assignment only
ENDMETHOD.
```

## Configuration & Thresholds

This check can be fine-tuned directly in the ATC Check Variant Editor (`CHKV`) in Eclipse ADT:

| Parameter Name | Data Type | Default Value | Description |
|---|---|:---:|---|
| `MAX_STATEMENTS` | `Integer / String` | `10` | Configurable attribute for clean-constructor |

## CLI & CI/CD Configuration

```yaml
checks:
  clean-constructor:
    enabled: true
    severity: warning
    attributes:
      maxStatements: 10
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC CLEAN_CTOR

" SAP CI_ prefix format:
... "#EC CI_CLEAN_CTOR
```

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_CLEAN_CTOR`
* **Finding Code:** `CTOR_LOGIC`
* **Implementation File:** [zcl_skylint_clean_ctor.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_clean_ctor.clas.abap)
