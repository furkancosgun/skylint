---
description: "Prefer IS [NOT] INITIAL over lines( ) or empty literals"
---

# Prefer IS [NOT] INITIAL over lines( ) or Literal Comparisons

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="warning" text="⚡ QuickFix Ready" />
  <Badge type="danger" text="#EC PREF_INIT" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Prefer IS [NOT] INITIAL over lines( ) or empty literals.

> **ATC Finding Message:** `Use IS [NOT] INITIAL instead of lines( ) or empty literal comparison`

## Rationale

Checking whether an internal table, string, or variable is empty should be done with `IS [NOT] INITIAL` rather than counting `lines( ) > 0` or comparing to empty literals (`""`, `space`, `0`). `IS INITIAL` is idiomatic Clean ABAP, expressive, and optimized.

### Non-Compliant

```abap
IF lines( lt_items ) > 0.
ENDIF.
```

### Compliant

```abap
IF lt_items IS NOT INITIAL.
ENDIF.
```

## Transformation

```diff
- IF lines( lt_items ) > 0.
- ENDIF.
+ IF lt_items IS NOT INITIAL.
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
  prefer-is-initial:
    enabled: true
    severity: warning
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC PREF_INIT

" SAP CI_ prefix format:
... "#EC CI_PREF_INIT
```

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_PREF_IS_INITIAL`
* **Implementation File:** [zcl_skylint_pref_is_initial.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_pref_is_initial.clas.abap)
