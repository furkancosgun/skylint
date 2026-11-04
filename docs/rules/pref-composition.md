---
title: "Favor Object Composition and Delegation Over Class Inheritance"
description: "Favor composition over inheritance in Clean ABAP to decouple business objects and prevent fragile base classes in ABAP Cloud."
keywords: "pref-composition, composition over inheritance, INHERITING FROM, Clean ABAP, ABAP Cloud"
category: "clean-abap"
ruleId: "pref-composition"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L4019"
---

# Favor Object Composition and Delegation Over Class Inheritance

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="danger" text="#EC PREF_COMPOSITION" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L4019" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Prefer composition over inheritance.

> **ATC Finding Message:** `Prefer composition over inheritance; only CX_* classes should inherit`

## Rationale

Inheritance creates tight architectural coupling between subclasses and base implementations, exposes internal state, and frequently leads to the fragile base class problem. With the sole exception of CX_* exception hierarchies, which require inheritance to integrate with the ABAP runtime error system, business objects should favor composition by injecting collaborating interfaces and delegating responsibility. Skylint inspects class definitions containing INHERITING FROM and reports PREF_COMPO on non-exception classes.

### Non-Compliant

```abap
CLASS lcl_order_processor DEFINITION INHERITING FROM lcl_order_base.
  PUBLIC SECTION.
    METHODS process.
ENDCLASS.
```

### Compliant

```abap
CLASS lcl_order_processor DEFINITION FINAL.
  PUBLIC SECTION.
    METHODS constructor
      IMPORTING io_order_base TYPE REF TO lif_order_base.
    METHODS process.
ENDCLASS.
```

## Configuration & Thresholds

This check can be fine-tuned directly in the ATC Check Variant Editor (`CHKV`) in Eclipse ADT:

| Parameter Name | Data Type | Default Value | Description & Guidance |
|---|---|:---:|---|
| `ALLOW_TEST_CLASSES` | `Boolean` | <code>false</code> | Allow class inheritance inside ABAP Unit test classes defined with the FOR TESTING addition. |

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC PREF_COMPOSITION

" SAP CI_ prefix format:
... "#EC CI_PREF_COMPOSITION
```

## Scope and Allowed Exceptions

The check evaluates `CLASS ... DEFINITION` statements featuring the `INHERITING FROM` clause:

- **Exception Classes (`CX_*`):** Permitted to inherit because ABAP class-based exceptions must inherit from `cx_static_check`, `cx_root`, or intermediate exception classes.
- **Test Classes (`FOR TESTING`):** When configuration parameter `ALLOW_TEST_CLASSES` is set to `abap_true`, local unit test classes inheriting from shared test harnesses are permitted.
- **Business Objects:** All standard business and utility classes are flagged with finding code `PREF_COMPO` to encourage interface-based dependency injection.

Suppress findings with pseudo comment `"#EC PREF_COMPOSITION`.


## Related Rules

* [Limit Class Inheritance Depth and Favor Object Composition](/rules/max-inherit) — <code>#EC MAX_INHERIT</code>
* [Design for Inheritance or Prohibit It with FINAL](/rules/pref-final-cls) — <code>#EC PREF_FINAL_CLASS</code>
* [Prefer NEW #( ) for Object Creation and RAISE EXCEPTION NEW](/rules/pref-new-op) — <code>#EC PREF_NEW_OPERATOR</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_PREF_COMPOSITION`
* **ABAP Implementation:** [/skyl/cl_pref_composition.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_pref_composition.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 4019)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L4019)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_PREF_COMPOSITION&title=%5BBug%5D%3A%20Issue%20in%20pref-composition)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20pref-composition)**
