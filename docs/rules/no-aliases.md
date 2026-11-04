---
title: "Avoid ALIASES and Reference Interface Components Explicitly"
description: "Remove ABAP ALIASES and require explicit lif_interface~component qualification at call sites and implementations for searchable, unambiguous code."
keywords: "ABAP ALIASES, interface component alias, lif~method qualification, SAP ATC, no-aliases"
category: "clean-abap"
ruleId: "no-aliases"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L4803"
---

# Avoid ALIASES and Reference Interface Components Explicitly

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="danger" text="#EC NO_ALIASES" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L4803" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Avoid using ALIASES in classes and interfaces.

> **ATC Finding Message:** `Do not use ALIASES; reference interface components explicitly`

## Rationale

An alias creates a second, unqualified name for the same component, so a search for the method finds the alias while the interface, the implementation and the caller use three different spellings. Aliases also hide which interface a method belongs to - exactly the information needed when two interfaces define a method with the same name. Writing `lif_printable~print( )` at the call site and `METHOD lif_printable~print.` in the implementation keeps one canonical name per capability and makes interface replacement a compile-time error instead of a silent rebinding.

### Non-Compliant

```abap
CLASS lcl_invoice_service DEFINITION.
  PUBLIC SECTION.
    INTERFACES lif_printable.
    ALIASES print FOR lif_printable~print.
ENDCLASS.
```

### Compliant

```abap
CLASS lcl_invoice_service DEFINITION.
  PUBLIC SECTION.
    INTERFACES lif_printable.
ENDCLASS.

CLASS lcl_invoice_service IMPLEMENTATION.
  METHOD lif_printable~print.
    render_invoice_pdf( ).
  ENDMETHOD.
ENDCLASS.
```

## Configuration & Thresholds

This check can be fine-tuned directly in the ATC Check Variant Editor (`CHKV`) in Eclipse ADT:

| Parameter Name | Data Type | Default Value | Description & Guidance |
|---|---|:---:|---|
| `IGNORE_PRIVATE` | `Boolean` | <code>false</code> | Skip ALIASES statements declared in a PRIVATE SECTION (default disabled, so every alias is reported). |

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC NO_ALIASES

" SAP CI_ prefix format:
... "#EC CI_NO_ALIASES
```

### Ignoring private aliases

`IGNORE_PRIVATE` (default off) skips `ALIASES` statements that appear after `PRIVATE SECTION` and before the next `PUBLIC SECTION` or `PROTECTED SECTION`. The section is tracked statement by statement, so the setting only helps when the alias really sits in the private section; a misplaced section header silently re-enables the finding.

### Why explicit qualification wins

| With alias | Without alias |
| --- | --- |
| `ALIASES print FOR lif_printable~print.` plus `print( ).` | `lif_printable~print( ).` |
| `ALIASES status FOR lif_state~status.` | `lif_state~status` |
| two interfaces both exposing `print` - alias collision | each call names its interface |

Explicit `interface~component` also survives interface replacement: when a component moves to another interface, the compiler points at every affected call site instead of quietly re-binding through an alias.

The check runs on class and interface definitions only, reports each `ALIASES` statement separately, and is token based (no RTTI), so it also works in remote ATC scenarios.


## Related Rules

* [Prefer Small, Role-Based Interfaces (Interface Segregation)](/rules/pref-intf-segreg) — <code>#EC PREF_INTF_SEGREG</code>
* [Keep Concrete Class References Out of Interface Components](/rules/no-intf-class-ref) — <code>#EC NO_INTF_CLASS_REF</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_NO_ALIASES`
* **ABAP Implementation:** [/skyl/cl_no_aliases.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_no_aliases.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 4803)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L4803)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_NO_ALIASES&title=%5BBug%5D%3A%20Issue%20in%20no-aliases)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20no-aliases)**
