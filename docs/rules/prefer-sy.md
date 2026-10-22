---
description: "Prefer the short system field alias SY over SYST"
---

# Prefer the Short System Field Alias SY over SYST

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="warning" text="⚡ QuickFix Ready" />
  <Badge type="danger" text="#EC PREF_SY" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Prefer the short system field alias SY over SYST.

> **ATC Finding Message:** `Use sy- instead of syst- for system fields`

## Rationale

`SY` and `SYST` address the same system structure, but `SY` is the established short form. Using a single alias keeps system field access consistent throughout the codebase.

### Non-Compliant

```abap
WRITE syst-uname.
```

### Compliant

```abap
WRITE sy-uname.
```

## Transformation

```diff
- WRITE syst-uname.
+ WRITE sy-uname.
```

## Automated QuickFix

This rule provides an **automated QuickFix** directly in Eclipse ABAP Development Tools (ADT):
1. Position the cursor on the flagged statement.
2. Press <kbd>Ctrl</kbd> + <kbd>1</kbd> (Quick Assist).
3. Select the automated refactoring to apply the clean syntax immediately.

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC PREF_SY

" SAP CI_ prefix format:
... "#EC CI_PREF_SY
```

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_PREF_SY`
* **Implementation File:** [zcl_skylint_pref_sy.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_pref_sy.clas.abap)
