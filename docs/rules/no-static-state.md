---
title: "Avoid Mutable Static State via CLASS-DATA and STATICS"
description: "Detect mutable CLASS-DATA and STATICS in ABAP to prevent hidden session state and unit test interference."
keywords: "ABAP STATICS, CLASS-DATA, global state anti-pattern, Clean ABAP, SAP ATC check, no-static-state"
category: "anti-patterns"
ruleId: "no-static-state"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L4537"
---

# Avoid Mutable Static State via CLASS-DATA and STATICS

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Anti-Patterns & Bad Practices" />
  <Badge type="danger" text="#EC NO_STATIC_STATE" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L4537" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Avoid CLASS-DATA and STATICS state.

> **ATC Finding Message:** `Static state hides dependencies and survives between calls; inject state instead`

## Rationale

Static state defined with CLASS-DATA or STATICS persists across procedure executions for the entire user session, coupling unrelated processes and introducing non-deterministic failures in unit tests. Hidden global state breaks idempotence and concurrency guarantees in ABAP Cloud stateless runtime containers. State should reside within instance attributes or be transferred explicitly via method parameters.

### Non-Compliant

```abap
STATICS sv_invoice_counter TYPE i.
sv_invoice_counter = sv_invoice_counter + 1.
```

### Compliant

```abap
DATA lv_invoice_counter TYPE i.
lv_invoice_counter = lv_invoice_counter + 1.
```

## Configuration & Thresholds

This check can be fine-tuned directly in the ATC Check Variant Editor (`CHKV`) in Eclipse ADT:

| Parameter Name | Data Type | Default Value | Description & Guidance |
|---|---|:---:|---|
| `CHECK_CLASS_DATA` | `Boolean` | <code>true</code> | Flag CLASS-DATA declarations in class definitions to prevent static class-level memory state (default true). |
| `CHECK_STATICS` | `Boolean` | <code>true</code> | Flag STATICS variable declarations inside methods, forms, and function modules (default true). |

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC NO_STATIC_STATE

" SAP CI_ prefix format:
... "#EC CI_NO_STATIC_STATE
```

### Scanned declarations

The check monitors static memory declarations across compilation units:

| Statement | Scope | Governed By Parameter |
| --- | --- | --- |
| `CLASS-DATA` | Class definitions | `CHECK_CLASS_DATA` (default: `abap_true`) |
| `STATICS` | Methods, function modules, and form routines | `CHECK_STATICS` (default: `abap_true`) |

### Testability & Session Safety

In modern ABAP Cloud systems, internal sessions can be reused across service calls or test executions. Retaining mutable variables in static memory leads to cross-test contamination and race conditions in multi-threaded ABAP environments. Use dependency injection and instance member attributes instead.

### Suppression

Legitimate performance caches or singleton registries can be suppressed with `"#EC NO_STATIC_STATE`.


## Related Rules

* [Call Static Methods with Class Component Selector (=>)](/rules/no-static-arrow) — <code>#EC NO_STATIC_ARROW</code>
* [Enforce Standard Naming Conventions for Class Members, Parameters and Screens](/rules/pref-name-members) — <code>#EC PREF_NAME_MEMBERS</code>
* [Limit Class Member Attribute Count to Prevent God Objects](/rules/max-attributes) — <code>#EC MAX_ATTRIBUTES</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_NO_STATIC_STATE`
* **ABAP Implementation:** [/skyl/cl_no_static_state.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_no_static_state.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 4537)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L4537)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_NO_STATIC_STATE&title=%5BBug%5D%3A%20Issue%20in%20no-static-state)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20no-static-state)**
