---
description: "Omit unnecessary RETURN at end of routine"
---

# Omit Unnecessary RETURN Statement

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="warning" text="⚡ QuickFix Ready" />
  <Badge type="danger" text="#EC NO_UNNEC_RETURN" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Omit unnecessary RETURN at end of routine.

> **ATC Finding Message:** `Omit optional RETURN at end of routine; routines return automatically`

## Rationale

Routines automatically return upon reaching ENDMETHOD, ENDFORM, or ENDFUNCTION. An explicit RETURN statement at the very end of the routine body is redundant and clutters the code.

### Non-Compliant

```abap
METHOD calculate.
  lv_total = 100.
  RETURN.
ENDMETHOD.
```

### Compliant

```abap
METHOD calculate.
  lv_total = 100.
ENDMETHOD.
```

## Transformation

```diff
- METHOD calculate.
-   lv_total = 100.
-   RETURN.
- ENDMETHOD.
+ METHOD calculate.
+   lv_total = 100.
+ ENDMETHOD.
```

## Automated QuickFix

This rule provides an **automated QuickFix** directly in Eclipse ABAP Development Tools (ADT):
1. Position the cursor on the flagged statement.
2. Press <kbd>Ctrl</kbd> + <kbd>1</kbd> (Quick Assist).
3. Select the automated refactoring to apply the clean syntax immediately.

## CLI & CI/CD Configuration

```yaml
checks:
  no-unnecessary-return:
    enabled: true
    severity: warning
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC NO_UNNEC_RETURN

" SAP CI_ prefix format:
... "#EC CI_NO_UNNEC_RETURN
```

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_NO_UNNEC_RETURN`
* **Implementation File:** [zcl_skylint_no_unnec_return.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_no_unnec_return.clas.abap)
