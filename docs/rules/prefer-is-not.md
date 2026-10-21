---
description: "Prefer IS NOT over NOT ... IS"
---

# Prefer IS NOT over NOT ... IS

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="warning" text="⚡ QuickFix Ready" />
  <Badge type="danger" text="#EC IS_NOT" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Prefer IS NOT over NOT ... IS.

> **ATC Finding Message:** `Use IS NOT instead of NOT ... IS`

## Rationale

Writing `IF lo_ref IS NOT BOUND` or `IF lt_tab IS NOT INITIAL` mirrors natural language reading order and avoids misreading inverted expressions that start with `NOT`.

### Non-Compliant

```abap
IF NOT lo_instance IS BOUND.
  RETURN.
ENDIF.
```

### Compliant

```abap
IF lo_instance IS NOT BOUND.
  RETURN.
ENDIF.
```

## Transformation

```diff
- IF NOT lo_instance IS BOUND.
-   RETURN.
- ENDIF.
+ IF lo_instance IS NOT BOUND.
+   RETURN.
+ ENDIF.
```

## Automated QuickFix

This rule provides an **automated QuickFix** directly in Eclipse ABAP Development Tools (ADT):
1. Position the cursor on the flagged statement.
2. Press <kbd>Ctrl</kbd> + <kbd>1</kbd> (Quick Assist).
3. Select the automated refactoring to apply the clean syntax immediately.

## CLI & CI/CD Configuration

```yaml
checks:
  prefer-is-not:
    enabled: true
    severity: warning
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC IS_NOT

" SAP CI_ prefix format:
... "#EC CI_IS_NOT
```

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_PREF_IS_NOT`
* **Implementation File:** [zcl_skylint_pref_is_not.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_pref_is_not.clas.abap)
