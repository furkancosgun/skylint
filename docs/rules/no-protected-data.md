---
title: "Keep Class Attributes Private Instead of Protected"
description: "Report DATA and CLASS-DATA declared in the PROTECTED SECTION of ABAP classes - enforce private attributes and accessor methods for real encapsulation."
keywords: "ABAP protected attributes, class encapsulation, no-protected-data, Clean ABAP classes, SAP ATC"
category: "clean-abap"
ruleId: "no-protected-data"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L4997"
---

# Keep Class Attributes Private Instead of Protected

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="danger" text="#EC NO_PROTECTED_DATA" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L4997" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Avoid declaring DATA or CLASS-DATA in PROTECTED SECTION.

> **ATC Finding Message:** `Avoid protected attributes; make them private and provide methods instead`

## Rationale

Protected attributes are the weakest form of encapsulation: invisible to clients but fully readable and writable by every subclass, so an inherited class can bypass the validation, invariants and change notifications the superclass implements. Clean ABAP therefore asks for private attributes plus protected or public accessor methods that the owner still controls. The check walks the CLASS DEFINITION statement stream, tracks the active visibility section and reports NO_PROTDAT for every DATA or CLASS-DATA declared while PROTECTED SECTION is open. Protected methods, types and constants stay allowed because they are the intended extension contract for subclasses.

### Non-Compliant

```abap
CLASS zcl_pricing_engine DEFINITION
  PUBLIC
  CREATE PUBLIC.
  PUBLIC SECTION.
    METHODS calculate_price.
  PROTECTED SECTION.
    DATA mv_discount_rate TYPE decfloat34.
ENDCLASS.
```

### Compliant

```abap
CLASS zcl_pricing_engine DEFINITION
  PUBLIC
  CREATE PUBLIC.
  PUBLIC SECTION.
    METHODS calculate_price.
  PROTECTED SECTION.
    METHODS get_discount_rate
      RETURNING VALUE(rv_rate) TYPE decfloat34.
  PRIVATE SECTION.
    DATA mv_discount_rate TYPE decfloat34.
ENDCLASS.
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC NO_PROTECTED_DATA

" SAP CI_ prefix format:
... "#EC CI_NO_PROTECTED_DATA
```

## Detected declarations

| Declaration in `PROTECTED SECTION` | Reported |
| --- | --- |
| `DATA` | yes |
| `CLASS-DATA` | yes |
| `TYPES`, `CONSTANTS`, `METHODS` | no |

`DATA` in `PUBLIC SECTION` or `PRIVATE SECTION` is not part of this rule.

## Notes

- The check follows the section statements in document order, so a class that re-opens `PROTECTED SECTION` further down is still analyzed correctly.
- A `FINAL` class cannot be inherited, so `PROTECTED SECTION` should not exist there at all - remove the section instead of suppressing the finding.
- Sharing state with subclasses is better expressed through a protected getter (`RETURNING` a read-only copy) and a protected hook method the superclass calls itself.
- Suppress legacy code with `"#EC NO_PROTECTED_DATA` on the offending `DATA` statement.


## Related Rules

* [Encapsulate Public Class Attributes and Interface Variables](/rules/no-exposed-data) — <code>#EC PUBLIC_ATTR</code>
* [Limit Class Member Attribute Count to Prevent God Objects](/rules/max-attributes) — <code>#EC MAX_ATTRIBUTES</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_NO_PROTECTED_DATA`
* **ABAP Implementation:** [/skyl/cl_no_protected_data.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_no_protected_data.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 4997)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L4997)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_NO_PROTECTED_DATA&title=%5BBug%5D%3A%20Issue%20in%20no-protected-data)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20no-protected-data)**
