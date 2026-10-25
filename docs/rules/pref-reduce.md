---
title: "Prefer REDUCE #( ) Expression over Simple Aggregation LOOP"
description: "Prefer REDUCE #( ) Expression over Simple Aggregation LOOP - Clean ABAP guidelines, modern SAP syntax rules, and automated ATC code inspection for SAP S/4HANA and ABAP Cloud."
keywords: "Clean ABAP, SAP ATC Check, ABAP Cloud, S/4HANA Readiness, pref-reduce, clean-abap"
---

# Prefer REDUCE #( ) Expression over Simple Aggregation LOOP

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="warning" text="QuickFix Ready" />
  <Badge type="danger" text="#EC PREF_REDUCE" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Prefer REDUCE #( ) expression over simple aggregation LOOP.

> **ATC Finding Message:** `Prefer REDUCE #( ) expression over simple aggregation LOOP`

## Rationale

A loop that only accumulates a sum or builds a single aggregated value mixes imperative control flow with a simple calculation and hides the real intent. Such loops are longer to read and easy to break when the accumulator initialization or the loop body changes. REDUCE #( ) expresses the aggregation declaratively inside one expression and removes the mutable helper state. Use REDUCE for straightforward sums, counts, and string concatenation, and keep a loop only when it performs additional side effects.

### Non-Compliant

```abap
LOOP AT lt_orders INTO ls_order.
  lv_total = lv_total + ls_order-amount.
ENDLOOP.
```

### Compliant

```abap
lv_total = REDUCE i( INIT total = 0
  FOR ls_order IN lt_orders
  NEXT total = total + ls_order-amount ).
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
