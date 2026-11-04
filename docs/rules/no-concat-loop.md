---
title: "Avoid String Accumulation Inside Loops (Quadratic Memory Growth)"
description: "Prevent quadratic string buffer allocations in ABAP loops by collecting fragments in a string table and joining them with concat_lines_of."
keywords: "no-concat-loop, string concatenation loop, concat_lines_of, Clean ABAP strings, SAP ATC"
category: "performance"
ruleId: "no-concat-loop"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L3806"
---

# Avoid String Accumulation Inside Loops (Quadratic Memory Growth)

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Performance & Database" />
  <Badge type="danger" text="#EC NO_CONCAT_LOOP" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L3806" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Avoid string concatenation inside loops.

> **ATC Finding Message:** `Accumulate parts in a table and concatenate once`

## Rationale

Repeatedly concatenating string fragments onto an accumulator variable inside a loop using &&, string templates |{ lv_result }...|, or CONCATENATE produces quadratic O(N^2) memory copying. On each iteration, the ABAP kernel allocates a brand-new dynamic string heap buffer, copies all previously accumulated bytes plus the new fragment, and marks the previous allocation for garbage collection. On loops with hundreds or thousands of iterations (such as XML, JSON, or CSV document generation), this causes severe heap fragmentation, cache misses, and CPU thrashing. In Clean ABAP, string fragments should be collected into a string_table and combined in a single linear O(N) operation using concat_lines_of( ).

### Non-Compliant

```abap
DATA lv_csv_output TYPE string.

LOOP AT lt_invoices INTO DATA(ls_invoice).
  lv_csv_output = lv_csv_output && ls_invoice-invoice_id && ',' && ls_invoice-gross_amount.
ENDLOOP.
```

### Compliant

```abap
DATA lt_csv_lines TYPE string_table.

LOOP AT lt_invoices INTO DATA(ls_invoice).
  INSERT |{ ls_invoice-invoice_id },{ ls_invoice-gross_amount }| INTO TABLE lt_csv_lines.
ENDLOOP.

DATA(lv_csv_output) = concat_lines_of( table = lt_csv_lines sep = cl_abap_char_utilities=>newline ).
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC NO_CONCAT_LOOP

" SAP CI_ prefix format:
... "#EC CI_NO_CONCAT_LOOP
```

### Detection Details

The check evaluates statements inside `LOOP`, `DO`, and `WHILE` blocks. Finding code `NO_CC_LOOP` is reported whenever a variable is written to via `COMPUTE` (using `&&` or string template `|...|`) or `CONCATENATE` and the same variable is read within the expression.

### Algorithmic Comparison

- **In-Loop Concatenation:** $O(N^2)$ time complexity. Iteration $k$ copies $k$ elements, requiring $\sum_{k=1}^N k = \frac{N(N+1)}{2}$ byte copies.
- **Table Collection with `concat_lines_of`:** $O(N)$ linear time complexity. Inserts table pointers and allocates the final buffer in a single native pass.

Suppress specific short loops with the pseudo comment `"#EC NO_CONCAT_LOOP`.


## Related Rules

* [Do Not Mutate or Sort Tables Currently Being Looped](/rules/no-mod-loop-tab) — <code>#EC NO_MOD_LOOP_TAB</code>
* [Capture sy-tabix and sy-index Immediately at Loop Start](/rules/no-late-sys-idx) — <code>#EC NO_LATE_SYS_IDX</code>
* [Specify TRANSPORTING in Internal Table MODIFY Inside Loops](/rules/pref-transport) — <code>#EC PREF_TRANSPORT</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_NO_CONCAT_LOOP`
* **ABAP Implementation:** [/skyl/cl_no_concat_loop.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_no_concat_loop.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 3806)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L3806)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_NO_CONCAT_LOOP&title=%5BBug%5D%3A%20Issue%20in%20no-concat-loop)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20no-concat-loop)**
