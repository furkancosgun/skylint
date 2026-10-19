# Inline a CAST helper that is only read once

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="warning" text="⚡ QuickFix Ready" />
  <Badge type="danger" text="Finding: PREF_ICST" />
</div>

## Overview

Inline a CAST helper that is only read once.

> **ATC Finding Message:** `CAST helper is read exactly once in the next statement; inline it`

## Rationale

A CAST helper declared as DATA and read exactly once in the following statement can be inlined, removing a temporary variable.

### Non-Compliant

```abap
DATA(helper) = CAST lcl_node( object ).
result = helper->get_tokens( ).
```

### Compliant

```abap
result = CAST lcl_node( object )->get_tokens( ).
```

## Transformation

```diff
- DATA(helper) = CAST lcl_node( object ).
- result = helper->get_tokens( ).
+ result = CAST lcl_node( object )->get_tokens( ).
```

## Automated QuickFix

This rule provides an **automated QuickFix** directly in Eclipse ABAP Development Tools (ADT):
1. Position the cursor on the flagged statement.
2. Press <kbd>Ctrl</kbd> + <kbd>1</kbd> (Quick Assist).
3. Select the automated refactoring to apply the clean syntax immediately.

## CLI & CI/CD Configuration

```yaml
checks:
  prefer-inline-cast:
    enabled: true
    severity: warning
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC INLINE_CAST

" SAP CI_ prefix format:
... "#EC CI_INLINE_CAST
```

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_PREF_INL_CAST`
* **Finding Code:** `PREF_ICST`
* **Implementation File:** [zcl_skylint_pref_inl_cast.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_pref_inl_cast.clas.abap)
