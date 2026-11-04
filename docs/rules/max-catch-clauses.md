---
title: "Limit Number of CATCH Clauses per TRY Block"
description: "Limit CATCH clauses per ABAP TRY block to prevent high error-handling coupling."
keywords: "ABAP TRY CATCH limit, Error Handling Coupling, Clean ABAP, Clean Exceptions"
category: "metrics"
ruleId: "max-catch-clauses"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L5400"
---

# Limit Number of CATCH Clauses per TRY Block

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Metrics & Complexity Limits" />
  <Badge type="danger" text="#EC MAX_CATCH_CLAUSES" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L5400" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Limit CATCH clauses per TRY block.

> **ATC Finding Message:** `TRY block has too many CATCH clauses; handling too many errors indicates coupling`

## Rationale

A single TRY block handling an excessive number of distinct exception types indicates high coupling and overly broad responsibilities. Decompose the procedure or catch common superclasses if appropriate.

### Non-Compliant

```abap
TRY.
    execute_workflow( ).
  CATCH cx_a. ...
  CATCH cx_b. ...
  CATCH cx_c. ...
  CATCH cx_d. ...
ENDTRY.
```

### Compliant

```abap
TRY.
    execute_workflow( ).
  CATCH cx_workflow_error. ...
ENDTRY.
```

## Configuration & Thresholds

This check can be fine-tuned directly in the ATC Check Variant Editor (`CHKV`) in Eclipse ADT:

| Parameter Name | Data Type | Default Value | Description & Guidance |
|---|---|:---:|---|
| `MAX_CATCH_CLAUSES` | `Integer` | <code>3</code> | Maximum number of CATCH clauses allowed per TRY block (default: 3) |

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC MAX_CATCH_CLAUSES

" SAP CI_ prefix format:
... "#EC CI_MAX_CATCH_CLAUSES
```


## Related Rules

* [Avoid Catching Generic CX_ROOT (Catch Specific Exceptions)](/rules/no-catch-root) — <code>#EC NO_CATCH_ROOT</code>
* [Prefer Class-Based Exceptions over Classic EXCEPTIONS](/rules/pref-class-exc) — <code>#EC PREF_CLASS_EXC</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_MAX_CATCH_CLAUSES`
* **ABAP Implementation:** [/skyl/cl_max_catch_clauses.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_max_catch_clauses.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 5400)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L5400)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_MAX_CATCH_CLAUSES&title=%5BBug%5D%3A%20Issue%20in%20max-catch-clauses)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20max-catch-clauses)**
