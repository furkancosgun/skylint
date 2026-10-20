---
description: "Prefer string templates over CONCATENATE"
---

# Prefer String Templates over CONCATENATE

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="warning" text="⚡ QuickFix Ready" />
  <Badge type="danger" text="#EC STR_TMPL" />
</div>

## Overview

Prefer string templates over CONCATENATE.

> **ATC Finding Message:** `Use string template |...| instead of CONCATENATE`

## Rationale

String templates (`|Hello { lv_name }|`) provide type-safe, readable string interpolation with built-in formatting options. They eliminate procedural `CONCATENATE` and `SEPARATED BY` statements.

### Non-Compliant

```abap
CONCATENATE 'Hello' iv_name INTO lv_greeting SEPARATED BY space.
```

### Compliant

```abap
lv_greeting = |Hello { iv_name }|.
```

## Transformation

```diff
- CONCATENATE 'Hello' iv_name INTO lv_greeting SEPARATED BY space.
+ lv_greeting = |Hello { iv_name }|.
```

## Automated QuickFix

This rule provides an **automated QuickFix** directly in Eclipse ABAP Development Tools (ADT):
1. Position the cursor on the flagged statement.
2. Press <kbd>Ctrl</kbd> + <kbd>1</kbd> (Quick Assist).
3. Select the automated refactoring to apply the clean syntax immediately.

## CLI & CI/CD Configuration

```yaml
checks:
  prefer-string-template:
    enabled: true
    severity: warning
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC STR_TMPL

" SAP CI_ prefix format:
... "#EC CI_STR_TMPL
```

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_PREF_STR_TMPL`
* **Implementation File:** [zcl_skylint_pref_str_tmpl.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_pref_str_tmpl.clas.abap)
