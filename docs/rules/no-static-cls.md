---
title: "Design Classes with Instance Methods and Interfaces Instead of Static-Only Utilities"
description: "Prevent purely static utility classes in ABAP Cloud to enable dependency injection, interface contracts, and unit test mocking."
keywords: "no-static-cls, Clean ABAP, ABAP Cloud, SAP ATC, dependency injection, testability"
category: "anti-patterns"
ruleId: "no-static-cls"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L2217"
---

# Design Classes with Instance Methods and Interfaces Instead of Static-Only Utilities

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Anti-Patterns & Bad Practices" />
  <Badge type="danger" text="#EC NO_STATIC_CLS" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L2217" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Avoid static-only classes; use instantiable classes.

> **ATC Finding Message:** `Avoid static-only classes; declare instance methods and interfaces`

## Rationale

Classes containing exclusively static methods violate object-oriented design and testability principles because static operations cannot be substituted via dependency injection or mocked with test doubles during unit tests. In ABAP Cloud and Clean ABAP, components must expose behaviors through interface contracts and instantiable classes to ensure high testability, isolated state, and lifecycle management under Cloud Contract C1. The ATC finding code NO_STAT_CL reports class definitions that lack instance methods.

### Non-Compliant

```abap
CLASS zcl_invoice_calculator DEFINITION PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    CLASS-METHODS calculate_tax
      IMPORTING iv_net_amount TYPE decfloat34
      RETURNING VALUE(rv_tax) TYPE decfloat34.
    CLASS-METHODS format_amount
      IMPORTING iv_amount         TYPE decfloat34
      RETURNING VALUE(rv_display) TYPE string.
ENDCLASS.
```

### Compliant

```abap
CLASS zcl_invoice_calculator DEFINITION PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    METHODS calculate_tax
      IMPORTING iv_net_amount TYPE decfloat34
      RETURNING VALUE(rv_tax) TYPE decfloat34.
    METHODS format_amount
      IMPORTING iv_amount         TYPE decfloat34
      RETURNING VALUE(rv_display) TYPE string.
ENDCLASS.
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC NO_STATIC_CLS

" SAP CI_ prefix format:
... "#EC CI_NO_STATIC_CLS
```

## Detection Details

The rule evaluates class definitions (`procedure_kinds-class_definition`) and counts static method declarations versus instance method declarations. If a class declares one or more `CLASS-METHODS` (excluding `CLASS_CONSTRUCTOR`) but zero instance `METHODS` (excluding `CONSTRUCTOR`), it is flagged with `NO_STAT_CL`.

### Clean Architecture Pattern
Replace utility classes with instantiable domain services implementing an interface. Callers then receive instances via constructor injection, enabling seamless test substitution with test doubles.

### Suppression
Suppress findings using the pseudo comment `"#EC NO_STATIC_CLS`.


## Related Rules

* [Call Static Methods with Class Component Selector (=>)](/rules/no-static-arrow) — <code>#EC NO_STATIC_ARROW</code>
* [Design for Inheritance or Prohibit It with FINAL](/rules/pref-final-cls) — <code>#EC PREF_FINAL_CLASS</code>
* [Encapsulate Public Class Attributes and Interface Variables](/rules/no-exposed-data) — <code>#EC PUBLIC_ATTR</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_NO_STATIC_CLS`
* **ABAP Implementation:** [/skyl/cl_no_static_cls.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_no_static_cls.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 2217)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L2217)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_NO_STATIC_CLS&title=%5BBug%5D%3A%20Issue%20in%20no-static-cls)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20no-static-cls)**
