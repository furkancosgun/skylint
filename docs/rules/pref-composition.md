---
title: "Prefer Composition over Inheritance"
description: "Prefer Composition over Inheritance - Clean ABAP guidelines, modern SAP syntax rules, and automated ATC code inspection for SAP S/4HANA and ABAP Cloud."
keywords: "Clean ABAP, SAP ATC Check, ABAP Cloud, S/4HANA Readiness, pref-composition, clean-abap"
category: "clean-abap"
ruleId: "pref-composition"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L3923"
---

# Prefer Composition over Inheritance

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="danger" text="#EC PREF_COMPOSITION" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L3923" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Prefer composition over inheritance.

> **ATC Finding Message:** `Prefer composition over inheritance; only CX_* classes should inherit`

## Rationale

Inheritance creates tight coupling between subclasses and parent implementations, exposes internal state, and complicates refactoring. With the exception of exception hierarchies (CX_* classes) which require inheritance to participate in ABAP error handling, business objects should favor composition by holding references to collaborating classes and delegating tasks.

### Non-Compliant

```abap
CLASS lcl_order_processor DEFINITION INHERITING FROM lcl_order_validator.
ENDCLASS.
```

### Compliant

```abap
CLASS lcl_order_processor DEFINITION.
  PUBLIC SECTION.
    METHODS constructor IMPORTING io_validator TYPE REF TO lif_order_validator.
ENDCLASS.
```

## Configuration & Thresholds

This check can be fine-tuned directly in the ATC Check Variant Editor (`CHKV`) in Eclipse ADT:

| Parameter Name | Data Type | Default Value | Description & Guidance |
|---|---|:---:|---|
| `ALLOW_TEST_CLASSES` | `Boolean` | <code>false</code> | Allow class inheritance inside ABAP Unit test includes |

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC PREF_COMPOSITION

" SAP CI_ prefix format:
... "#EC CI_PREF_COMPOSITION
```


## Related Rules

* [Limit Class Inheritance Depth (Favor Composition over Inheritance)](/rules/max-inherit) — <code>#EC MAX_INHERIT</code>
* [Design for Inheritance or Prohibit It (FINAL)](/rules/pref-final-cls) — <code>#EC PREF_FINAL_CLASS</code>
* [Prefer NEW #( ) over CREATE OBJECT](/rules/pref-new-op) — <code>#EC PREF_NEW_OPERATOR</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_PREF_COMPOSITION`
* **ABAP Implementation:** [/skyl/cl_pref_composition.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_pref_composition.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 3923)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L3923)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_PREF_COMPOSITION&title=%5BBug%5D%3A%20Issue%20in%20pref-composition)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20pref-composition)**
