---
title: "Avoid Directly Modifying System Fields (sy-subrc, sy-tabix)"
description: "Preserve kernel integrity in SAP ABAP by forbidding direct assignment to system fields like sy-subrc and sy-tabix."
keywords: "sy-subrc assignment ABAP, System fields modification SAP, Clean ABAP Code Integrity"
category: "security"
ruleId: "no-sy-modify"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L1774"
---

# Avoid Directly Modifying System Fields (sy-subrc, sy-tabix)

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Security & Robustness" />
  <Badge type="danger" text="#EC NO_SY_MODIFY" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L1774" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Avoid sy-* System Variable Modification.

> **ATC Finding Message:** `Avoid modifying system fields (sy-*); system variables are read-only`

## Rationale

System fields in the `sy` structure (`sy-subrc`, `sy-tabix`, `sy-index`, `sy-mandt`) are maintained exclusively by the ABAP C-kernel. Directly overwriting them in application code (e.g., `sy-subrc = 0.`) creates deceptive illusion of successful operations, hides runtime failures from subsequent check tools, and produces erratic debugger state.

### Non-Compliant

```abap
" Anti-pattern: Overwrites kernel state to trick caller
CALL FUNCTION 'SOME_LEGACY_FUNC'.
sy-subrc = 0. " Masked error!
```

### Compliant

```abap
" Clean ABAP: Return explicit boolean flag or raise exception
DATA lv_success TYPE abap_bool.
lv_success = call_legacy_func( ).
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC NO_SY_MODIFY

" SAP CI_ prefix format:
... "#EC CI_NO_SY_MODIFY
```


## Related Rules

* [Prefer the Short System Field Alias SY over SYST](/rules/pref-sy) — <code>#EC PREF_SY</code>
* [Avoid Obsolete Arithmetic and Assignment Statements](/rules/no-obs-arith) — <code>#EC NO_OBS_ARITH</code>
* [Avoid Obsolete Control Flow and Procedural Forms](/rules/no-obs-control) — <code>#EC NO_OBS_CONTROL</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_NO_SY_MODIFY`
* **ABAP Implementation:** [/skyl/cl_no_sy_modify.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_no_sy_modify.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 1774)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L1774)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_NO_SY_MODIFY&title=%5BBug%5D%3A%20Issue%20in%20no-sy-modify)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20no-sy-modify)**
