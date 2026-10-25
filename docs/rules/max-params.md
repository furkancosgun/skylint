---
description: "Method parameter limits (count and lines)"
---

# Limit Method Parameter Count and Parameters Per Line

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Metrics & Complexity Limits" />
  <Badge type="danger" text="#EC MAX_PARAMS" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Method parameter limits (count and lines).

> **ATC Finding Messages:**
> - `Method signature has too many parameters; consider grouping into structures`
> - `Keep max one method parameter definition per line`

## Rationale

Long parameter lists complicate method invocations and signal excessive responsibilities. Furthermore, placing multiple parameter definitions on a single line impairs code readability and produces noisy version control diffs. Restrict the total parameter count (max 8) and declare at most one parameter definition per line.

### Non-Compliant

```abap
METHODS execute IMPORTING iv_id TYPE string iv_status TYPE c LENGTH 1.
```

### Compliant

```abap
METHODS execute
  IMPORTING
    iv_id     TYPE string
    iv_status TYPE c LENGTH 1.
```

## Configuration & Thresholds

This check can be fine-tuned directly in the ATC Check Variant Editor (`CHKV`) in Eclipse ADT:

| Parameter Name | Data Type | Default Value |
|---|---|:---:|
| `MAX_PARAMETERS` | `Integer` | <code>8</code> |
| `CHECK_PARAM_LINE` | `Boolean` | <code>true</code> |

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC MAX_PARAMS

" SAP CI_ prefix format:
... "#EC CI_MAX_PARAMS
```

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_MAX_PARAMS`
* **Implementation File:** [zcl_skylint_max_params.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_max_params.clas.abap)
