---
title: "Prefer ASSIGNING over LOOP INTO Copy Targets"
description: "Detect ABAP LOOP AT statements that copy rows with INTO and recommend ASSIGNING field symbols for allocation-free iteration."
keywords: "ABAP LOOP AT INTO, ASSIGNING field symbol, internal table performance ABAP, SAP ATC performance check, Clean ABAP loop target"
category: "performance"
ruleId: "no-loop-into"
---

# Prefer ASSIGNING over LOOP INTO Copy Targets

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Performance & Database" />
  <Badge type="danger" text="#EC NO_LOOP_INTO" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Prefer ASSIGNING over LOOP INTO copy targets.

> **ATC Finding Message:** `Loop copies each row; use ASSIGNING with a field symbol`

## Rationale

`LOOP AT ... INTO ls_row` copies every table row into a work area before the body runs. For read-only loops this allocation and copy is pure overhead; `ASSIGNING FIELD-SYMBOL(<ls_row>)` iterates by reference and keeps the code allocation-free. The rule flags LOOP statements that use INTO without ASSIGNING or REFERENCE INTO, and deliberately leaves READ TABLE ... INTO to pref-read-table to avoid duplicate findings.

### Non-Compliant

```abap
LOOP AT lt_items INTO ls_item.
  lv_total = lv_total + ls_item-amount.
ENDLOOP.
```

### Compliant

```abap
LOOP AT lt_items ASSIGNING FIELD-SYMBOL(<ls_item>).
  lv_total = lv_total + <ls_item>-amount.
ENDLOOP.
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC NO_LOOP_INTO

" SAP CI_ prefix format:
... "#EC CI_NO_LOOP_INTO
```


## Related Rules

* [Do Not Mutate the Internal Table Currently Being Looped (Iterator Invalidation)](/rules/no-mod-loop-tab) — <code>#EC NO_MOD_LOOP_TAB</code>
* [Modernize READ TABLE (Table Expressions & line_exists)](/rules/pref-read-table) — <code>#EC PREF_TAB_EXPR</code>
* [Avoid String Concatenation Inside Loops (Quadratic Memory Allocation)](/rules/no-concat-loop) — <code>#EC NO_CONCAT_LOOP</code>

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_NO_LOOP_INTO`
* **Implementation File:** [zcl_skylint_no_loop_into.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_no_loop_into.clas.abap)
