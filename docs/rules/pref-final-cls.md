---
title: "Design for Inheritance or Prohibit It with FINAL"
description: "Mark classes and methods FINAL by default so unintended inheritance and redefinition cannot break internal behaviour in ABAP Cloud."
keywords: "pref-final-cls, FINAL class, inheritance design, Clean ABAP, SAP ATC"
category: "clean-abap"
ruleId: "pref-final-cls"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L2100"
---

# Design for Inheritance or Prohibit It with FINAL

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="warning" text="QuickFix Ready" />
  <Badge type="danger" text="#EC PREF_FINAL_CLASS" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L2100" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Prefer FINAL classes and methods by default.

> **ATC Finding Messages:**
> - `Classes should be marked FINAL by default unless designed for inheritance`
> - `Declare method as FINAL if it is not intended to be redefined`

## Rationale

A class that was never designed for inheritance can still be subclassed, and subclasses silently depend on protected internals that later change. Marking the class FINAL prevents the fragile base class problem and documents that no extension point exists; marking individual methods FINAL protects redefinition when the class itself must stay inheritable. The check raises PREF_FCLS and PREF_FMETH separately, so a framework base class can be exempted while its methods are still locked down.

### Non-Compliant

```abap
CLASS zcl_customer_service DEFINITION PUBLIC CREATE PUBLIC.
  PUBLIC SECTION.
    METHODS execute.
ENDCLASS.
```

### Compliant

```abap
CLASS zcl_customer_service DEFINITION PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    METHODS execute.
ENDCLASS.
```

## Automated QuickFix

This rule provides an **automated QuickFix** directly in Eclipse ABAP Development Tools (ADT):
1. Position the cursor on the flagged statement.
2. Press <kbd>Ctrl</kbd> + <kbd>1</kbd> (Quick Assist).
3. Select the automated refactoring to apply the clean syntax immediately.

## Configuration & Thresholds

This check can be fine-tuned directly in the ATC Check Variant Editor (`CHKV`) in Eclipse ADT:

| Parameter Name | Data Type | Default Value | Description & Guidance |
|---|---|:---:|---|
| `CHECK_CLASSES` | `Boolean` | <code>true</code> | Report CLASS ... DEFINITION statements that are neither FINAL nor ABSTRACT nor TESTING. Disable when your framework requires inheritable base classes. |
| `CHECK_METHODS` | `Boolean` | <code>true</code> | Report METHODS statements that are not FINAL so redefinition is blocked by default. Constructors, abstract, redefined and FOR TESTING methods are skipped. |

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC PREF_FINAL_CLASS

" SAP CI_ prefix format:
... "#EC CI_PREF_FINAL_CLASS
```

### Finding codes and exceptions

| Code | Trigger |
| --- | --- |
| `PREF_FCLS` | `CLASS ... DEFINITION` without `FINAL`, `ABSTRACT` or `TESTING` |
| `PREF_FMETH` | `METHODS` inside a non-final class without `FINAL` |

The class finding is skipped for abstract classes and test classes; classes that inherit from a superclass are still reported, because `FINAL` documents that the new class is a leaf. The method finding skips constructors, abstract and redefined methods, interface implementations (`... FOR ...`) and methods with `DEFAULT` parameters. `CHECK_CLASSES` and `CHECK_METHODS` toggle the two checks independently, `ADDFINAL` inserts the addition as a QuickFix, and suppression uses `"#EC PREF_FINAL_CLASS` / `"#EC PREF_FINAL_METHOD`.


## Related Rules

* [Limit Class Inheritance Depth and Favor Object Composition](/rules/max-inherit) — <code>#EC MAX_INHERIT</code>
* [Name Static Factory Methods CREATE_* When They Return Their Own Class](/rules/pref-factory-name) — <code>#EC PREF_FACTORY_NAME</code>
* [Favor Object Composition and Delegation Over Class Inheritance](/rules/pref-composition) — <code>#EC PREF_COMPOSITION</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_PREF_FINAL_CLS`
* **ABAP Implementation:** [/skyl/cl_pref_final_cls.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_pref_final_cls.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 2100)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L2100)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_PREF_FINAL_CLS&title=%5BBug%5D%3A%20Issue%20in%20pref-final-cls)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20pref-final-cls)**
