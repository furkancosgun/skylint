---
description: "Inline a CAST helper that is only read once"
---

# Inline a CAST helper that is only read once

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="warning" text="QuickFix Ready" />
  <Badge type="danger" text="#EC INLINE_CAST" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Inline a CAST helper that is only read once.

> **ATC Finding Message:** `CAST helper is read exactly once in the next statement; inline it`

## Rationale

A CAST helper assigned to a temporary and read only once adds a variable that carries no extra meaning. Inlining the CAST into the consuming expression keeps the downcast and its use together. Use CAST type( ... )->method( ) when the helper is not reused.

### Non-Compliant

```abap
DATA(lo_node) = CAST lcl_node( io_object ).
result = lo_node->get_tokens( ).
```

### Compliant

```abap
result = CAST lcl_node( io_object )->get_tokens( ).
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
... "#EC INLINE_CAST

" SAP CI_ prefix format:
... "#EC CI_INLINE_CAST
```

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_PREF_INL_CAST`
* **Implementation File:** [zcl_skylint_pref_inl_cast.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_pref_inl_cast.clas.abap)
