---
title: "Prefer Class-Based Exceptions over Classic EXCEPTIONS"
description: "Replace legacy EXCEPTIONS lists with RAISING of CX_ROOT subclasses so ABAP methods propagate typed, catchable class-based exceptions."
keywords: "pref-class-exc, class-based exceptions, RAISING, Clean ABAP, SAP S/4HANA"
category: "clean-abap"
ruleId: "pref-class-exc"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L1841"
---

# Prefer Class-Based Exceptions over Classic EXCEPTIONS

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="danger" text="#EC PREF_CLASS_EXC" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L1841" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Prefer Class-Based Exceptions over Classic EXCEPTIONS.

> **ATC Finding Message:** `Prefer class-based exceptions (RAISING) over classic EXCEPTIONS`

## Rationale

Classic exceptions report a failure only through sy-subrc and cannot carry a message object, context data or a stack trace. They are easy to ignore, they clutter every caller with CLEAR sy-subrc and MESSAGE ... RAISING idioms, and they do not propagate reliably through nested call stacks. Replacing EXCEPTIONS with RAISING forces callers into TRY ... CATCH with a typed CX_ROOT subclass, which is what ABAP Cloud and the RAP error handling model expect.

### Non-Compliant

```abap
CLASS zcl_vendor_reader DEFINITION PUBLIC CREATE PUBLIC.
  PUBLIC SECTION.
    METHODS read_vendor
      IMPORTING iv_vendor_id TYPE i
      EXCEPTIONS vendor_not_found.
ENDCLASS.
```

### Compliant

```abap
CLASS zcl_vendor_reader DEFINITION PUBLIC CREATE PUBLIC.
  PUBLIC SECTION.
    METHODS read_vendor
      IMPORTING iv_vendor_id TYPE i
      RAISING   zcx_vendor_not_found.
ENDCLASS.
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC PREF_CLASS_EXC

" SAP CI_ prefix format:
... "#EC CI_PREF_CLASS_EXC
```

### Scope

`PREF_CLEXC` is raised from the class definition part whenever a `METHODS` or `CLASS-METHODS` statement still contains an `EXCEPTIONS` addition. Replacing it with `RAISING` moves the handling to the caller:

```abap
METHODS read_vendor
  IMPORTING iv_vendor_id TYPE i
  RAISING   zcx_vendor_not_found.
```

Callers use `TRY ... CATCH zcx_vendor_not_found INTO DATA(lo_error)` instead of testing `sy-subrc`, so the message, previous exception and stack stay available. `RAISE EXCEPTION NEW` and `CATCH` are the modern counterparts; suppress a single declaration with `"#EC PREF_CLASS_EXC`.


## Related Rules

* [Assign Distinct Error Numbers in Classic Function EXCEPTIONS Clauses](/rules/no-exc-overlap) — <code>#EC NO_EXC_OVERLAP</code>
* [Avoid Generic CATCH cx_root and Catch Specific Exceptions](/rules/no-catch-root) — <code>#EC NO_CATCH_ROOT</code>
* [Avoid Raising System Exceptions Directly (cx_sy_*)](/rules/no-raise-cx-sy) — <code>#EC NO_RAISE_CX_SY</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_PREF_CLASS_EXC`
* **ABAP Implementation:** [/skyl/cl_pref_class_exc.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_pref_class_exc.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 1841)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L1841)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_PREF_CLASS_EXC&title=%5BBug%5D%3A%20Issue%20in%20pref-class-exc)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20pref-class-exc)**
