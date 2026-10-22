---
description: "Max one method parameter definition per line"
---

# Max One Method Parameter Definition Per Line

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="danger" text="#EC MAX_PARAM_LINE" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Max one method parameter definition per line.

> **ATC Finding Message:** `Keep max one method parameter definition per line`

## Rationale

Several parameters on one line are hard to scan and produce noisy diffs when one parameter changes. Multi-line signatures also allow types and comments to align clearly. Declare each parameter on its own line.

### Non-Compliant

```abap
METHODS process IMPORTING iv_a TYPE i iv_b TYPE string.
```

### Compliant

```abap
METHODS process
  IMPORTING
    iv_a TYPE i
    iv_b TYPE string.
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC MAX_PARAM_LINE

" SAP CI_ prefix format:
... "#EC CI_MAX_PARAM_LINE
```

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_MAX_PARAM_LINE`
* **Implementation File:** [zcl_skylint_max_param_line.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_max_param_line.clas.abap)
