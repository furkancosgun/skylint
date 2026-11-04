---
title: "Declare OPTIONAL and DEFAULT Parameters Last"
description: "Enforce parameter order in ABAP method signatures: mandatory IMPORTING and CHANGING parameters before OPTIONAL and DEFAULT ones for predictable calls."
keywords: "ABAP OPTIONAL parameter, DEFAULT parameter order, method signature, pref-opt-last, Clean ABAP"
category: "clean-abap"
ruleId: "pref-opt-last"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L5898"
---

# Declare OPTIONAL and DEFAULT Parameters Last

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="danger" text="#EC PREF_OPTIONAL_LAST" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L5898" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Declare optional and default parameters last in methods.

> **ATC Finding Message:** `Declare mandatory parameters before OPTIONAL and DEFAULT parameters`

## Rationale

When an OPTIONAL or DEFAULT parameter precedes a mandatory one, callers must either use named parameter notation or fill the optional slot just to reach the required argument, which produces confusing positional calls and hides which values are really supplied. Keeping mandatory parameters first and optional ones last makes positional and named calls predictable and keeps the signature stable when a new optional parameter is appended. The check parses the IMPORTING and CHANGING sections of every METHODS and CLASS-METHODS statement and reports PREF_OPT_L on the first mandatory parameter that follows an optional or defaulted one. EXPORTING and RETURNING are ignored because they are always optional for the caller.

### Non-Compliant

```abap
CLASS zcl_order_service DEFINITION
  PUBLIC
  CREATE PUBLIC.
  PUBLIC SECTION.
    METHODS create_order
      IMPORTING
        iv_priority TYPE i OPTIONAL
        iv_customer TYPE kunnr.
ENDCLASS.
```

### Compliant

```abap
CLASS zcl_order_service DEFINITION
  PUBLIC
  CREATE PUBLIC.
  PUBLIC SECTION.
    METHODS create_order
      IMPORTING
        iv_customer TYPE kunnr
        iv_priority TYPE i OPTIONAL.
ENDCLASS.
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC PREF_OPTIONAL_LAST

" SAP CI_ prefix format:
... "#EC CI_PREF_OPTIONAL_LAST
```

## Scope

| Section | Inspected |
| --- | --- |
| `IMPORTING` | yes |
| `CHANGING` | yes |
| `EXPORTING` | no - always optional for the caller |
| `RETURNING` | no - single mandatory value |

- `OPTIONAL` and `DEFAULT` both count as optional; `DEFAULT` often hides the problem because callers can omit the value silently.
- The state resets per section, so an optional `EXPORTING` parameter never influences the `IMPORTING` order.
- Each mandatory parameter that follows an optional one is reported, so a signature with two violations produces two findings.
- Only class definition procedures are inspected; `FORM`/`FUNCTION` interfaces are not part of this rule.

## Notes

- `METHODS` and `CLASS-METHODS` are both analysed, and the finding points at the offending parameter token, not at the whole statement.
- Suppress a released API with `"#EC PREF_OPTIONAL_LAST` on the `METHODS` / `CLASS-METHODS` statement when its historical parameter order cannot change.
- Appending a new `OPTIONAL` parameter at the end is source-compatible for existing callers; inserting it in the middle is not.


## Related Rules

* [Omit or Require Parameter Names in Method Calls](/rules/pref-param-name) — <code>#EC PREF_PARAM_NAME</code>
* [One Parameter or Structure Component per Line](/rules/pref-param-1line) — <code>#EC PREF_PARAM_1LINE</code>
* [Limit Method Parameter Count and Keep One Parameter per Line](/rules/max-params) — <code>#EC MAX_PARAMS_COUNT</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_PREF_OPT_LAST`
* **ABAP Implementation:** [/skyl/cl_pref_opt_last.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_pref_opt_last.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 5898)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L5898)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_PREF_OPT_LAST&title=%5BBug%5D%3A%20Issue%20in%20pref-opt-last)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20pref-opt-last)**
