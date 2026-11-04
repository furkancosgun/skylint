---
title: "Use Enumerated Types Instead of Structured Constants"
description: "Replace structured CONSTANTS value sets with typed ABAP ENUM definitions - compiler-checked status values for Clean ABAP and ABAP Cloud development."
keywords: "ABAP ENUM, BEGIN OF ENUM, structured constants, pref-enum, Clean ABAP"
category: "clean-abap"
ruleId: "pref-enum"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L4970"
---

# Use Enumerated Types Instead of Structured Constants

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="danger" text="#EC PREF_ENUM" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L4970" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Prefer ENUM over CONSTANTS for set of related values.

> **ATC Finding Message:** `Prefer ENUM over CONSTANTS for set of related values`

## Rationale

A structured CONSTANTS block describes a value set but keeps the type system out of the decision: every component is an independent constant, any value of the base type can be assigned to the variable, and nothing prevents mixing members of two unrelated groups. An enumerated type declared with TYPES BEGIN OF ENUM creates one dedicated type whose only valid values are the enumerated constants, so the compiler rejects cross-family assignments and every consumer sees the closed value set in the signature. The check reports PREF_ENUM for every CONSTANTS statement that contains both BEGIN and OF, pointing maintainers to the ABAP 7.51 enum syntax that is also fully supported in ABAP Cloud. Single scalar constants stay untouched because they are a legitimate, non-structured declaration.

### Non-Compliant

```abap
CONSTANTS:
  BEGIN OF c_order_status,
    created  TYPE string VALUE 'CREATED',
    released TYPE string VALUE 'RELEASED',
    closed   TYPE string VALUE 'CLOSED',
  END OF c_order_status.
```

### Compliant

```abap
TYPES:
  BEGIN OF ENUM ty_order_status,
    created,
    released,
    closed,
  END OF ENUM ty_order_status.

DATA lv_order_status TYPE ty_order_status.
lv_order_status = released.
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC PREF_ENUM

" SAP CI_ prefix format:
... "#EC CI_PREF_ENUM
```

## What is reported

The check fires on any `CONSTANTS` declaration that contains both `BEGIN` and `OF`, i.e. every structure-shaped constant definition:

```abap
CONSTANTS: BEGIN OF c_order_status, created TYPE string VALUE 'CREATED', END OF c_order_status.
```

Single, non-structured declarations such as `CONSTANTS c_max_retries TYPE i VALUE 3.` are never reported.

## Preferred alternative

```abap
TYPES:
  BEGIN OF ENUM ty_order_status,
    created,
    released,
    closed,
  END OF ENUM ty_order_status.
```

| Advantage | Effect |
| --- | --- |
| Dedicated type | `ty_order_status` appears in the signature instead of `string`/`i` |
| Compiler check | assigning `released` to a `ty_payment_status` variable fails at compile time |
| Closed set | SE11/ADT display all legal values in one place |

Values that come from Customizing should stay a domain with fixed values or a CDS domain; an enum is the right tool only for a set that is fixed in the code.


## Related Rules

* [Replace Unexplained Magic Numbers with Named Constants](/rules/no-magic-numbers) — <code>#EC NO_MAGIC_NUMBERS</code>
* [Avoid Reading Environment and Landscape System Fields](/rules/no-hardcoded-env) — <code>#EC NO_HARDCODED_ENV</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_PREF_ENUM`
* **ABAP Implementation:** [/skyl/cl_pref_enum.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_pref_enum.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 4970)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L4970)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_PREF_ENUM&title=%5BBug%5D%3A%20Issue%20in%20pref-enum)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20pref-enum)**
