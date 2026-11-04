---
title: "Keep Concrete Class References Out of Interface Components"
description: "Stop ABAP interfaces from exposing concrete class references such as TYPE REF TO zcl_... and keep Dependency Inversion intact, verified through RTTI."
keywords: "ABAP interface design, Dependency Inversion ABAP, TYPE REF TO class, SAP ATC, no-intf-class-ref"
category: "clean-abap"
ruleId: "no-intf-class-ref"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L4776"
---

# Keep Concrete Class References Out of Interface Components

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="danger" text="#EC NO_INTF_CLASS_REF" />
  <Badge type="warning" text="Local Only" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L4776" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Interfaces should not reference concrete classes.

> **ATC Finding Message:** `Interface references concrete class; use an interface reference instead`

## Rationale

An interface that declares `TYPE REF TO zcl_concrete` creates a compile-time dependency on one implementation, so every consumer of the interface is coupled to that class and can no longer be tested with a lighter test double. Interface-typed components keep the Dependency Inversion Principle intact and let the runtime, a factory or dependency injection choose the implementation. The check resolves the referenced type through RTTI and reports only names that really denote a class, so interfaces and unresolved names stay clean.

### Non-Compliant

```abap
INTERFACE lif_document_printer.
  DATA mo_document TYPE REF TO cl_abap_typedescr.
ENDINTERFACE.
```

### Compliant

```abap
INTERFACE lif_document_printer.
  DATA mo_renderer TYPE REF TO lif_document_renderer.
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

### How the check decides

For every `TYPE REF TO <name>` inside an `INTERFACE ... ENDINTERFACE` block the rule resolves `<name>` via RTTI:

| Type behind `<name>` | Result |
| --- | --- |
| class (`CL_*`, `ZCL_*`, exception class) | `NO_CLS_REF` |
| interface (`IF_*`, `LIF_*`) | ok |
| the interface being declared (self reference) | ok - skipped explicitly |
| `TYPE REF TO object` | ok - skipped explicitly |
| unresolvable or not installed in the system | ok - nothing can be proven |

Only the first `TYPE REF TO` per statement is inspected, so declare one component per statement when you refactor an interface.

### Remote enablement

Because the decision needs runtime type information, the check declares `remote_enablement = abap_false`. In an ATC run against a remote system the local RTTI cannot see the remote classes and would produce wrong results, so the check is skipped there. Run it in the local system, or in a central check system that holds the same software component versions.


## Related Rules

* [Prefer Small, Role-Based Interfaces (Interface Segregation)](/rules/pref-intf-segreg) — <code>#EC PREF_INTF_SEGREG</code>
* [Encapsulate Public Class Attributes and Interface Variables](/rules/no-exposed-data) — <code>#EC PUBLIC_ATTR</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_NO_INTF_CLASS_REF`
* **ABAP Implementation:** [/skyl/cl_no_intf_class_ref.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_no_intf_class_ref.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 4776)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L4776)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_NO_INTF_CLASS_REF&title=%5BBug%5D%3A%20Issue%20in%20no-intf-class-ref)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20no-intf-class-ref)**
