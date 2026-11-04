---
title: "Avoid Granting Friendship via FRIENDS in Class Definitions"
description: "Eliminate FRIENDS relationships in ABAP class definitions to preserve object encapsulation and clean interface contracts."
keywords: "no-friends, Clean ABAP, ABAP Cloud, encapsulation, object-oriented, SAP ATC"
category: "anti-patterns"
ruleId: "no-friends"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L2870"
---

# Avoid Granting Friendship via FRIENDS in Class Definitions

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Anti-Patterns & Bad Practices" />
  <Badge type="danger" text="#EC NO_FRIENDS" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L2870" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Avoid FRIENDS in class definitions.

> **ATC Finding Message:** `Avoid FRIENDS; expose behavior via public methods`

## Rationale

Declaring another class as a friend breaks fundamental encapsulation by granting external entities unrestricted access to private and protected attributes and internal methods. This creates hidden, tightly coupled bidirectional dependencies that make refactoring dangerous and unit testing brittle. Clean ABAP and ABAP Cloud architecture advocate for public interface contracts and dependency injection rather than bypassing encapsulation via FRIENDS. The ATC check reports NO_FRIENDS whenever a class definition declares friendship.

### Non-Compliant

```abap
CLASS zcl_invoice_service DEFINITION PUBLIC FINAL CREATE PUBLIC
  FRIENDS zcl_invoice_test_helper.
  PUBLIC SECTION.
    METHODS process_invoice.
ENDCLASS.
```

### Compliant

```abap
CLASS zcl_invoice_service DEFINITION PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    METHODS process_invoice.
ENDCLASS.
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC NO_FRIENDS

" SAP CI_ prefix format:
... "#EC CI_NO_FRIENDS
```

## Architectural Guidance

Granting friendship is often misused to allow test classes to inspect private state. In Clean ABAP, unit tests should verify behavior through public interfaces rather than inspecting internal state. For scenarios requiring test seams, use test injection or dependency injection rather than `FRIENDS`.

### Detection
The check inspects class definitions (`procedure_kinds-class_definition`) for the keyword token `FRIENDS`.

### Suppression
Suppress with pseudo comment `"#EC NO_FRIENDS`.


## Related Rules

* [Name Static Factory Methods CREATE_* When They Return Their Own Class](/rules/pref-factory-name) — <code>#EC PREF_FACTORY_NAME</code>
* [Limit Class Inheritance Depth and Favor Object Composition](/rules/max-inherit) — <code>#EC MAX_INHERIT</code>
* [Limit Class Member Attribute Count to Prevent God Objects](/rules/max-attributes) — <code>#EC MAX_ATTRIBUTES</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_NO_FRIENDS`
* **ABAP Implementation:** [/skyl/cl_no_friends.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_no_friends.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 2870)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L2870)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_NO_FRIENDS&title=%5BBug%5D%3A%20Issue%20in%20no-friends)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20no-friends)**
