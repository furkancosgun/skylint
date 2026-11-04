---
title: "Declare Instance Constructor in PUBLIC SECTION Regardless of Instantiation Scope"
description: "Ensure instance constructors are declared in the PUBLIC SECTION for clean reflection, testing, and modern ABAP Cloud factory architectures."
keywords: "pref-pub-ctor, constructor, PUBLIC SECTION, CREATE PRIVATE, Clean ABAP"
category: "clean-abap"
ruleId: "pref-pub-ctor"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L3109"
---

# Declare Instance Constructor in PUBLIC SECTION Regardless of Instantiation Scope

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="danger" text="#EC PREF_PUB_CTOR" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L3109" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Declare Constructor in PUBLIC SECTION.

> **ATC Finding Message:** `Declare constructor in PUBLIC SECTION, even if class is CREATE PRIVATE`

## Rationale

Declaring the instance constructor in PROTECTED or PRIVATE sections hinders reflection, dependency injection frameworks, and test doubles. Even for singleton or factory patterns where class instantiation is restricted using CREATE PRIVATE or CREATE PROTECTED, the constructor itself should remain declared in the PUBLIC SECTION. The class header declaration already controls external instantiation permissions. Skylint flags any constructor declared under protected or private sections with PREF_PBCTR.

### Non-Compliant

```abap
CLASS zcl_invoice_factory DEFINITION PUBLIC CREATE PRIVATE.
  PRIVATE SECTION.
    METHODS constructor.
ENDCLASS.
```

### Compliant

```abap
CLASS zcl_invoice_factory DEFINITION PUBLIC CREATE PRIVATE.
  PUBLIC SECTION.
    METHODS constructor.
ENDCLASS.
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC PREF_PUB_CTOR

" SAP CI_ prefix format:
... "#EC CI_PREF_PUB_CTOR
```

## Scope and Architectural Intent

Class instantiation constraints should be governed exclusively by the class header attributes (`CREATE PUBLIC`, `CREATE PROTECTED`, or `CREATE PRIVATE`). Placing the constructor method declaration in the `PUBLIC SECTION` exposes its signature transparently to RTTI and testing frameworks while preserving strict instantiation boundaries.

Suppress findings using pseudo comment `"#EC PREF_PUB_CTOR`.


## Related Rules

* [Prefer NEW #( ) for Object Creation and RAISE EXCEPTION NEW](/rules/pref-new-op) — <code>#EC PREF_NEW_OPERATOR</code>
* [Name Static Factory Methods CREATE_* When They Return Their Own Class](/rules/pref-factory-name) — <code>#EC PREF_FACTORY_NAME</code>
* [Design for Inheritance or Prohibit It with FINAL](/rules/pref-final-cls) — <code>#EC PREF_FINAL_CLASS</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_PREF_PUB_CTOR`
* **ABAP Implementation:** [/skyl/cl_pref_pub_ctor.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_pref_pub_ctor.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 3109)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L3109)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_PREF_PUB_CTOR&title=%5BBug%5D%3A%20Issue%20in%20pref-pub-ctor)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20pref-pub-ctor)**
