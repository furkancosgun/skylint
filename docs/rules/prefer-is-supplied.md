---
description: "Prefer IS SUPPLIED over the obsolete IS REQUESTED"
---

# Prefer IS SUPPLIED over IS REQUESTED

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="warning" text="⚡ QuickFix Ready" />
  <Badge type="danger" text="#EC PREF_IS_SUPPLIED" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Prefer IS SUPPLIED over the obsolete IS REQUESTED.

> **ATC Finding Message:** `Use IS SUPPLIED instead of IS REQUESTED`

## Rationale

`IS REQUESTED` is obsolete and only meaningful for output parameters. `IS SUPPLIED` expresses the actual question reliably: whether the caller passed an actual parameter, regardless of the parameter direction.

### Non-Compliant

```abap
IF iv_name IS REQUESTED.
  process( iv_name ).
ENDIF.
```

### Compliant

```abap
IF iv_name IS SUPPLIED.
  process( iv_name ).
ENDIF.
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
... "#EC PREF_IS_SUPPLIED

" SAP CI_ prefix format:
... "#EC CI_PREF_IS_SUPPLIED
```

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_PREF_IS_SUPPLIED`
* **Implementation File:** [zcl_skylint_pref_is_supplied.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_pref_is_supplied.clas.abap)
