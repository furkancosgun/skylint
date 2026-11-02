---
title: "Raise At Most One Exception Class per Method"
description: "Raise at most one exception class per ABAP method - Clean ABAP exception design with a single exception type per method. Simplified error handling and automated ATC inspection for SAP S/4HANA and ABAP Cloud."
keywords: "Clean ABAP Exceptions, Raise Exception Type, Exception Class Design, Error Handling ABAP, ATC Code Review"
category: "clean-abap"
ruleId: "no-multi-exc"
---

# Raise At Most One Exception Class per Method

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="danger" text="#EC NO_MULTI_EXC" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Raise At Most One Exception Type per Method.

> **ATC Finding Message:** `Method raises several different exception classes - raise one type instead`

## Rationale

Throwing several different exception classes from one method forces each caller to nest separate TRY/CATCH blocks and duplicate handler logic. Define a single dedicated exception type per method's interface (or a single hierarchy family) so the caller can react with one handler; packing more error detail into the exception's attributes keeps the API stable. Clean ABAP (Throw one type of exception) recommends one main exception class per method.

### Non-Compliant

```abap
METHOD add_row.
  IF rows_full.
    RAISE EXCEPTION TYPE cx_full.
  ENDIF.
  IF invalid_row.
    RAISE EXCEPTION TYPE cx_invalid.
  ENDIF.
ENDMETHOD.
```

### Compliant

```abap
METHOD add_row.
  RAISE EXCEPTION TYPE cx_my_add_row
    EXPORTING iv_reason = reason.
ENDMETHOD.
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC NO_MULTI_EXC

" SAP CI_ prefix format:
... "#EC CI_NO_MULTI_EXC
```


## Related Rules

* [Prefer Class-Based Exceptions over Classic EXCEPTIONS](/rules/pref-class-exc) — <code>#EC PREF_CLASS_EXC</code>
* [Classic EXCEPTIONS must not map two errors to the same number](/rules/no-exc-overlap) — <code>#EC NO_EXC_OVERLAP</code>
* [Avoid Obsolete MESSAGE ... RAISING in Methods](/rules/no-msg-raising) — <code>#EC NO_MSG_RAISING</code>

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_NO_MULTI_EXC`
* **Implementation File:** [zcl_skylint_no_multi_exc.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_no_multi_exc.clas.abap)
