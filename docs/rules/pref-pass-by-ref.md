---
title: "Prefer Pass-by-Reference for Internal Tables in Method Signatures"
description: "Eliminate deep copy memory overhead in SAP ABAP methods by passing internal tables by reference instead of by value."
keywords: "Pass by reference ABAP, Pass by value memory copy, Clean ABAP Method Parameters, SAP Memory Management"
---

# Prefer Pass-by-Reference for Internal Tables in Method Signatures

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Performance & Database" />
  <Badge type="danger" text="#EC PREF_PASS_BY_REF" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Slow Parameter Passing.

> **ATC Finding Message:** `Avoid pass-by-value for importing method parameters`

## Rationale

Declaring method parameters with `VALUE(it_table)` forces the ABAP runtime to perform an immediate deep copy of the entire table into a new memory allocation upon invocation. If an internal table containing thousands of rows is passed across multiple layers, memory consumption multiplies rapidly and garbage collection pressure causes latency spikes.

**Best Practice:** Pass internal tables by reference (`it_table TYPE ...` without the `VALUE` keyword). In ABAP, parameters are passed by reference by default, which passes only a pointer ($O(1)$ cost).

### Non-Compliant

```abap
" Anti-pattern: Deep-copies the entire table buffer on every method invocation
METHODS calculate_totals
  IMPORTING
    VALUE(it_items) TYPE ty_item_table.
```

### Compliant

```abap
" Clean ABAP: Zero-copy pointer reference passed instantly
METHODS calculate_totals
  IMPORTING
    it_items TYPE ty_item_table.
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC PREF_PASS_BY_REF

" SAP CI_ prefix format:
... "#EC CI_PREF_PASS_BY_REF
```

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_PREF_PASS_BY_REF`
* **Implementation File:** [zcl_skylint_pref_pass_by_ref.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_pref_pass_by_ref.clas.abap)
