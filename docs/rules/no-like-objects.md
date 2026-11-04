---
title: "Declare Data Objects with Explicit TYPE Instead of LIKE"
description: "Enforce explicit TYPE definitions over LIKE references in ABAP Cloud declarations according to Clean ABAP and SAP ATC standards."
keywords: "no-like-objects, Clean ABAP, ABAP Cloud, SAP ATC, explicit TYPE, data declaration"
category: "anti-patterns"
ruleId: "no-like-objects"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L2188"
---

# Declare Data Objects with Explicit TYPE Instead of LIKE

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Anti-Patterns & Bad Practices" />
  <Badge type="danger" text="#EC NO_LIKE_OBJECTS" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L2188" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Avoid LIKE referencing data objects; use explicit TYPE.

> **ATC Finding Message:** `Avoid LIKE for data declarations; specify TYPE explicitly`

## Rationale

Referencing other data objects via LIKE tightly couples variable declarations to local variable implementations or structure instances rather than semantic type definitions. In modern ABAP Cloud and Clean ABAP, explicit typing with TYPE ensures strong data integrity, eliminates unintended ripple effects when source variables change, and aligns with Cloud Contract C1 requirements for decoupled API contracts. The ATC finding code NO_LIKE_OB flags LIKE additions in DATA, TYPES, STATICS, and CONSTANTS statements.

### Non-Compliant

```abap
DATA lv_original_price TYPE decfloat34.
DATA lv_discounted_price LIKE lv_original_price.
```

### Compliant

```abap
DATA lv_discounted_price TYPE decfloat34.
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC NO_LIKE_OBJECTS

" SAP CI_ prefix format:
... "#EC CI_NO_LIKE_OBJECTS
```

## Detection Details

The check scans `DATA`, `TYPES`, `STATICS`, and `CONSTANTS` statements for the token lexeme `LIKE`. In ABAP Cloud development, declarations should reference explicit data types, data elements, or dictionary types via `TYPE` rather than mirroring the memory layout of sibling variables.

### Suppression
To suppress a finding, use the pseudo comment `"#EC NO_LIKE_OBJECTS` on the declaration statement.


## Related Rules

* [Enforce Standard Naming Conventions for Classes, Interfaces, Types and Global Objects](/rules/pref-name-objects) — <code>#EC PREF_NAME_OBJECTS</code>
* [Avoid Chained Declarations for Variables, Types, and Constants](/rules/no-chained-decl) — <code>#EC NO_CHAINED_DECL</code>
* [Avoid Chained Assignments Binding Multiple Targets Simultaneously](/rules/no-chained-assign) — <code>#EC NO_CHAINED_ASSIGN</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_NO_LIKE_OBJECTS`
* **ABAP Implementation:** [/skyl/cl_no_like_objects.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_no_like_objects.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 2188)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L2188)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_NO_LIKE_OBJECTS&title=%5BBug%5D%3A%20Issue%20in%20no-like-objects)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20no-like-objects)**
