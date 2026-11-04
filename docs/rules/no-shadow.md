---
title: "Prevent Local Variables from Shadowing Class Attributes"
description: "Prevent local variables from shadowing class attributes to maintain clean variable scoping in ABAP Cloud."
keywords: "no-shadow, variable shadowing, class attributes, Clean ABAP, SAP ATC"
category: "anti-patterns"
ruleId: "no-shadow"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L1610"
---

# Prevent Local Variables from Shadowing Class Attributes

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Anti-Patterns & Bad Practices" />
  <Badge type="danger" text="#EC NO_SHADOW" />
  <Badge type="warning" text="Local Only" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L1610" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Avoid local variables shadowing class attributes.

> **ATC Finding Message:** `Local variable shadows a class attribute; rename it`

## Rationale

Declaring a local variable with the exact same name as an instance or static attribute of the enclosing class silently shadows the member attribute inside that method. This creates ambiguity during code reviews, as readers cannot readily distinguish between local variables and persistent class state, and increases the likelihood of serious bugs when refactoring logic. Clean ABAP requires distinct variable naming conventions (e.g. prefixing local variables with lv_ or using unique domain identifiers) to maintain transparent scoping in ABAP Cloud.

### Non-Compliant

```abap
DATA mv_delivery_date TYPE d.
mv_delivery_date = sy-datum.
```

### Compliant

```abap
DATA lv_delivery_date TYPE d.
lv_delivery_date = sy-datum.
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC NO_SHADOW

" SAP CI_ prefix format:
... "#EC CI_NO_SHADOW
```

### Shadowing Detection via RTTI

The check inspects data definitions inside method procedures and queries class attribute names via ABAP Run-Time Type Identification (RTTI):

- Resolves the containing class descriptor using `cl_abap_classdescr`.
- Compares local `DATA` and inline `DATA(...)` definitions against member attributes.
- Because RTTI requires local type descriptor resolution, this rule operates with `remote_enablement = abap_false`.

Suppress findings with `"#EC NO_SHADOW`.


## Related Rules

* [Remove Unread Local Variables and Field Symbols](/rules/no-unused-vars) — <code>#EC NO_UNUSED_VARS</code>
* [Enforce Configured Naming Conventions for Local Variables and Field-Symbols](/rules/pref-naming-vars) — <code>#EC PREF_NAMING_VARS</code>
* [Enforce Standard Naming Conventions for Class Members, Parameters and Screens](/rules/pref-name-members) — <code>#EC PREF_NAME_MEMBERS</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_NO_SHADOW`
* **ABAP Implementation:** [/skyl/cl_no_shadow.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_no_shadow.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 1610)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L1610)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_NO_SHADOW&title=%5BBug%5D%3A%20Issue%20in%20no-shadow)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20no-shadow)**
