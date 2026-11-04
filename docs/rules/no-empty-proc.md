---
title: "Remove Empty Methods, Forms and Function Modules"
description: "Detect empty ABAP methods, FORM routines and function modules so dead API surface is deleted or implemented instead of silently passing ATC review."
keywords: "empty ABAP method, FORM routine, function module cleanup, SAP ATC, no-empty-proc"
category: "clean-abap"
ruleId: "no-empty-proc"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L4744"
---

# Remove Empty Methods, Forms and Function Modules

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="danger" text="#EC NO_EMPTY_PROC" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L4744" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Avoid empty procedures (methods, forms, functions).

> **ATC Finding Message:** `Procedure is empty; implement logic or remove procedure`

## Rationale

An empty method or FORM is dead API surface: callers cannot tell whether it is a forgotten implementation, an intentional hook or a leftover from a refactor, and reviewers and coverage reports waste time on it. Empty procedures also let an interface contract be fulfilled without any behaviour, which hides a missing feature behind a green build. The check reports procedures whose body holds nothing but the header and footer, so the fix is either to implement the logic or to delete the declaration and its callers.

### Non-Compliant

```abap
METHOD refresh_pricing_cache.
ENDMETHOD.
```

### Compliant

```abap
METHOD refresh_pricing_cache.
  DATA(pricing_entries) = read_pricing_from_database( ).
  cache_pricing_entries( pricing_entries ).
ENDMETHOD.
```

## Configuration & Thresholds

This check can be fine-tuned directly in the ATC Check Variant Editor (`CHKV`) in Eclipse ADT:

| Parameter Name | Data Type | Default Value | Description & Guidance |
|---|---|:---:|---|
| `CHECK_METHODS` | `Boolean` | <code>true</code> | Report METHOD ... ENDMETHOD blocks with an empty body (default enabled). |
| `CHECK_FORMS` | `Boolean` | <code>true</code> | Report FORM ... ENDFORM routines with an empty body (default enabled; switch off while legacy forms are being retired). |
| `CHECK_FUNCS` | `Boolean` | <code>true</code> | Report FUNCTION ... ENDFUNCTION modules with an empty body (default enabled; function modules are not available in ABAP Cloud). |

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC NO_EMPTY_PROC

" SAP CI_ prefix format:
... "#EC CI_NO_EMPTY_PROC
```

### Which procedures are checked

| Procedure kind | Attribute | Default |
| --- | --- | --- |
| `METHOD ... ENDMETHOD` | `CHECK_METHODS` | on |
| `FORM ... ENDFORM` | `CHECK_FORMS` | on |
| `FUNCTION ... ENDFUNCTION` | `CHECK_FUNCS` | on |

A procedure counts as empty when its inspected statement block contains at most two statements - the opening and the closing keyword. Comments are not statements, so a body that only holds a placeholder such as `"TODO: implement` is reported as well; that is exactly the case the rule wants to surface.

Not reported: interface method declarations (they have no body) and any procedure kind outside the table above, for example a class constructor pool entry that is generated.

### Choosing the fix

- **Delete** the procedure and its callers when it is dead - that also removes the false impression of an extension point.
- **Implement** the behaviour when the declaration is part of an interface contract.
- **Make the hook explicit**: add a documented `RETURN.` to a deliberate no-op hook so the intent is visible and the body is no longer empty.

Suppressions use `"#EC NO_EMPTY_PROC` on the procedure header statement.


## Related Rules

* [Avoid Empty Control Blocks in Branching and Looping Statements](/rules/no-empty-block) — <code>#EC NO_EMPTY_BLOCK</code>
* [Eliminate Unreachable Dead Code Caused by Constant False Conditions](/rules/no-dead-code) — <code>#EC NO_DEAD_CODE</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_NO_EMPTY_PROC`
* **ABAP Implementation:** [/skyl/cl_no_empty_proc.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_no_empty_proc.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 4744)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L4744)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_NO_EMPTY_PROC&title=%5BBug%5D%3A%20Issue%20in%20no-empty-proc)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20no-empty-proc)**
