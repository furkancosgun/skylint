---
title: "Assign Distinct Error Numbers in Classic Function EXCEPTIONS Clauses"
description: "Prevent overlapping exception return numbers in ABAP classic CALL FUNCTION calls to ensure reliable sy-subrc error handling."
keywords: "no-exc-overlap, Clean ABAP, CALL FUNCTION, EXCEPTIONS clause, sy-subrc, SAP ATC"
category: "anti-patterns"
ruleId: "no-exc-overlap"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L2928"
---

# Assign Distinct Error Numbers in Classic Function EXCEPTIONS Clauses

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Anti-Patterns & Bad Practices" />
  <Badge type="danger" text="#EC NO_EXC_OVERLAP" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L2928" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Classic EXCEPTIONS must not overlap.

> **ATC Finding Message:** `Two classic exceptions share the same error number`

## Rationale

When multiple classic exceptions in a CALL FUNCTION or CALL METHOD statement map to the same numeric return code, the caller cannot distinguish between different failure reasons when evaluating sy-subrc. This masks critical system errors, impedes accurate logging and diagnostic analysis, and turns error handling into guesswork. Clean ABAP requires assigning distinct return codes to every specific exception and reserving a unique code for OTHERS. The ATC rule detects duplicate numeric error codes and reports NO_EXC_OVL.

### Non-Compliant

```abap
CALL FUNCTION 'CONVERT_TO_LOCAL_CURRENCY'
  EXPORTING
    date             = sy-datum
    foreign_amount   = lv_foreign_amount
    foreign_currency = lv_foreign_currency
    local_currency   = lv_local_currency
  IMPORTING
    local_amount     = lv_local_amount
  EXCEPTIONS
    no_rate_found    = 1
    overflow         = 1
    OTHERS           = 2.
```

### Compliant

```abap
CALL FUNCTION 'CONVERT_TO_LOCAL_CURRENCY'
  EXPORTING
    date             = sy-datum
    foreign_amount   = lv_foreign_amount
    foreign_currency = lv_foreign_currency
    local_currency   = lv_local_currency
  IMPORTING
    local_amount     = lv_local_amount
  EXCEPTIONS
    no_rate_found    = 1
    overflow         = 2
    OTHERS           = 3.
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC NO_EXC_OVERLAP

" SAP CI_ prefix format:
... "#EC CI_NO_EXC_OVERLAP
```

## Detection Details

The check scans `CALL FUNCTION` and `CALL METHOD` invocations that define an `EXCEPTIONS` block. It parses each literal return number assigned to an exception name. If the same numeric literal is assigned to multiple exception entries, the duplicate token is reported with finding code `NO_EXC_OVL`.

### Best Practice
Assign incrementing numbers starting from 1 to each named exception, and assign the highest distinct integer to `OTHERS`. In modern ABAP Cloud code, favor class-based exceptions over classic exceptions altogether.

### Suppression
Suppress findings with `"#EC NO_EXC_OVERLAP`.


## Related Rules

* [Prefer Class-Based Exceptions over Classic EXCEPTIONS](/rules/pref-class-exc) — <code>#EC PREF_CLASS_EXC</code>
* [Avoid Generic CATCH cx_root and Catch Specific Exceptions](/rules/no-catch-root) — <code>#EC NO_CATCH_ROOT</code>
* [Avoid Raising System Exceptions Directly (cx_sy_*)](/rules/no-raise-cx-sy) — <code>#EC NO_RAISE_CX_SY</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_NO_EXC_OVERLAP`
* **ABAP Implementation:** [/skyl/cl_no_exc_overlap.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_no_exc_overlap.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 2928)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L2928)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_NO_EXC_OVERLAP&title=%5BBug%5D%3A%20Issue%20in%20no-exc-overlap)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20no-exc-overlap)**
