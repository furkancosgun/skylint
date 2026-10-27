---
title: "Avoid Static State (CLASS-DATA and STATICS)"
description: "Detect CLASS-DATA attributes and STATICS variables in ABAP, highlighting hidden global state that breaks test isolation and dependency clarity."
keywords: "ABAP CLASS-DATA, ABAP STATICS, static state anti-pattern, SAP ATC check global state, ABAP test isolation"
category: "anti-patterns"
ruleId: "no-static-state"
---

# Avoid Static State (CLASS-DATA and STATICS)

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Anti-Patterns & Bad Practices" />
  <Badge type="danger" text="#EC NO_STATIC_STATE" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Avoid CLASS-DATA and STATICS state.

> **ATC Finding Message:** `Static state hides dependencies and survives between calls; inject state instead`

## Rationale

Static state survives between calls and is shared by every caller in the internal session, which makes behavior order-dependent and lets unit tests interfere with each other. CLASS-DATA and STATICS also hide dependencies: a method looks self-contained while it silently reads or mutates global memory. Keep state in instances that are injected, or pass it explicitly, so lifecycles stay visible and tests stay isolated.

### Non-Compliant

```abap
CLASS-DATA gv_counter TYPE i.

METHOD increment.
  STATICS sv_calls TYPE i.
  sv_calls = sv_calls + 1.
ENDMETHOD.
```

### Compliant

```abap
METHOD increment
  IMPORTING io_counter TYPE REF TO zcl_counter.
  io_counter->increment( ).
ENDMETHOD.
```

## Configuration & Thresholds

This check can be fine-tuned directly in the ATC Check Variant Editor (`CHKV`) in Eclipse ADT:

| Parameter Name | Data Type | Default Value | Description & Guidance |
|---|---|:---:|---|
| `CHECK_CLASS_DATA` | `Boolean` | <code>true</code> | Detect CLASS-DATA attributes declared in class definitions |
| `CHECK_STATICS` | `Boolean` | <code>true</code> | Detect STATICS variables declared inside methods, forms, and function modules |

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC NO_STATIC_STATE

" SAP CI_ prefix format:
... "#EC CI_NO_STATIC_STATE
```


## Related Rules

* [Avoid Calling Static Methods via Instance References (->)](/rules/no-static-arrow) — <code>#EC NO_STATIC_ARROW</code>
* [Enforce Class Attribute and Method Parameter Naming Conventions](/rules/pref-name-members) — <code>#EC PREF_NAME_MEMBERS</code>
* [Limit Class Member Attribute Count (Prevent God Classes)](/rules/max-attributes) — <code>#EC MAX_ATTRIBUTES</code>

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_NO_STATIC_STATE`
* **Implementation File:** [zcl_skylint_no_static_state.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_no_static_state.clas.abap)
