---
title: "Avoid Method Names That Overwrite Built-in Functions"
description: "Avoid Method Names That Overwrite Built-in Functions - Clean ABAP guidelines, modern SAP syntax rules, and automated ATC code inspection for SAP S/4HANA and ABAP Cloud."
keywords: "Clean ABAP, SAP ATC Check, ABAP Cloud, S/4HANA Readiness, no-overw-builtin, anti-patterns"
category: "anti-patterns"
ruleId: "no-overw-builtin"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L3153"
---

# Avoid Method Names That Overwrite Built-in Functions

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Anti-Patterns & Bad Practices" />
  <Badge type="danger" text="#EC NO_OVERW_BUILTIN" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L3153" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Method name overwrites built-in SAP function.

> **ATC Finding Message:** `Method name overwrites built-in SAP function name`

## Rationale

Naming a method LINES, STRLEN, or XSDBOOL shadows a well-known built-in and makes the call site ambiguous. Readers cannot tell whether the built-in or the method is intended. Use a descriptive verb that does not collide with language functions.

### Non-Compliant

```abap
METHODS matches
  RETURNING VALUE(rv_result) TYPE abap_bool.
```

### Compliant

```abap
METHODS matches_pattern
  RETURNING VALUE(rv_result) TYPE abap_bool.
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC NO_OVERW_BUILTIN

" SAP CI_ prefix format:
... "#EC CI_NO_OVERW_BUILTIN
```


## Related Rules

* [Avoid Obsolete Dash (-) in Form Names](/rules/no-dash-in-form) — <code>#EC NO_DASH_IN_FORM</code>
* [Avoid Obsolete Arithmetic and Assignment Statements](/rules/no-obs-arith) — <code>#EC NO_OBS_ARITH</code>
* [Avoid Obsolete Control Flow and Procedural Forms](/rules/no-obs-control) — <code>#EC NO_OBS_CONTROL</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_NO_OVERW_BUILTIN`
* **ABAP Implementation:** [/skyl/cl_no_overw_builtin.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_no_overw_builtin.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 3153)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L3153)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_NO_OVERW_BUILTIN&title=%5BBug%5D%3A%20Issue%20in%20no-overw-builtin)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20no-overw-builtin)**
