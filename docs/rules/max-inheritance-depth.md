# Limit Inheritance Depth

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="tip" text="Metrics & Complexity Limits" />
  <Badge type="danger" text="Finding: DEEP_INHRT" />
</div>

## Overview

Avoid deep class inheritance hierarchies.

> **ATC Finding Message:** `Avoid deep class inheritance; prefer composition over inheritance`

## Rationale

Deep class inheritance hierarchies create the fragile base class problem and tight coupling. Favor composition over inheritance (`HAS-A` instead of `IS-A`).

### Non-Compliant

```abap
CLASS lcl_child DEFINITION INHERITING FROM lcl_sub_parent. " Depth > 3
ENDCLASS.
```

### Compliant

```abap
" Favor composition over deep class inheritance hierarchies
CLASS lcl_worker DEFINITION.
  PRIVATE SECTION.
    DATA mo_engine TYPE REF TO if_engine.
ENDCLASS.
```

## Transformation

```diff
- CLASS lcl_child DEFINITION INHERITING FROM lcl_sub_parent. " Depth > 3
- ENDCLASS.
+ " Favor composition over deep class inheritance hierarchies
+ CLASS lcl_worker DEFINITION.
+   PRIVATE SECTION.
+     DATA mo_engine TYPE REF TO if_engine.
+ ENDCLASS.
```

## Configuration & Thresholds

This check can be fine-tuned directly in the ATC Check Variant Editor (`CHKV`) in Eclipse ADT:

| Parameter Name | Data Type | Default Value |
|---|---|:---:|
| `MAX_DEPTH` | `Integer / String` | `3` |

## CLI & CI/CD Configuration

```yaml
checks:
  max-inheritance-depth:
    enabled: true
    severity: warning
    attributes:
      maxDepth: 3
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC INHERIT_DEPTH

" SAP CI_ prefix format:
... "#EC CI_INHERIT_DEPTH
```

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_MAX_INHERIT`
* **Finding Code:** `DEEP_INHRT`
* **Implementation File:** [zcl_skylint_max_inherit.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_max_inherit.clas.abap)
