---
title: "Avoid Conflicting ABSTRACT and FINAL Class Modifiers"
description: "Prevent invalid ABSTRACT FINAL class definitions in ABAP OO, enforcing valid inheritance and instantiation contracts."
keywords: "ABSTRACT FINAL ABAP, class definition modifiers, ABAP OO architecture, Clean ABAP, SAP ATC check, no-abstract-final"
category: "anti-patterns"
ruleId: "no-abstract-final"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L4833"
---

# Avoid Conflicting ABSTRACT and FINAL Class Modifiers

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Anti-Patterns & Bad Practices" />
  <Badge type="danger" text="#EC NO_ABSTRACT_FINAL" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L4833" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

A class cannot be defined as both ABSTRACT and FINAL.

> **ATC Finding Message:** `Class cannot be both ABSTRACT and FINAL`

## Rationale

Declaring a class as both ABSTRACT and FINAL is an inherent contradiction in object-oriented architecture. An ABSTRACT class is incomplete by definition and cannot be directly instantiated, requiring subclasses to implement its contracts. Conversely, a FINAL class explicitly prohibits subclassing. A class marked with both modifiers cannot be instantiated or inherited from, rendering it unusable dead code.

### Non-Compliant

```abap
CLASS lcl_pricing_strategy DEFINITION ABSTRACT FINAL.
  PUBLIC SECTION.
    METHODS calculate_discount ABSTRACT.
ENDCLASS.
```

### Compliant

```abap
CLASS lcl_pricing_strategy DEFINITION ABSTRACT.
  PUBLIC SECTION.
    METHODS calculate_discount ABSTRACT.
ENDCLASS.
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC NO_ABSTRACT_FINAL

" SAP CI_ prefix format:
... "#EC CI_NO_ABSTRACT_FINAL
```

### Why ABSTRACT FINAL is invalid

In ABAP OO design, modifiers serve complementary but mutually exclusive purposes on class headers:

| Modifier | Intended Purpose | Direct Instantiation | Subclassing Allowed |
| --- | --- | --- | --- |
| `ABSTRACT` | Defines extensible base contract | No | Yes |
| `FINAL` | Locks class hierarchy against extension | Yes | No |
| `ABSTRACT FINAL` | Inherent contradiction | No | No (Unusable) |

For utility classes containing only static methods (`CLASS-METHODS`), use `CREATE PRIVATE` or `FINAL` without `ABSTRACT`, or prefer modern ABAP interfaces with stateless implementations.

### Suppression

If required by legacy code generation templates, suppress using `"#EC NO_ABSTRACT_FINAL`.


## Related Rules

* [Remove Empty Methods, Forms and Function Modules](/rules/no-empty-proc) — <code>#EC NO_EMPTY_PROC</code>
* [Eliminate Unreachable Dead Code Caused by Constant False Conditions](/rules/no-dead-code) — <code>#EC NO_DEAD_CODE</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_NO_ABSTRACT_FINAL`
* **ABAP Implementation:** [/skyl/cl_no_abstract_final.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_no_abstract_final.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 4833)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L4833)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_NO_ABSTRACT_FINAL&title=%5BBug%5D%3A%20Issue%20in%20no-abstract-final)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20no-abstract-final)**
