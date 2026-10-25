---
description: "Modernize Downcasting (CAST #( ) & inlining)"
---

# Modernize Downcasting (CAST #( ) Expression & Inlining)

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="warning" text="QuickFix Ready" />
  <Badge type="danger" text="#EC PREF_CAST" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Modernize Downcasting (CAST #( ) & inlining).

> **ATC Finding Messages:**
> - `Prefer CAST #( ) constructor expression over ?= downcast`
> - `CAST helper is read exactly once in the next statement; inline it`

## Rationale

The legacy ?= and MOVE ?TO operators are obsolete downcast statements that cannot be chained or used in modern expressions. The modern CAST #( ) expression creates cleanly typed references that can be used directly in chained calls or assignments. Furthermore, single-use downcast helper variables should be inlined into the consuming expression to prevent clutter and unnecessary temporary state.

### Non-Compliant

```abap
lo_child ?= lo_parent.
DATA(lo_node) = CAST lcl_node( io_obj ).
result = lo_node->get_tokens( ).
```

### Compliant

```abap
lo_child = CAST #( lo_parent ).
result = CAST lcl_node( io_obj )->get_tokens( ).
```

## Automated QuickFix

This rule provides an **automated QuickFix** directly in Eclipse ABAP Development Tools (ADT):
1. Position the cursor on the flagged statement.
2. Press <kbd>Ctrl</kbd> + <kbd>1</kbd> (Quick Assist).
3. Select the automated refactoring to apply the clean syntax immediately.

## Configuration & Thresholds

This check can be fine-tuned directly in the ATC Check Variant Editor (`CHKV`) in Eclipse ADT:

| Parameter Name | Data Type | Default Value |
|---|---|:---:|
| `CHECK_CAST_SYNTAX` | `Boolean` | <code>true</code> |
| `CHECK_INLINE_CAST` | `Boolean` | <code>true</code> |

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC PREF_CAST

" SAP CI_ prefix format:
... "#EC CI_PREF_CAST
```

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_PREF_DOWNCAST`
* **Implementation File:** [zcl_skylint_pref_downcast.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_pref_downcast.clas.abap)
