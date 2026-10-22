---
description: "RFC calls must handle system failures"
---

# RFC calls must handle SYSTEM_FAILURE and COMMUNICATION_FAILURE

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="danger" text="Error" />
  <Badge type="tip" text="Security & Robustness" />
  <Badge type="danger" text="#EC RFC_ERR" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

RFC calls must handle system failures.

> **ATC Finding Message:** `RFC call must handle SYSTEM_FAILURE and COMMUNICATION_FAILURE`

## Rationale

A remote function call can fail because the target system is unavailable or the communication layer breaks, independently of the function logic. Without handlers for SYSTEM_FAILURE and COMMUNICATION_FAILURE, these failures become unhandled dumps or silent errors. Always handle both, plus OTHERS, and evaluate the response.

### Non-Compliant

```abap
CALL FUNCTION 'Z_RFC'
  DESTINATION lv_rfc.
```

### Compliant

```abap
CALL FUNCTION 'Z_RFC'
  DESTINATION lv_rfc
  EXCEPTIONS
    system_failure        = 1 MESSAGE lv_message
    communication_failure = 2 MESSAGE lv_message
    OTHERS                = 3.
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC RFC_ERR

" SAP CI_ prefix format:
... "#EC CI_RFC_ERR
```

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_NO_RFC_ERR`
* **Implementation File:** [zcl_skylint_no_rfc_err.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_no_rfc_err.clas.abap)
