---
description: "Prefer REDUCE #( ) expression over simple aggregation LOOP"
---

# Prefer REDUCE #( ) Expression over Simple Aggregation LOOP

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="warning" text="⚡ QuickFix Ready" />
  <Badge type="danger" text="#EC PREF_REDUCE" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Prefer REDUCE #( ) expression over simple aggregation LOOP.

> **ATC Finding Message:** `Prefer REDUCE #( ) expression over simple aggregation LOOP`

## Rationale

Simple loops that only accumulate a sum or concatenate strings into a single target variable can be expressed much more concisely and declaratively with modern ABAP REDUCE #( ) constructor expressions.

### Non-Compliant

```abap
LOOP AT lt_items INTO ls_item.
  lv_sum = lv_sum + ls_item-amount.
ENDLOOP.
```

### Compliant

```abap
lv_sum = REDUCE #( 
  INIT res = lv_sum
  FOR ls_item IN lt_items
  NEXT res = res + ls_item-amount ).
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
... "#EC PREF_REDUCE

" SAP CI_ prefix format:
... "#EC CI_PREF_REDUCE
```

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_PREF_REDUCE`
* **Implementation File:** [zcl_skylint_pref_reduce.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_pref_reduce.clas.abap)
