---
description: "Avoid deep class inheritance hierarchies"
---

# Limit Inheritance Depth

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Metrics & Complexity Limits" />
  <Badge type="danger" text="#EC INHERIT_DEPTH" />
  <Badge type="warning" text="Local Only" />
</div>

## Overview

Avoid deep class inheritance hierarchies.

> **ATC Finding Message:** `Avoid deep class inheritance; prefer composition over inheritance`

## Rationale

Deep inheritance chains make behavior depend on many superclasses and expose subclasses to the fragile base class problem. A change near the root can affect every descendant and is hard to test completely. Prefer composition and keep class hierarchies shallow.

### Non-Compliant

```abap
CLASS lcl_level1 DEFINITION.
ENDCLASS.
CLASS lcl_level2 DEFINITION INHERITING FROM lcl_level1.
ENDCLASS.
CLASS lcl_level3 DEFINITION INHERITING FROM lcl_level2.
ENDCLASS.
CLASS lcl_level4 DEFINITION INHERITING FROM lcl_level3.
ENDCLASS.
CLASS lcl_level5 DEFINITION INHERITING FROM lcl_level4.
ENDCLASS.
```

### Compliant

```abap
CLASS lcl_worker DEFINITION.
  PRIVATE SECTION.
    DATA mo_engine TYPE REF TO if_engine.
ENDCLASS.
```

## Configuration & Thresholds

This check can be fine-tuned directly in the ATC Check Variant Editor (`CHKV`) in Eclipse ADT:

| Parameter Name | Data Type | Default Value |
|---|---|:---:|
| `MAX_DEPTH` | `Integer` | <code>3</code> |

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
* **Implementation File:** [zcl_skylint_max_inherit.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_max_inherit.clas.abap)
