# Limit Member Attributes per Class

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="tip" text="Metrics & Complexity Limits" />
  <Badge type="danger" text="Finding: ATTR_COUNT" />
</div>

## Overview

Limit class member attributes to prevent God Classes.

> **ATC Finding Message:** `Class has too many member attributes; split into cohesive components`

## Rationale

Classes with dozens of member variables are almost always God Objects that handle multiple unrelated responsibilities. Split them into smaller, focused domain classes.

## Transformation

```diff
- CLASS cl_order DEFINITION.
-   PRIVATE SECTION.
-     " 30+ individual scalar member variables
- ENDCLASS.
+ CLASS cl_order DEFINITION.
+   PRIVATE SECTION.
+     DATA ms_header TYPE ty_order_header.
+     DATA mt_items  TYPE ty_order_items.
+ ENDCLASS.
```

### Non-Compliant

```abap
CLASS cl_order DEFINITION.
  PRIVATE SECTION.
    " 30+ individual scalar member variables
ENDCLASS.
```

### Compliant

```abap
CLASS cl_order DEFINITION.
  PRIVATE SECTION.
    DATA ms_header TYPE ty_order_header.
    DATA mt_items  TYPE ty_order_items.
ENDCLASS.
```

## Configuration & Thresholds

This check can be fine-tuned directly in the ATC Check Variant Editor (`CHKV`) in Eclipse ADT:

| Parameter Name | Data Type | Default Value | Description |
|---|---|:---:|---|
| `MAX_ATTRIBUTES` | `Integer / String` | `5` | Configurable attribute for max-attributes |

## CLI & CI/CD Configuration

```yaml
checks:
  max-attributes:
    enabled: true
    severity: warning
    attributes:
      maxAttributes: 5
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC ATTRIBUTES

" SAP CI_ prefix format:
... "#EC CI_ATTRIBUTES
```

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_MAX_ATTRIBUTES`
* **Finding Code:** `ATTR_COUNT`
* **Implementation File:** [zcl_skylint_max_attributes.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_max_attributes.clas.abap)
