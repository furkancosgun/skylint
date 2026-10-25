---
description: "Obsolete Memory and Context Statements"
---

# Avoid Obsolete ABAP Memory and Context Statements

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Anti-Patterns & Bad Practices" />
  <Badge type="danger" text="#EC OBSOLETE_MEM" />
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

| Parameter Name | Data Type | Default Value |
|---|---|:---:|
| `CHECK_EXPORT_MEMORY` | `Boolean` | <code>true</code> |
| `CHECK_FREE_MEMORY` | `Boolean` | <code>true</code> |
| `CHECK_PROVIDE` | `Boolean` | <code>true</code> |
| `CHECK_CONTEXTS` | `Boolean` | <code>true</code> |
| `CHECK_INFOTYPES` | `Boolean` | <code>true</code> |
| `CHECK_COMMUNICATION` | `Boolean` | <code>true</code> |
| `CHECK_CALL_TRANSF` | `Boolean` | <code>true</code> |

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC OBSOLETE_MEM

" SAP CI_ prefix format:
... "#EC CI_OBSOLETE_MEM
```

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_NO_OBS_MEMORY`
* **Implementation File:** [zcl_skylint_no_obs_memory.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_no_obs_memory.clas.abap)
