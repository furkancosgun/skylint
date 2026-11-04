---
title: "Pass Importing Parameters by Reference to Avoid Value Copies"
description: "Improve SAP ABAP method performance by passing IMPORTING parameters by reference instead of using VALUE() deep copies."
keywords: "pref-pass-by-ref, pass by reference, VALUE importing, Clean ABAP methods, SAP ATC"
category: "performance"
ruleId: "pref-pass-by-ref"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L3015"
---

# Pass Importing Parameters by Reference to Avoid Value Copies

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Performance & Database" />
  <Badge type="warning" text="QuickFix Ready" />
  <Badge type="danger" text="#EC PREF_PASS_BY_REF" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L3015" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Slow Parameter Passing.

> **ATC Finding Message:** `Avoid pass-by-value for importing method parameters`

## Rationale

In ABAP Object-Oriented programming, method parameters are passed by reference by default (O(1) pointer transfer). Declaring an IMPORTING parameter with VALUE(iv_param) instructs the runtime kernel to allocate a fresh heap memory buffer and deep-copy the argument value upon entering the method. When passing internal tables, complex structures, or large strings across multiple call layers, pass-by-value causes severe memory inflation, CPU memory bus saturation, and garbage collection churn. In Clean ABAP and ABAP Cloud, IMPORTING parameters should always be passed by reference unless explicit local isolation is strictly required.

### Non-Compliant

```abap
CLASS lcl_sales_service DEFINITION.
  PUBLIC SECTION.
    METHODS process_orders
      IMPORTING
        VALUE(it_orders) TYPE string_table.
ENDCLASS.
```

### Compliant

```abap
CLASS lcl_sales_service DEFINITION.
  PUBLIC SECTION.
    METHODS process_orders
      IMPORTING
        it_orders TYPE string_table.
ENDCLASS.
```

## Automated QuickFix

This rule provides an **automated QuickFix** directly in Eclipse ABAP Development Tools (ADT):
1. Position the cursor on the flagged statement.
2. Press <kbd>Ctrl</kbd> + <kbd>1</kbd> (Quick Assist).
3. Select the automated refactoring to apply the clean syntax immediately.

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC PREF_PASS_BY_REF

" SAP CI_ prefix format:
... "#EC CI_PREF_PASS_BY_REF
```

### Detection Details

The check evaluates `METHODS` and `CLASS-METHODS` declarations within `CLASS ... DEFINITION` blocks. Any parameter in an `IMPORTING` section defined with `VALUE(...)` is flagged with finding code `PREF_PASRF`.

### When is Pass-by-Value Appropriate?

- **RETURNING Parameters:** By ABAP language specification, `RETURNING` parameters must always be passed by value.
- **RFC / Update Modules:** Remote function modules require value serialization across network boundaries.

### Quickfix

The `OMIT_VAL` quickfix automatically strips the `VALUE(...)` wrapper from the importing parameter definition, converting it to clean pass-by-reference.

Suppress legitimate pass-by-value requirements with the pseudo comment `"#EC PREF_PASS_BY_REF`.


## Related Rules

* [Limit Method Parameter Count and Keep One Parameter per Line](/rules/max-params) — <code>#EC MAX_PARAMS_COUNT</code>
* [Replace Obsolete CALL METHOD Statements with Functional Invocations](/rules/no-call-method) — <code>#EC NO_CALL_METHOD</code>
* [Omit Redundant EXPORTING Keyword in Method Invocations](/rules/no-call-exporting) — <code>#EC NO_CALL_EXPORTING</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_PREF_PASS_BY_REF`
* **ABAP Implementation:** [/skyl/cl_pref_pass_by_ref.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_pref_pass_by_ref.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 3015)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L3015)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_PREF_PASS_BY_REF&title=%5BBug%5D%3A%20Issue%20in%20pref-pass-by-ref)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20pref-pass-by-ref)**
