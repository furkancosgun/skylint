---
title: "Avoid Concrete Class References in Interfaces"
description: "Prevent interfaces from referencing concrete classes via RTTI inspection."
keywords: "Clean ABAP, interface class reference, no-intf-class-ref"
category: "clean-abap"
ruleId: "no-intf-class-ref"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L4652"
---

# Avoid Concrete Class References in Interfaces

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="danger" text="#EC NO_INTF_CLASS_REF" />
  <Badge type="warning" text="Local Only" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L4652" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Interfaces should not reference concrete classes.

> **ATC Finding Message:** `Interface references concrete class; use an interface reference instead`

## Rationale

Interfaces should adhere to the Dependency Inversion Principle and not couple directly to concrete class implementations. Use interface references instead.

### Non-Compliant

```abap
INTERFACE lif_demo.
  DATA mo_obj TYPE REF TO cl_concrete.
ENDINTERFACE.
```

### Compliant

```abap
INTERFACE lif_demo.
  DATA mo_obj TYPE REF TO if_contract.
ENDINTERFACE.
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC NO_INTF_CLASS_REF

" SAP CI_ prefix format:
... "#EC CI_NO_INTF_CLASS_REF
```


## Related Rules

* [Prefer Interface Segregation (Small, Focused Interfaces)](/rules/pref-intf-segreg) — <code>#EC PREF_INTF_SEGREG</code>
* [Avoid Exposed Mutable Data in Classes and Interfaces](/rules/no-exposed-data) — <code>#EC PUBLIC_ATTR</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_NO_INTF_CLASS_REF`
* **ABAP Implementation:** [/skyl/cl_no_intf_class_ref.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_no_intf_class_ref.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 4652)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L4652)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_NO_INTF_CLASS_REF&title=%5BBug%5D%3A%20Issue%20in%20no-intf-class-ref)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20no-intf-class-ref)**
