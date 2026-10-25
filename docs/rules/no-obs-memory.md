---
title: "Avoid Obsolete ABAP Memory and Context Statements"
description: "Avoid Obsolete ABAP Memory and Context Statements - Clean ABAP guidelines, modern SAP syntax rules, and automated ATC code inspection for SAP S/4HANA and ABAP Cloud."
keywords: "Clean ABAP, SAP ATC Check, ABAP Cloud, S/4HANA Readiness, no-obs-memory, anti-patterns"
category: "anti-patterns"
ruleId: "no-obs-memory"
---

# Avoid Obsolete ABAP Memory and Context Statements

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Anti-Patterns & Bad Practices" />
  <Badge type="danger" text="#EC NO_OBS_MEMORY" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Obsolete Memory and Context Statements.

> **ATC Finding Message:** `Avoid obsolete memory, context, and legacy data-sharing constructs`

## Rationale

ABAP memory and database cluster statements (EXPORT ... TO MEMORY / DATABASE, FREE MEMORY) and Context commands (CONTEXTS, DEMAND, SUPPLY, PROVIDE) rely on hidden shared memory regions that break statelessness, multi-tenancy, and testability. In cloud systems, communicate explicitly via method parameters, database repositories, or session services.

### Non-Compliant

```abap
EXPORT user_id = lv_user TO MEMORY ID 'USR_CTX'.
FREE MEMORY ID 'USR_CTX'.
```

### Compliant

```abap
" Pass user context explicitly via method arguments or a dedicated context provider service.
```

## Configuration & Thresholds

This check can be fine-tuned directly in the ATC Check Variant Editor (`CHKV`) in Eclipse ADT:

| Parameter Name | Data Type | Default Value | Description & Guidance |
|---|---|:---:|---|
| `CHECK_EXPORT_MEMORY` | `Boolean` | <code>true</code> | Detect obsolete EXPORT TO MEMORY statements |
| `CHECK_FREE_MEMORY` | `Boolean` | <code>true</code> | Detect obsolete FREE MEMORY statements |
| `CHECK_PROVIDE` | `Boolean` | <code>true</code> | Detect obsolete PROVIDE statements |
| `CHECK_CONTEXTS` | `Boolean` | <code>true</code> | Detect obsolete CONTEXTS statements |
| `CHECK_INFOTYPES` | `Boolean` | <code>true</code> | Detect obsolete INFOTYPES statements |
| `CHECK_COMMUNICATION` | `Boolean` | <code>true</code> | Detect obsolete COMMUNICATION statements |
| `CHECK_CALL_TRANSF` | `Boolean` | <code>true</code> | Detect obsolete CALL TRANSFORMATION XML statements |

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC NO_OBS_MEMORY

" SAP CI_ prefix format:
... "#EC CI_NO_OBS_MEMORY
```


## Related Rules

* [Avoid Obsolete Arithmetic and Assignment Statements](/rules/no-obs-arith) — <code>#EC NO_OBS_ARITH</code>
* [Avoid Obsolete Control Flow and Procedural Forms](/rules/no-obs-control) — <code>#EC NO_OBS_CONTROL</code>
* [Avoid Obsolete Declarations and Table Headers](/rules/no-obs-decl) — <code>#EC NO_OBS_DECL</code>

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_NO_OBS_MEMORY`
* **Implementation File:** [zcl_skylint_no_obs_memory.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_no_obs_memory.clas.abap)
