---
description: "Declare inline variables as FINAL when never written again"
---

# Prefer FINAL( ) over DATA( ) when the variable is never written again

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="warning" text="⚡ QuickFix Ready" />
  <Badge type="danger" text="#EC PREF_FINAL" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Declare inline variables as FINAL when never written again.

> **ATC Finding Message:** `Inline variable is never written again; declare it with FINAL( )`

## Rationale

When an inline DATA( ) variable is assigned once and never written again, declaring it FINAL( ) communicates immutability and lets the compiler enforce it.

### Non-Compliant

```abap
DATA(lv_count) = 10.
WRITE lv_count.
```

### Compliant

```abap
FINAL(lv_count) = 10.
WRITE lv_count.
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
... "#EC PREF_FINAL

" SAP CI_ prefix format:
... "#EC CI_PREF_FINAL
```

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_PREF_FINAL_DATA`
* **Implementation File:** [zcl_skylint_pref_final_data.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_pref_final_data.clas.abap)
