---
title: "Separate Functional RETURNING Parameters from EXPORTING and CHANGING Outputs"
description: "Enforce Command-Query Separation in ABAP method signatures by disallowing RETURNING alongside EXPORTING or CHANGING."
keywords: "no-mix-returning, Clean ABAP, ABAP Cloud, RETURNING parameter, CQS, SAP ATC"
category: "anti-patterns"
ruleId: "no-mix-returning"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L3198"
---

# Separate Functional RETURNING Parameters from EXPORTING and CHANGING Outputs

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Anti-Patterns & Bad Practices" />
  <Badge type="danger" text="#EC NO_MIX_RETURNING" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L3198" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Do not mix RETURNING with EXPORTING or CHANGING.

> **ATC Finding Message:** `Do not mix RETURNING with EXPORTING or CHANGING parameters in a single method`

## Rationale

A method signature combining a RETURNING parameter with EXPORTING or CHANGING parameters violates the Command-Query Separation (CQS) principle. Functional methods in Clean ABAP and ABAP Cloud are intended for expression-oriented evaluation; mixing side-effect parameter exports forces callers into cumbersome syntax and obscures whether a method performs a pure query or mutates state. Methods should either return a single value/structure functionally or act as a procedural command with output parameters. The check emits NO_MIX_RET.

### Non-Compliant

```abap
CLASS zcl_pricing_calculator DEFINITION PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    METHODS calculate_discount
      IMPORTING iv_customer_id TYPE kunnr
      EXPORTING ev_discount_rate TYPE decfloat34
      RETURNING VALUE(rv_final_price) TYPE decfloat34.
ENDCLASS.
```

### Compliant

```abap
CLASS zcl_pricing_calculator DEFINITION PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    METHODS calculate_discount
      IMPORTING iv_customer_id TYPE kunnr
      RETURNING VALUE(rv_final_price) TYPE decfloat34.
ENDCLASS.
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC NO_MIX_RETURNING

" SAP CI_ prefix format:
... "#EC CI_NO_MIX_RETURNING
```

## Command-Query Separation (CQS)

In Clean ABAP, methods with a `RETURNING` parameter are expected to behave as functional queries without side-effect output parameters. When multiple results must be returned functionally, package them into a structured type or class object instead of mixing parameter kinds.

### Detection Details
The rule inspects method signatures in class definitions (`METHODS` and `CLASS-METHODS`). If a signature contains the token `RETURNING` alongside `EXPORTING` or `CHANGING`, it reports `NO_MIX_RET`.

### Suppression
Suppress findings with pseudo comment `"#EC NO_MIX_RETURNING`.


## Related Rules

* [Use RETURNING Instead of a Single EXPORTING Parameter](/rules/pref-returning) — <code>#EC PREF_RETURNING</code>
* [Omit Redundant EXPORTING Keyword in Method Invocations](/rules/no-call-exporting) — <code>#EC NO_CALL_EXPORTING</code>
* [Capture and Consume Return Values of Functional Method Calls](/rules/no-ignored-return) — <code>#EC NO_IGNORED_RETURN</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_NO_MIX_RETURNING`
* **ABAP Implementation:** [/skyl/cl_no_mix_returning.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_no_mix_returning.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 3198)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L3198)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_NO_MIX_RETURNING&title=%5BBug%5D%3A%20Issue%20in%20no-mix-returning)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20no-mix-returning)**
