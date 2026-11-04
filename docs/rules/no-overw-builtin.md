---
title: "Prevent Declaring Methods That Shadow Built-in ABAP Functions"
description: "Avoid method names that shadow standard ABAP built-in functions like lines, matches, and strlen in ABAP Cloud."
keywords: "no-overw-builtin, Clean ABAP, ABAP Cloud, built-in functions, method naming, SAP ATC"
category: "anti-patterns"
ruleId: "no-overw-builtin"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L3227"
---

# Prevent Declaring Methods That Shadow Built-in ABAP Functions

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Anti-Patterns & Bad Practices" />
  <Badge type="danger" text="#EC NO_OVERW_BUILTIN" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L3227" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Method name overwrites built-in SAP function.

> **ATC Finding Message:** `Method name overwrites built-in SAP function name`

## Rationale

Giving a custom method the same name as an ABAP built-in function (such as LINES, MATCHES, STRLEN, REPEAT, or XSDBOOL) creates severe naming ambiguity for developers and tools alike. At call sites, readers cannot easily distinguish whether the standard language built-in or the class method is invoked, which increases defect rates during maintenance. Clean ABAP mandates meaningful, domain-specific verb phrases for method names that do not collide with reserved language constructs. The ATC check scans method declarations and reports NO_OVR_BLT.

### Non-Compliant

```abap
CLASS zcl_text_processor DEFINITION PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    METHODS matches
      IMPORTING iv_pattern TYPE string
      RETURNING VALUE(rv_is_match) TYPE abap_bool.
ENDCLASS.
```

### Compliant

```abap
CLASS zcl_text_processor DEFINITION PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    METHODS matches_pattern
      IMPORTING iv_pattern TYPE string
      RETURNING VALUE(rv_is_match) TYPE abap_bool.
ENDCLASS.
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC NO_OVERW_BUILTIN

" SAP CI_ prefix format:
... "#EC CI_NO_OVERW_BUILTIN
```

## Evaluated Built-in Functions

The check maintains a catalog of 74 ABAP built-in functions, including:
- **String functions**: `STRLEN`, `MATCHES`, `MATCH`, `FIND`, `SUBSTRING`, `REPEAT`, `REPLACE`, `TO_UPPER`, `TO_LOWER`
- **Table functions**: `LINES`, `LINE_EXISTS`, `LINE_INDEX`
- **Boolean and conversion functions**: `XSDBOOL`, `BOOLC`, `BOOLX`
- **Math functions**: `ABS`, `CEIL`, `FLOOR`, `ROUND`, `TRUNC`, `SQRT`

Any `METHODS` or `CLASS-METHODS` declaration matching one of these names is flagged with finding code `NO_OVR_BLT`.

### Suppression
Suppress with pseudo comment `"#EC NO_OVERW_BUILTIN`.


## Related Rules

* [Use Underscores Instead of Hyphens in Subroutine FORM Names](/rules/no-dash-in-form) — <code>#EC NO_DASH_IN_FORM</code>
* [Replace Obsolete Arithmetic Statements with Modern Operators](/rules/no-obs-arith) — <code>#EC NO_OBS_ARITH</code>
* [Eliminate Obsolete Control Flow and Procedural Statements](/rules/no-obs-control) — <code>#EC NO_OBS_CONTROL</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_NO_OVERW_BUILTIN`
* **ABAP Implementation:** [/skyl/cl_no_overw_builtin.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_no_overw_builtin.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 3227)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L3227)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_NO_OVERW_BUILTIN&title=%5BBug%5D%3A%20Issue%20in%20no-overw-builtin)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20no-overw-builtin)**
