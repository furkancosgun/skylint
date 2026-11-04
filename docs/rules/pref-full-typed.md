---
title: "Require Fully Typed Variables and Parameters"
description: "Require Fully Typed Variables and Parameters - Clean ABAP guidelines, modern SAP syntax rules, and automated ATC code inspection for SAP S/4HANA and ABAP Cloud."
keywords: "Clean ABAP, SAP ATC Check, ABAP Cloud, S/4HANA Readiness, pref-full-typed, clean-abap"
category: "clean-abap"
ruleId: "pref-full-typed"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L1658"
---

# Require Fully Typed Variables and Parameters

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="warning" text="QuickFix Ready" />
  <Badge type="danger" text="#EC PREF_FULL_TYPED" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L1658" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Enforce fully typed constant declarations.

> **ATC Finding Message:** `Constant declaration should explicitly specify TYPE`

## Rationale

Untyped constants and data objects receive an implicit type whose length and value range are easy to misjudge. A later change to the literal can silently truncate data or alter comparisons. Declare explicit TYPE and LENGTH so the contract is visible to readers and checked by the compiler.

### Non-Compliant

```abap
CONSTANTS c_status VALUE 'A'.
```

### Compliant

```abap
CONSTANTS c_status TYPE c LENGTH 1 VALUE 'A'.
```

## Automated QuickFix

This rule provides an **automated QuickFix** directly in Eclipse ABAP Development Tools (ADT):
1. Position the cursor on the flagged statement.
2. Press <kbd>Ctrl</kbd> + <kbd>1</kbd> (Quick Assist).
3. Select the automated refactoring to apply the clean syntax immediately.

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC PREF_FULL_TYPED

" SAP CI_ prefix format:
... "#EC CI_PREF_FULL_TYPED
```


## Related Rules

* [Eliminate Unused Local Variables and Symbols](/rules/no-unused-vars) — <code>#EC NO_UNUSED_VARS</code>
* [Avoid Hungarian Notation and Type Prefixes](/rules/no-hungarian) — <code>#EC NO_HUNGARIAN</code>
* [Enforce Local Variable and Field-Symbol Naming Conventions](/rules/pref-naming-vars) — <code>#EC PREF_NAMING_VARS</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_PREF_FULL_TYPED`
* **ABAP Implementation:** [/skyl/cl_pref_full_typed.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_pref_full_typed.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 1658)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L1658)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_PREF_FULL_TYPED&title=%5BBug%5D%3A%20Issue%20in%20pref-full-typed)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20pref-full-typed)**
