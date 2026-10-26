---
title: "Limit NPath Complexity per Method"
description: "Limit NPath execution path complexity in ABAP procedures to prevent combinatorial branch explosion and ensure thorough unit testability."
keywords: "NPath complexity ABAP, Checkstyle NPath, PMD NPath complexity, SAP ATC complexity check, acyclic execution paths"
category: "metrics"
ruleId: "max-npath"
---

# Limit NPath Complexity per Method

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Metrics & Complexity Limits" />
  <Badge type="danger" text="#EC MAX_NPATH" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Limit NPath complexity per procedure.

> **ATC Finding Message:** `Procedure NPath complexity exceeds threshold`

## Rationale

NPath complexity measures the total number of acyclic execution paths through a procedure. Unlike cyclomatic complexity which grows linearly with decision points, NPath complexity grows multiplicatively across sequential and nested control structures (IF, CASE, loops, compound boolean expressions). High NPath complexity makes exhaustive testing impossible. Keep NPath under the threshold by breaking large procedures into cohesive helper methods.

### Non-Compliant

```abap
METHOD process.
  IF cond_a = abap_true.
    ...
  ENDIF.
  IF cond_b = abap_true.
    ...
  ENDIF.
  IF cond_c = abap_true.
    ...
  ENDIF.
ENDMETHOD.
```

### Compliant

```abap
METHOD process.
  handle_condition_a( ).
  handle_condition_b( ).
  handle_condition_c( ).
ENDMETHOD.
```

## Configuration & Thresholds

This check can be fine-tuned directly in the ATC Check Variant Editor (`CHKV`) in Eclipse ADT:

| Parameter Name | Data Type | Default Value | Description & Guidance |
|---|---|:---:|---|
| `MAX_NPATH` | `Integer` | <code>200</code> | Maximum allowed NPath execution paths per procedure (default: 200) |

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC MAX_NPATH

" SAP CI_ prefix format:
... "#EC CI_MAX_NPATH
```


## Related Rules

* [Limit Cyclomatic Complexity (McCabe Complexity Metric)](/rules/max-cyclo-comp) — <code>#EC MAX_CYCLO_COMP</code>
* [Limit Cognitive Complexity per Method](/rules/max-cognitive) — <code>#EC MAX_COGNITIVE</code>
* [Limit Control Flow Nesting Depth (Guard Clause Enforcement)](/rules/max-nesting) — <code>#EC MAX_NESTING</code>
* [Limit Method and Constructor Statement Length](/rules/max-method-len) — <code>#EC MAX_METHOD_LEN</code>

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_MAX_NPATH`
* **Implementation File:** [zcl_skylint_max_npath.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_max_npath.clas.abap)
