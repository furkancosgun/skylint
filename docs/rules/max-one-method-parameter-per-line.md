---
description: "Max one method parameter definition per line"
---

# Max One Method Parameter Definition Per Line

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="danger" text="#EC MAX_PARAM_LINE" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Max one method parameter definition per line.

> **ATC Finding Message:** `Keep max one method parameter definition per line`

## Rationale

Defining multiple parameters on the same line hampers readability and produces noisy version control diffs. Each parameter in a signature should be declared on its own dedicated line.

### Non-Compliant

```abap
METHODS foo IMPORTING iv_a TYPE i iv_b TYPE string.
```

### Compliant

```abap
METHODS foo
  IMPORTING
    iv_a TYPE i
    iv_b TYPE string.
```

## Transformation

```diff
- METHODS foo IMPORTING iv_a TYPE i iv_b TYPE string.
+ METHODS foo
+   IMPORTING
+     iv_a TYPE i
+     iv_b TYPE string.
```

## CLI & CI/CD Configuration

```yaml
checks:
  max-one-method-parameter-per-line:
    enabled: true
    severity: warning
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
