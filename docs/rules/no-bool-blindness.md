---
title: "Replace Boolean Importing Parameters with Explicit APIs"
description: "Detect boolean flag IMPORTING parameters in ABAP method signatures and replace boolean blindness with dedicated, self-explanatory APIs."
keywords: "ABAP boolean parameter, boolean blindness, Clean ABAP method signature, SAP ATC, no-bool-blindness"
category: "clean-abap"
ruleId: "no-bool-blindness"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L4509"
---

# Replace Boolean Importing Parameters with Explicit APIs

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="danger" text="#EC NO_BOOL_BLINDNESS" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L4509" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Avoid boolean flag importing parameters.

> **ATC Finding Message:** `Boolean importing parameters hide intent; use dedicated methods or a typed flag`

## Rationale

An abap_bool IMPORTING parameter turns a call into a positional switch: `save_order( abap_true )` tells the reader nothing and reviewers must open the signature to learn what `true` does. It also grows into a parameter zoo - send_mail, skip_validation, commit - where every new variation edits the same method and every caller re-tests all combinations. Separate, well-named methods or a small typed mode keep each behaviour testable in isolation and make the call site self-documenting.

### Non-Compliant

```abap
CLASS lcl_order_service DEFINITION.
  PUBLIC SECTION.
    METHODS save_order
      IMPORTING send_confirmation TYPE abap_bool.
ENDCLASS.
```

### Compliant

```abap
CLASS lcl_order_service DEFINITION.
  PUBLIC SECTION.
    METHODS save_order.
    METHODS save_and_confirm_order.
ENDCLASS.
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC NO_BOOL_BLINDNESS

" SAP CI_ prefix format:
... "#EC CI_NO_BOOL_BLINDNESS
```

### What the check inspects

Only `METHODS` / `CLASS-METHODS` declarations inside class and interface definitions are inspected. `NO_BOOL_BL` is raised once per declaration when at least one `IMPORTING` parameter is typed `abap_bool`:

| Signature element | Reported |
| --- | --- |
| `IMPORTING iv_flag TYPE abap_bool` | yes |
| `IMPORTING iv_flag TYPE abap_bool DEFAULT abap_true` | yes |
| `EXPORTING ev_active TYPE abap_bool` | no |
| `RETURNING VALUE(rv_ok) TYPE abap_bool` | no |
| `CHANGING cv_flag TYPE abap_bool` | no |
| `IMPORTING iv_mode TYPE ty_dispatch_mode` (enum) | no |

### Acceptable alternatives

- **Two methods**: `save_order( )` and `save_and_confirm_order( )` - the usual Clean ABAP answer.
- **Typed flag**: a DDIC domain, enum or constants interface with meaningful values, so the call reads `process( mode = dispatch_immediately )` instead of `process( abap_true )`.
- **Collaborator**: move the optional behaviour into an injected service, which also keeps the method unit-testable.

Boolean `EXPORTING` and `RETURNING` values are fine because they are results, not switches. A wrapper around a legacy API that cannot change its signature can be suppressed with `"#EC NO_BOOL_BLINDNESS` on the `METHODS` statement.


## Related Rules

* [Use Predicate Naming (is_, has_, can_) for Boolean Methods](/rules/pref-pred-name) — <code>#EC PREF_PRED_NAME</code>
* [Avoid Comparing Boolean Method Calls to abap_true or abap_false](/rules/no-bool-compare) — <code>#EC NO_BOOL_COMPARE</code>
* [Limit Method Parameter Count and Keep One Parameter per Line](/rules/max-params) — <code>#EC MAX_PARAMS_COUNT</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_NO_BOOL_BLINDNESS`
* **ABAP Implementation:** [/skyl/cl_no_bool_blindness.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_no_bool_blindness.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 4509)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L4509)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_NO_BOOL_BLINDNESS&title=%5BBug%5D%3A%20Issue%20in%20no-bool-blindness)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20no-bool-blindness)**
