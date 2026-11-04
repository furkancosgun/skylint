---
title: "Use RETURNING Instead of a Single EXPORTING Parameter"
description: "Turn single-EXPORTING methods into functional RETURNING methods so callers can use them inside expressions and inline declarations."
keywords: "pref-returning, RETURNING parameter, functional methods, Clean ABAP, SAP ATC"
category: "clean-abap"
ruleId: "pref-returning"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L1813"
---

# Use RETURNING Instead of a Single EXPORTING Parameter

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="danger" text="#EC PREF_RETURNING" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L1813" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Prefer RETURNING over single EXPORTING.

> **ATC Finding Message:** `Prefer functional RETURNING parameter over single EXPORTING parameter`

## Rationale

A method with exactly one EXPORTING parameter forces every caller to declare a target variable and invoke the method as a standalone statement. A RETURNING parameter makes the method a value expression that can be inlined into assignments, constructor expressions, method arguments and test assertions. That shortens call sites, removes unused output variables, and keeps the data flow visible when the method is read on its own.

### Non-Compliant

```abap
CLASS zcl_invoice_calculator DEFINITION PUBLIC CREATE PUBLIC.
  PUBLIC SECTION.
    METHODS calculate_total
      IMPORTING iv_order_id TYPE i
      EXPORTING ev_total    TYPE i.
ENDCLASS.
```

### Compliant

```abap
CLASS zcl_invoice_calculator DEFINITION PUBLIC CREATE PUBLIC.
  PUBLIC SECTION.
    METHODS calculate_total
      IMPORTING iv_order_id TYPE i
      RETURNING VALUE(rv_total) TYPE i.
ENDCLASS.
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC PREF_RETURNING

" SAP CI_ prefix format:
... "#EC CI_PREF_RETURNING
```

### When the check stays silent

The check runs on the class definition part and raises `PREF_RETNG` only when a `METHODS` / `CLASS-METHODS` statement has an `EXPORTING` section with exactly one typed parameter. It deliberately ignores:

- constructors and `FOR TESTING` methods,
- methods that already declare `RETURNING` or `CHANGING`,
- `REDEFINITION` statements, because the signature is fixed by the superclass or interface.

Use `"#EC PREF_RETURNING` when an external interface or framework forces a single `EXPORTING` parameter.


## Related Rules

* [Separate Functional RETURNING Parameters from EXPORTING and CHANGING Outputs](/rules/no-mix-returning) — <code>#EC NO_MIX_RETURNING</code>
* [Capture and Consume Return Values of Functional Method Calls](/rules/no-ignored-return) — <code>#EC NO_IGNORED_RETURN</code>
* [Omit or Require Parameter Names in Method Calls](/rules/pref-param-name) — <code>#EC PREF_PARAM_NAME</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_PREF_RETURNING`
* **ABAP Implementation:** [/skyl/cl_pref_returning.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_pref_returning.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 1813)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L1813)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_PREF_RETURNING&title=%5BBug%5D%3A%20Issue%20in%20pref-returning)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20pref-returning)**
