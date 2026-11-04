---
title: "Avoid Empty Procedures"
description: "Detect empty procedures including methods, forms, and function modules."
keywords: "Clean ABAP, empty procedure, no-empty-proc"
category: "clean-abap"
ruleId: "no-empty-proc"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L4623"
---

# Avoid Empty Procedures

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="danger" text="#EC NO_EMPTY_PROC" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L4623" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Avoid empty procedures (methods, forms, functions).

> **ATC Finding Message:** `Procedure is empty; implement logic or remove procedure`

## Rationale

Methods, form routines, and function modules should not be empty. Implement required logic or remove superfluous empty procedures.

### Non-Compliant

```abap
METHOD do_work.
ENDMETHOD.
```

### Compliant

```abap
METHOD do_work.
  DATA lv_val TYPE i.
  lv_val = 1.
ENDMETHOD.
```

## Configuration & Thresholds

This check can be fine-tuned directly in the ATC Check Variant Editor (`CHKV`) in Eclipse ADT:

| Parameter Name | Data Type | Default Value | Description & Guidance |
|---|---|:---:|---|
| `CHECK_METHODS` | `Boolean` | <code>true</code> | Check methods (defaults to true) |
| `CHECK_FORMS` | `Boolean` | <code>true</code> | Check form routines (defaults to true) |
| `CHECK_FUNCS` | `Boolean` | <code>true</code> | Check function modules (defaults to true) |

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC NO_EMPTY_PROC

" SAP CI_ prefix format:
... "#EC CI_NO_EMPTY_PROC
```


## Related Rules

* [Avoid Empty Control Blocks](/rules/no-empty-block) — <code>#EC NO_EMPTY_BLOCK</code>
* [Avoid Dead Code with Constant Conditions](/rules/no-dead-code) — <code>#EC NO_DEAD_CODE</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_NO_EMPTY_PROC`
* **ABAP Implementation:** [/skyl/cl_no_empty_proc.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_no_empty_proc.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 4623)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L4623)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_NO_EMPTY_PROC&title=%5BBug%5D%3A%20Issue%20in%20no-empty-proc)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20no-empty-proc)**
