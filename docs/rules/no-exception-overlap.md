---
description: "Classic EXCEPTIONS must not overlap"
---

# Classic EXCEPTIONS must not map two errors to the same number

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="tip" text="Anti-Patterns & Bad Practices" />
  <Badge type="danger" text="#EC EXC_OVERLAP" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Classic EXCEPTIONS must not overlap.

> **ATC Finding Message:** `Two classic exceptions share the same error number`

## Rationale

When two classic exceptions share one error number, the caller cannot tell which one was raised.

### Non-Compliant

```abap
CALL FUNCTION 'SOMETHING'
  EXCEPTIONS
    system_failure        = 1 MESSAGE lv_message
    communication_failure = 1 MESSAGE lv_message
    OTHERS                = 1.
```

### Compliant

```abap
CALL FUNCTION 'SOMETHING'
  EXCEPTIONS
    system_failure        = 1 MESSAGE lv_message
    communication_failure = 2 MESSAGE lv_message
    OTHERS                = 3.
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC EXC_OVERLAP

" SAP CI_ prefix format:
... "#EC CI_EXC_OVERLAP
```

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_NO_EXC_OVERLAP`
* **Implementation File:** [zcl_skylint_no_exc_overlap.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_no_exc_overlap.clas.abap)
