---
description: "Cyclomatic Complexity Threshold"
---

# Limit Cyclomatic Complexity

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="tip" text="Metrics & Complexity Limits" />
  <Badge type="danger" text="#EC CYCLO_COMP" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Cyclomatic Complexity Threshold.

> **ATC Finding Message:** `Procedure cyclomatic complexity exceeds threshold`

## Rationale

High cyclomatic complexity means a method contains too many decision points (branches, loops, catches), making comprehensive unit test branch coverage nearly impossible.

### Non-Compliant

```abap
" Complex method containing excessive branches (> 10 cyclomatic complexity)
METHOD compute.
  IF c1. ... ELSEIF c2. ... ELSEIF c3. ...
ENDMETHOD.
```

### Compliant

```abap
" Decompose into strategy classes or cohesive helper methods
METHOD compute.
  ro_strategy = mo_factory->get_strategy( mv_type ).
  ro_strategy->execute( ).
ENDMETHOD.
```

## Transformation

```diff
- " Complex method containing excessive branches (> 10 cyclomatic complexity)
- METHOD compute.
-   IF c1. ... ELSEIF c2. ... ELSEIF c3. ...
- ENDMETHOD.
+ " Decompose into strategy classes or cohesive helper methods
+ METHOD compute.
+   ro_strategy = mo_factory->get_strategy( mv_type ).
+   ro_strategy->execute( ).
+ ENDMETHOD.
```

## Configuration & Thresholds

This check can be fine-tuned directly in the ATC Check Variant Editor (`CHKV`) in Eclipse ADT:

| Parameter Name | Data Type | Default Value |
|---|---|:---:|
| `MAX_COMPLEXITY` | `Integer` | <code>5</code> |

## CLI & CI/CD Configuration

```yaml
checks:
  max-cyclomatic-complexity:
    enabled: true
    severity: warning
    attributes:
      maxComplexity: 5
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC CYCLO_COMP

" SAP CI_ prefix format:
... "#EC CI_CYCLO_COMP
```

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_MAX_CYCLO_COMP`
* **Implementation File:** [zcl_skylint_max_cyclo_comp.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_max_cyclo_comp.clas.abap)
