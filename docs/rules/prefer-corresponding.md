---
description: "Prefer CORRESPONDING Expression over MOVE-CORRESPONDING"
---

# Prefer CORRESPONDING #( ) Operator

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="warning" text="⚡ QuickFix Ready" />
  <Badge type="danger" text="#EC CORRESP" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Prefer CORRESPONDING Expression over MOVE-CORRESPONDING.

> **ATC Finding Message:** `Prefer functional CORRESPONDING #( ... ) over MOVE-CORRESPONDING`

## Rationale

The constructor expression `CORRESPONDING #( )` is type-safe, expression-capable, and supports modern features like `EXCEPT` and `MAPPING`. It replaces the archaic `MOVE-CORRESPONDING` statement.

### Non-Compliant

```abap
MOVE-CORRESPONDING ls_source TO ls_target.
```

### Compliant

```abap
ls_target = CORRESPONDING #( ls_source ).
```

## Transformation

```diff
- MOVE-CORRESPONDING ls_source TO ls_target.
+ ls_target = CORRESPONDING #( ls_source ).
```

## Automated QuickFix

This rule provides an **automated QuickFix** directly in Eclipse ABAP Development Tools (ADT):
1. Position the cursor on the flagged statement.
2. Press <kbd>Ctrl</kbd> + <kbd>1</kbd> (Quick Assist).
3. Select the automated refactoring to apply the clean syntax immediately.

## CLI & CI/CD Configuration

```yaml
checks:
  prefer-corresponding:
    enabled: true
    severity: warning
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC CORRESP

" SAP CI_ prefix format:
... "#EC CI_CORRESP
```

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_PREF_CORRESP`
* **Implementation File:** [zcl_skylint_pref_corresp.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_pref_corresp.clas.abap)
