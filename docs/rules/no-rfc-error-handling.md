# RFC calls must handle SYSTEM_FAILURE and COMMUNICATION_FAILURE

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="tip" text="Security & Robustness" />
  <Badge type="danger" text="Finding: NO_RFC_ERR" />
</div>

## Overview

RFC calls must handle system failures.

> **ATC Finding Message:** `RFC call must handle SYSTEM_FAILURE and COMMUNICATION_FAILURE`

## Rationale

Remote calls can fail at runtime; the caller must handle system and communication failures (and resource failures for async calls in a group).

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
    system_failure        = 1 MESSAGE msg
    communication_failure = 2 MESSAGE msg
    OTHERS                = 3.
```

## Transformation

```diff
- CALL FUNCTION 'Z_RFC'
-   DESTINATION lv_rfc.
+ CALL FUNCTION 'Z_RFC'
+   DESTINATION lv_rfc
+   EXCEPTIONS
+     system_failure        = 1 MESSAGE msg
+     communication_failure = 2 MESSAGE msg
+     OTHERS                = 3.
```

## CLI & CI/CD Configuration

```yaml
checks:
  no-rfc-error-handling:
    enabled: true
    severity: error
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
* **Finding Code:** `NO_RFC_ERR`
* **Implementation File:** [zcl_skylint_no_rfc_err.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_no_rfc_err.clas.abap)
