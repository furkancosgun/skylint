---
title: "Avoid LIKE Typing on Global Dictionary Objects"
description: "Avoid LIKE Typing on Global Dictionary Objects - Clean ABAP guidelines, modern SAP syntax rules, and automated ATC code inspection for SAP S/4HANA and ABAP Cloud."
keywords: "Clean ABAP, SAP ATC Check, ABAP Cloud, S/4HANA Readiness, no-like-objects, anti-patterns"
category: "anti-patterns"
ruleId: "no-like-objects"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L2156"
---

# Avoid LIKE Typing on Global Dictionary Objects

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Anti-Patterns & Bad Practices" />
  <Badge type="danger" text="#EC NO_LIKE_OBJECTS" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L2156" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Avoid LIKE referencing data objects; use explicit TYPE.

> **ATC Finding Message:** `Avoid LIKE for data declarations; specify TYPE explicitly`

## Rationale

LIKE copies the type of a data object, which couples the new declaration to an implementation detail rather than to a type contract. For Dictionary objects, TYPE references the type directly and stays stable when the referenced object changes. Use LIKE only for local data objects whose type is intentionally shared.

### Non-Compliant

```abap
DATA lv_material LIKE mara-matnr.
```

### Compliant

```abap
DATA lv_material TYPE mara-matnr.
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC NO_LIKE_OBJECTS

" SAP CI_ prefix format:
... "#EC CI_NO_LIKE_OBJECTS
```


## Related Rules

* [Enforce Class, Interface, Type and Object Naming Conventions](/rules/pref-name-objects) — <code>#EC PREF_NAME_OBJECTS</code>
* [Avoid Chained Declarations (DATA:, CONSTANTS:, TYPES:)](/rules/no-chained-decl) — <code>#EC NO_CHAINED_DECL</code>
* [Avoid Chained Assignments (a = b = c = 1)](/rules/no-chained-assign) — <code>#EC NO_CHAINED_ASSIGN</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_NO_LIKE_OBJECTS`
* **ABAP Implementation:** [/skyl/cl_no_like_objects.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_no_like_objects.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 2156)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L2156)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_NO_LIKE_OBJECTS&title=%5BBug%5D%3A%20Issue%20in%20no-like-objects)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20no-like-objects)**
