---
description: "Method signature cleanliness (excessive parameter count)"
---

# Limit Method Parameter Count

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="tip" text="Metrics & Complexity Limits" />
  <Badge type="danger" text="#EC MAX_PARAMS" />
</div>

## Overview

Method signature cleanliness (excessive parameter count).

> **ATC Finding Message:** `Method signature has too many parameters; consider grouping into structures`

## Rationale

Methods with excessive parameters are difficult to comprehend, call, and test. When a method needs more than 5-8 parameters, bundle related fields into a structured type or parameter object.

### Non-Compliant

```abap
METHODS execute
  IMPORTING p1 TYPE i p2 TYPE i p3 TYPE i p4 TYPE i p5 TYPE i p6 TYPE i.
```

### Compliant

```abap
METHODS execute
  IMPORTING is_options TYPE ty_options.
```

## Transformation

```diff
- METHODS execute
-   IMPORTING p1 TYPE i p2 TYPE i p3 TYPE i p4 TYPE i p5 TYPE i p6 TYPE i.
+ METHODS execute
+   IMPORTING is_options TYPE ty_options.
```

## Configuration & Thresholds

This check can be fine-tuned directly in the ATC Check Variant Editor (`CHKV`) in Eclipse ADT:

| Parameter Name | Data Type | Default Value |
|---|---|:---:|
| `MAX_PARAMETERS` | `Integer / String` | <code>8</code> |

## CLI & CI/CD Configuration

```yaml
checks:
  max-params:
    enabled: true
    severity: warning
    attributes:
      maxParameters: 8
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC MAX_PARAMS

" SAP CI_ prefix format:
... "#EC CI_MAX_PARAMS
```

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_MAX_PARAMS`
* **Implementation File:** [zcl_skylint_max_params.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_max_params.clas.abap)
