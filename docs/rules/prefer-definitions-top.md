# Place Definitions at Top of Routine

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="danger" text="#EC DEF_TOP" />
</div>

## Overview

Place definitions at beginning of routine.

> **ATC Finding Message:** `Reorder definitions to beginning of routine; avoid scattered DATA statements`

## Rationale

Explicit local definitions (DATA, TYPES, CONSTANTS, FIELD-SYMBOLS) should be placed at the very beginning of the routine rather than scattered in the middle of executable code.

### Non-Compliant

```abap
METHOD calculate.
  lv_total = 100.
  DATA lv_tax TYPE i.
ENDMETHOD.
```

### Compliant

```abap
METHOD calculate.
  DATA lv_tax TYPE i.
  lv_total = 100.
ENDMETHOD.
```

## Transformation

```diff
- METHOD calculate.
-   lv_total = 100.
-   DATA lv_tax TYPE i.
- ENDMETHOD.
+ METHOD calculate.
+   DATA lv_tax TYPE i.
+   lv_total = 100.
+ ENDMETHOD.
```

## CLI & CI/CD Configuration

```yaml
checks:
  prefer-definitions-top:
    enabled: true
    severity: warning
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
