---
title: "Avoid Assignments Whose Value Is Never Read"
description: "Detect dead stores in ABAP: assignments that are overwritten before any read, wasting computation and hiding leftover refactoring artifacts."
keywords: "ABAP dead store, unused assignment ABAP, SAP ATC check dead store, Clean ABAP unused value, ABAP overwritten variable"
category: "anti-patterns"
ruleId: "no-dead-store"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L4487"
---

# Avoid Assignments Whose Value Is Never Read

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Anti-Patterns & Bad Practices" />
  <Badge type="danger" text="#EC NO_DEAD_STORE" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L4487" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Avoid assignments that are never read.

> **ATC Finding Message:** `This value is overwritten before it is read; remove the assignment or read it`

## Rationale

An assignment whose value is overwritten before any read computes a result nobody uses: the work, the helper call, and the temporary state are all wasted. Such dead stores usually survive a refactor that removed the consuming branch, and they mislead readers into believing the value matters. Either read the value or delete the assignment.

### Non-Compliant

```abap
lv_status = 'NEW'.
lv_status = 'DONE'.
WRITE lv_status.
```

### Compliant

```abap
lv_status = 'DONE'.
WRITE lv_status.
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC NO_DEAD_STORE

" SAP CI_ prefix format:
... "#EC CI_NO_DEAD_STORE
```


## Related Rules

* [Eliminate Unused Local Variables and Symbols](/rules/no-unused-vars) — <code>#EC NO_UNUSED_VARS</code>
* [Avoid Dead Code with Constant Conditions](/rules/no-dead-code) — <code>#EC NO_DEAD_CODE</code>
* [Prefer FINAL( ) over DATA( ) when the variable is never written again](/rules/pref-final-data) — <code>#EC PREF_FINAL_DATA</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_NO_DEAD_STORE`
* **ABAP Implementation:** [/skyl/cl_no_dead_store.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_no_dead_store.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 4487)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L4487)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_NO_DEAD_STORE&title=%5BBug%5D%3A%20Issue%20in%20no-dead-store)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20no-dead-store)**
