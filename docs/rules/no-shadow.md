---
title: "Avoid Local Variables Shadowing Class Attributes"
description: "Avoid Local Variables Shadowing Class Attributes - Clean ABAP guidelines, modern SAP syntax rules, and automated ATC code inspection for SAP S/4HANA and ABAP Cloud."
keywords: "Clean ABAP, SAP ATC Check, ABAP Cloud, S/4HANA Readiness, no-shadow, anti-patterns"
category: "anti-patterns"
ruleId: "no-shadow"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L1602"
---

# Avoid Local Variables Shadowing Class Attributes

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Anti-Patterns & Bad Practices" />
  <Badge type="danger" text="#EC NO_SHADOW" />
  <Badge type="warning" text="Local Only" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L1602" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Avoid local variables shadowing class attributes.

> **ATC Finding Message:** `Local variable shadows a class attribute; rename it`

## Rationale

A local variable that repeats a class attribute name silently hides the member inside the method. Readers can no longer tell whether the code changes the object state or only a temporary copy, and a later refactoring may keep the wrong reference. Rename the local or use a distinct name that states its purpose.

### Non-Compliant

```abap
DATA mv_status TYPE string.
mv_status = 'OPEN'.
```

### Compliant

```abap
DATA lv_status TYPE string.
lv_status = 'OPEN'.
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC NO_SHADOW

" SAP CI_ prefix format:
... "#EC CI_NO_SHADOW
```


## Related Rules

* [Eliminate Unused Local Variables and Symbols](/rules/no-unused-vars) — <code>#EC NO_UNUSED_VARS</code>
* [Enforce Local Variable and Field-Symbol Naming Conventions](/rules/pref-naming-vars) — <code>#EC PREF_NAMING_VARS</code>
* [Enforce Class Attribute and Method Parameter Naming Conventions](/rules/pref-name-members) — <code>#EC PREF_NAME_MEMBERS</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_NO_SHADOW`
* **ABAP Implementation:** [/skyl/cl_no_shadow.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_no_shadow.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 1602)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L1602)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_NO_SHADOW&title=%5BBug%5D%3A%20Issue%20in%20no-shadow)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20no-shadow)**
