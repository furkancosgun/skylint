---
title: "Limit Type Fan-Out per Procedure"
description: "Measure ABAP procedure coupling by counting distinct class and interface type references, and flag types that depend on too many collaborators."
keywords: "ABAP class coupling metric, fan-out ABAP, Sonar S1200 coupling, SAP ATC metrics check, type dependencies procedure"
category: "metrics"
ruleId: "max-fanout"
---

# Limit Type Fan-Out per Procedure

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Metrics & Complexity Limits" />
  <Badge type="danger" text="#EC MAX_FANOUT" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Limit type fan-out per procedure.

> **ATC Finding Message:** `Procedure depends on too many distinct classes or interfaces`

## Rationale

A procedure that references many unrelated classes and interfaces is tightly coupled to a large part of the system, which makes it fragile and hard to test in isolation. Counting distinct `kind = type` references gives a lower-bound fan-out metric that never produces false positives: only types that actually appear in the procedure body are considered. Split responsibilities or introduce a facade when the number grows.

### Non-Compliant

```abap
DATA lo_a TYPE REF TO zcl_a.
DATA lo_b TYPE REF TO zcl_b.
DATA lo_c TYPE REF TO zcl_c.
DATA lo_d TYPE REF TO zcl_d.
```

### Compliant

```abap
DATA lo_service TYPE REF TO zif_order_service.
lo_service = mo_service_factory->create( ).
```

## Configuration & Thresholds

This check can be fine-tuned directly in the ATC Check Variant Editor (`CHKV`) in Eclipse ADT:

| Parameter Name | Data Type | Default Value | Description & Guidance |
|---|---|:---:|---|
| `MAX_FANOUT` | `Integer` | <code>15</code> | Maximum allowed number of distinct class or interface types per procedure (default: 15) |

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC MAX_FANOUT

" SAP CI_ prefix format:
... "#EC CI_MAX_FANOUT
```


## Related Rules

* [Limit Class Inheritance Depth (Favor Composition over Inheritance)](/rules/max-inherit) — <code>#EC MAX_INHERIT</code>
* [Limit Class Member Attribute Count (Prevent God Classes)](/rules/max-attributes) — <code>#EC MAX_ATTRIBUTES</code>
* [Limit Method and Constructor Statement Length](/rules/max-method-len) — <code>#EC MAX_METHOD_LEN</code>

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_MAX_FANOUT`
* **Implementation File:** [zcl_skylint_max_fanout.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_max_fanout.clas.abap)
