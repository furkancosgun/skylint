---
title: "Classic EXCEPTIONS must not map two errors to the same number"
description: "Classic EXCEPTIONS must not map two errors to the same number - Clean ABAP guidelines, modern SAP syntax rules, and automated ATC code inspection for SAP S/4HANA and ABAP Cloud."
keywords: "Clean ABAP, SAP ATC Check, ABAP Cloud, S/4HANA Readiness, no-exc-overlap, anti-patterns"
category: "anti-patterns"
ruleId: "no-exc-overlap"
---

# Classic EXCEPTIONS must not map two errors to the same number

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Anti-Patterns & Bad Practices" />
  <Badge type="danger" text="#EC NO_EXC_OVERLAP" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Classic EXCEPTIONS must not overlap.

> **ATC Finding Message:** `Two classic exceptions share the same error number`

## Rationale

When two classic exceptions map to the same sy-subrc number, the caller cannot tell which failure occurred. This makes error handling guesswork and can hide the real cause. Assign distinct numbers and reserve OTHERS for unexpected failures.

### Non-Compliant

```abap
CALL FUNCTION 'Z_PROCESS_ORDER'
  EXCEPTIONS
    system_failure        = 1 MESSAGE lv_message
    communication_failure = 1 MESSAGE lv_message
    OTHERS                = 1.
```

### Compliant

```abap
CALL FUNCTION 'Z_PROCESS_ORDER'
  EXCEPTIONS
    system_failure        = 1 MESSAGE lv_message
    communication_failure = 2 MESSAGE lv_message
    OTHERS                = 3.
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC NO_EXC_OVERLAP

" SAP CI_ prefix format:
... "#EC CI_NO_EXC_OVERLAP
```


## Related Rules

* [Prefer Class-Based Exceptions over Classic EXCEPTIONS](/rules/pref-class-exc) — <code>#EC PREF_CLASS_EXC</code>
* [Avoid Catching Generic CX_ROOT (Catch Specific Exceptions)](/rules/no-catch-root) — <code>#EC NO_CATCH_ROOT</code>
* [Avoid Raising System Exceptions Directly (CX_SY_*)](/rules/no-raise-cx-sy) — <code>#EC NO_RAISE_CX_SY</code>

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_NO_EXC_OVERLAP`
* **Implementation File:** [zcl_skylint_no_exc_overlap.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_no_exc_overlap.clas.abap)
