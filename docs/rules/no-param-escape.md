---
description: "Avoid unnecessary parameter escape (!param)"
---

# Avoid Reassigning Importing Parameters

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="warning" text="⚡ QuickFix Ready" />
  <Badge type="danger" text="#EC PARAM_ESCAPE" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Avoid unnecessary parameter escape (!param).

> **ATC Finding Message:** `Escape params with ! only on keyword clash`

## Rationale

Importing parameters should be treated as immutable inputs. Modifying them inside the method leads to unexpected side effects and debugging difficulties.

### Non-Compliant

```abap
METHODS process IMPORTING !iv_data TYPE string.
```

### Compliant

```abap
METHODS process IMPORTING iv_data TYPE string.
```

## Transformation

```diff
- METHODS process IMPORTING !iv_data TYPE string.
+ METHODS process IMPORTING iv_data TYPE string.
```

## Automated QuickFix

This rule provides an **automated QuickFix** directly in Eclipse ABAP Development Tools (ADT):
1. Position the cursor on the flagged statement.
2. Press <kbd>Ctrl</kbd> + <kbd>1</kbd> (Quick Assist).
3. Select the automated refactoring to apply the clean syntax immediately.

## CLI & CI/CD Configuration

```yaml
checks:
  no-param-escape:
    enabled: true
    severity: warning
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC PARAM_ESCAPE

" SAP CI_ prefix format:
... "#EC CI_PARAM_ESCAPE
```

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_NO_PARAM_ESCAPE`
* **Implementation File:** [zcl_skylint_no_param_escape.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_no_param_escape.clas.abap)
