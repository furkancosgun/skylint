---
description: "Place definitions at beginning of routine"
---

# Place Definitions at Top of Routine

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="danger" text="#EC DEF_TOP" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Place definitions at beginning of routine.

> **ATC Finding Message:** `Reorder definitions to beginning of routine; avoid scattered DATA statements`

## Rationale

A declaration in the middle of executable code interrupts the reading flow and hides that the variable exists for the whole routine. It also makes accidental use before declaration harder to spot. Put DATA, TYPES, CONSTANTS, and FIELD-SYMBOLS at the top of the routine.

### Non-Compliant

```abap
METHOD calculate.
  DATA lv_total TYPE i.
  lv_total = 100.
  DATA lv_tax TYPE i.
ENDMETHOD.
```

### Compliant

```abap
METHOD calculate.
  DATA lv_total TYPE i.
  DATA lv_tax TYPE i.
  lv_total = 100.
ENDMETHOD.
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC DEF_TOP

" SAP CI_ prefix format:
... "#EC CI_DEF_TOP
```

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_PREF_DEF_TOP`
* **Implementation File:** [zcl_skylint_pref_def_top.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_pref_def_top.clas.abap)
