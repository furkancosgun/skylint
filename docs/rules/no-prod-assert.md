---
title: "Avoid Native ASSERT in Production Code (Prevent Unrecoverable Dumps)"
description: "Prevent production short dumps in SAP ABAP by replacing uncatchable ASSERT statements with structured exception handling."
keywords: "ASSERTION_FAILED dump ABAP, Avoid ASSERT in production SAP, Clean ABAP Exception Handling"
---

# Avoid Native ASSERT in Production Code (Prevent Unrecoverable Dumps)

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Security & Robustness" />
  <Badge type="danger" text="#EC NO_PROD_ASSERT" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Native ASSERT in Production Logic.

> **ATC Finding Message:** `Avoid native ASSERT in production logic; raise an exception instead`

## Rationale

The ABAP statement `ASSERT condition` immediately raises an uncatchable short dump (`ASSERTION_FAILED`) if the condition evaluates to false. While useful in unit test classes, using unconditioned assertions in production application logic abruptly terminates end-user sessions, loses uncommitted data, and creates emergency incidents.

**Best Practice:** Check conditions gracefully and raise recoverable class-based exceptions with informative error messages. Reserve `ASSERT` strictly for ABAP Unit test includes (`LCL_TEST`).

### Non-Compliant

```abap
" Dangerous: Causes catastrophic user session crash in production
ASSERT iv_amount > 0.
```

### Compliant

```abap
" Clean ABAP: Graceful validation with recoverable domain exception
IF iv_amount <= 0.
  RAISE EXCEPTION NEW zcx_invalid_amount( iv_amount ).
ENDIF.
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC NO_PROD_ASSERT

" SAP CI_ prefix format:
... "#EC CI_NO_PROD_ASSERT
```

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_NO_PROD_ASSERT`
* **Implementation File:** [zcl_skylint_no_prod_assert.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_no_prod_assert.clas.abap)
