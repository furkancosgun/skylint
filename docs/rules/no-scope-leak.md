---
title: "Avoid Variable Scope Leaking from Inner Blocks"
description: "Avoid Variable Scope Leaking from Inner Blocks - Clean ABAP guidelines, modern SAP syntax rules, and automated ATC code inspection for SAP S/4HANA and ABAP Cloud."
keywords: "Clean ABAP, SAP ATC Check, ABAP Cloud, S/4HANA Readiness, no-scope-leak, anti-patterns"
category: "anti-patterns"
ruleId: "no-scope-leak"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L1545"
---

# Avoid Variable Scope Leaking from Inner Blocks

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Anti-Patterns & Bad Practices" />
  <Badge type="danger" text="#EC NO_SCOPE_LEAK" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L1545" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Avoid variable usage outside its declaring control block.

> **ATC Finding Message:** `Variable declared in inner block is referenced outside its scope`

## Rationale

A variable declared inside an IF or LOOP block is still visible after the block ends, so using it later creates a hidden dependency on whether the branch executed. This makes behavior hard to reason about and can leave the variable uninitialized. Declare the variable in the enclosing scope and assign it explicitly inside the branch.

### Non-Compliant

```abap
IF is_valid( ).
  DATA(lv_message) = |Order { lv_id }|.
ENDIF.
log_message( lv_message ).
```

### Compliant

```abap
DATA lv_message TYPE string.
IF is_valid( ).
  lv_message = |Order { lv_id }|.
ENDIF.
log_message( lv_message ).
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC NO_SCOPE_LEAK

" SAP CI_ prefix format:
... "#EC CI_NO_SCOPE_LEAK
```


## Related Rules

* [Prefer FINAL( ) over DATA( ) when the variable is never written again](/rules/pref-final-data) — <code>#EC PREF_FINAL_DATA</code>
* [Enforce Local Variable and Field-Symbol Naming Conventions](/rules/pref-naming-vars) — <code>#EC PREF_NAMING_VARS</code>
* [Avoid Single-Letter Variable Names](/rules/no-single-letter) — <code>#EC NO_SINGLE_LETTER</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_NO_SCOPE_LEAK`
* **ABAP Implementation:** [/skyl/cl_no_scope_leak.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_no_scope_leak.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 1545)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L1545)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_NO_SCOPE_LEAK&title=%5BBug%5D%3A%20Issue%20in%20no-scope-leak)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20no-scope-leak)**
