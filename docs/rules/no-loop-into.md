---
title: "Prefer ASSIGNING Field Symbols Over LOOP INTO Copy Targets"
description: "Eliminate row-by-row memory copies in ABAP loops by replacing LOOP AT INTO with ASSIGNING field symbols for zero-copy performance."
keywords: "no-loop-into, LOOP AT ASSIGNING, field symbols, Clean ABAP loops, SAP ATC"
category: "performance"
ruleId: "no-loop-into"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L4388"
---

# Prefer ASSIGNING Field Symbols Over LOOP INTO Copy Targets

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Performance & Database" />
  <Badge type="danger" text="#EC NO_LOOP_INTO" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L4388" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Prefer ASSIGNING over LOOP INTO copy targets.

> **ATC Finding Message:** `Loop copies each row; use ASSIGNING with a field symbol`

## Rationale

The LOOP AT itab INTO wa statement copies every single row of an internal table into a local work area structure upon each iteration. For wide structures, nested components, or tables containing thousands of entries, this repetitive row-by-row memory copy generates significant CPU memory bus traffic and cache misses. In Clean ABAP and ABAP Cloud, iterating with `ASSIGNING FIELD-SYMBOL(<ls_row>)` binds a direct reference pointer to the table line in memory (O(1) zero-copy iteration). Alternatively, `REFERENCE INTO DATA(lo_row)` should be used when data references are explicitly required.

### Non-Compliant

```abap
DATA lv_total_amount TYPE p DECIMALS 2.

LOOP AT lt_order_items INTO DATA(ls_item).
  lv_total_amount = lv_total_amount + ls_item-net_amount.
ENDLOOP.
```

### Compliant

```abap
DATA lv_total_amount TYPE p DECIMALS 2.

LOOP AT lt_order_items ASSIGNING FIELD-SYMBOL(<ls_item>).
  lv_total_amount = lv_total_amount + <ls_item>-net_amount.
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

### Detection Details

The check evaluates `LOOP` statements. Finding code `NO_LOOPIN` is reported when `AT` and `INTO` are present without an `ASSIGNING` or `REFERENCE` target.

### Scope and Design

- Single row lookups via `READ TABLE ... INTO` are intentionally excluded from this check and handled by rule `pref-read-table` to avoid redundant findings.
- Using `ASSIGNING FIELD-SYMBOL(<ls_row>)` allows modifying fields in place without requiring an explicit `MODIFY` statement.
- When data references are needed for polymorphism or generic processing, use `LOOP AT itab REFERENCE INTO DATA(lr_row)`.

Suppress legacy copy loops with the pseudo comment `"#EC NO_LOOP_INTO`.


## Related Rules

* [Do Not Mutate or Sort Tables Currently Being Looped](/rules/no-mod-loop-tab) — <code>#EC NO_MOD_LOOP_TAB</code>
* [Replace READ TABLE with Table Expressions and line_exists](/rules/pref-read-table) — <code>#EC PREF_TAB_EXPR</code>
* [Avoid String Accumulation Inside Loops (Quadratic Memory Growth)](/rules/no-concat-loop) — <code>#EC NO_CONCAT_LOOP</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_NO_LOOP_INTO`
* **ABAP Implementation:** [/skyl/cl_no_loop_into.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_no_loop_into.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 4388)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L4388)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_NO_LOOP_INTO&title=%5BBug%5D%3A%20Issue%20in%20no-loop-into)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20no-loop-into)**
