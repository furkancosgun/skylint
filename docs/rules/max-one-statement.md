# Limit One Statement per Source Code Line

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="danger" text="#EC ONE_STMT" />
</div>

## Overview

Max One Statement Per Line.

> **ATC Finding Message:** `Only one statement is allowed per line`

## Rationale

Placing multiple statements on a single line hinders debugger stepping, breaks Git line diffs, and hurts overall code scannability.

### Non-Compliant

```abap
lv_a = 1. lv_b = 2.
```

### Compliant

```abap
lv_a = 1.
lv_b = 2.
```

## Transformation

```diff
- lv_a = 1. lv_b = 2.
+ lv_a = 1.
+ lv_b = 2.
```

## CLI & CI/CD Configuration

```yaml
checks:
  max-one-statement:
    enabled: true
    severity: warning
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC ONE_STMT

" SAP CI_ prefix format:
... "#EC CI_ONE_STMT
```

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_MAX_ONE_STMT`
* **Implementation File:** [zcl_skylint_max_one_stmt.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_max_one_stmt.clas.abap)
