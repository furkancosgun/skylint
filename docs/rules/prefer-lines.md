---
description: "Prefer lines( ) over DESCRIBE TABLE ... LINES"
---

# Prefer lines( ) over DESCRIBE TABLE

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="warning" text="⚡ QuickFix Ready" />
  <Badge type="danger" text="#EC LINES" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Prefer lines( ) over DESCRIBE TABLE ... LINES.

> **ATC Finding Message:** `Use lines( ) function instead of DESCRIBE TABLE ... LINES`

## Rationale

The built-in `lines( )` function is modern, functional, and can be embedded directly into expressions and conditionals without requiring a temporary variable or the cumbersome procedural `DESCRIBE TABLE ... LINES` statement.

### Non-Compliant

```abap
DESCRIBE TABLE lt_customers LINES lv_count.
```

### Compliant

```abap
lv_count = lines( lt_customers ).
```

## Transformation

```diff
- DESCRIBE TABLE lt_customers LINES lv_count.
+ lv_count = lines( lt_customers ).
```

## Automated QuickFix

This rule provides an **automated QuickFix** directly in Eclipse ABAP Development Tools (ADT):
1. Position the cursor on the flagged statement.
2. Press <kbd>Ctrl</kbd> + <kbd>1</kbd> (Quick Assist).
3. Select the automated refactoring to apply the clean syntax immediately.

## CLI & CI/CD Configuration

```yaml
checks:
  prefer-lines:
    enabled: true
    severity: warning
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC LINES

" SAP CI_ prefix format:
... "#EC CI_LINES
```

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_PREF_LINES`
* **Implementation File:** [zcl_skylint_pref_lines.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_pref_lines.clas.abap)
