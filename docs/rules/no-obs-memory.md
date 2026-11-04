---
title: "Prohibit Obsolete ABAP Memory and Cluster Statements"
description: "Prohibit obsolete ABAP memory, database clusters, and Context statements in ABAP Cloud."
keywords: "no-obs-memory, EXPORT TO MEMORY, FREE MEMORY, Clean ABAP, ABAP Cloud"
category: "anti-patterns"
ruleId: "no-obs-memory"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L1300"
---

# Prohibit Obsolete ABAP Memory and Cluster Statements

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Anti-Patterns & Bad Practices" />
  <Badge type="danger" text="#EC NO_OBS_MEMORY" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L1300" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Obsolete Memory and Context Statements.

> **ATC Finding Message:** `Avoid obsolete memory, context, and legacy data-sharing constructs`

## Rationale

Statements interacting with internal ABAP memory or database clusters (EXPORT ... TO MEMORY / DATABASE, FREE MEMORY) and obsolete Context modules (CONTEXTS, DEMAND, SUPPLY, PROVIDE) rely on hidden shared memory regions that break statelessness, multi-tenancy, and test isolation. In ABAP Cloud and cloud-native applications, state must never be stashed in implicit session memory. Instead, exchange data explicitly via method parameters, dependency-injected services, or modern database persistence models.

### Non-Compliant

```abap
EXPORT order_id = lv_order_id TO MEMORY ID 'ORDER_BUFFER'.
FREE MEMORY ID 'ORDER_BUFFER'.
```

### Compliant

```abap
mo_order_repository->store_order_id( iv_order_id = lv_order_id ).
```

## Configuration & Thresholds

This check can be fine-tuned directly in the ATC Check Variant Editor (`CHKV`) in Eclipse ADT:

| Parameter Name | Data Type | Default Value | Description & Guidance |
|---|---|:---:|---|
| `CHECK_EXPORT_MEMORY` | `Boolean` | <code>true</code> | Report obsolete EXPORT ... TO MEMORY and EXPORT ... TO DATABASE statements. |
| `CHECK_FREE_MEMORY` | `Boolean` | <code>true</code> | Report obsolete FREE MEMORY statements that clear shared ABAP memory buffers. |
| `CHECK_PROVIDE` | `Boolean` | <code>true</code> | Report obsolete PROVIDE and ENDPROVIDE statements for interval processing. |
| `CHECK_CONTEXTS` | `Boolean` | <code>true</code> | Report obsolete CONTEXTS, DEMAND, and SUPPLY statements for legacy context objects. |
| `CHECK_INFOTYPES` | `Boolean` | <code>true</code> | Report obsolete INFOTYPES declarations used in classic HR programming. |
| `CHECK_COMMUNICATION` | `Boolean` | <code>true</code> | Report obsolete COMMUNICATION statements used in legacy CPI-C connections. |
| `CHECK_CALL_TRANSF` | `Boolean` | <code>true</code> | Report obsolete CALL TRANSFORMATION ... OBJECTS statements. |

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC NO_OBS_MEMORY

" SAP CI_ prefix format:
... "#EC CI_NO_OBS_MEMORY
```

### Prohibited Memory Statements

- `EXPORT ... TO MEMORY` / `EXPORT ... TO DATABASE`: Breaks encapsulation and leaks state across transactions.
- `FREE MEMORY`: Clears global session buffers without lifecycle management.
- `PROVIDE` / `ENDPROVIDE`: Legacy interval evaluation on internal tables.
- `CONTEXTS`, `DEMAND`, `SUPPLY`: Obsolete context objects replaced by core data services (CDS) and classes.
- `INFOTYPES`: Legacy HR infotype declarations.
- `COMMUNICATION`: Obsolete CPI-C communication interface.
- `CALL TRANSFORMATION ... OBJECTS`: Legacy transformation syntax.

Suppress findings with `"#EC NO_OBS_MEMORY`.


## Related Rules

* [Replace Obsolete Arithmetic Statements with Modern Operators](/rules/no-obs-arith) — <code>#EC NO_OBS_ARITH</code>
* [Eliminate Obsolete Control Flow and Procedural Statements](/rules/no-obs-control) — <code>#EC NO_OBS_CONTROL</code>
* [Replace Obsolete Data Declarations with Explicit Types](/rules/no-obs-decl) — <code>#EC NO_OBS_DECL</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_NO_OBS_MEMORY`
* **ABAP Implementation:** [/skyl/cl_no_obs_memory.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_no_obs_memory.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 1300)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L1300)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_NO_OBS_MEMORY&title=%5BBug%5D%3A%20Issue%20in%20no-obs-memory)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20no-obs-memory)**
