---
title: "Avoid Duplicate Subexpressions in a Single Statement"
description: "Detect duplicate table expressions and method calls in ABAP statements to apply Common Subexpression Elimination."
keywords: "duplicate table expression, common subexpression ABAP, ABAP performance, Clean ABAP, SAP ATC check, no-dup-subexpr"
category: "anti-patterns"
ruleId: "no-dup-subexpr"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L5841"
---

# Avoid Duplicate Subexpressions in a Single Statement

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="info" text="Note" />
  <Badge type="tip" text="Anti-Patterns & Bad Practices" />
  <Badge type="danger" text="#EC NO_DUP_SUBEXPR" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L5841" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Avoid duplicate subexpressions in the same statement.

> **ATC Finding Message:** `Avoid repeating duplicate subexpressions; evaluate once into a variable`

## Rationale

Repeating identical subexpressions - such as table expressions (lt_items[ 1 ]-amount) or functional method calls (lo_calc->get_rate( )) - within a single statement causes redundant table lookups, secondary hash computations, or repeated method invocations. In performance-critical logic, this wastes CPU cycles and increases runtime overhead. Evaluate common subexpressions once into a local helper variable or field symbol.

### Non-Compliant

```abap
lv_total_amount = lt_order_items[ 1 ]-net_amount + lt_order_items[ 1 ]-tax_amount.
```

### Compliant

```abap
DATA(ls_order_item) = lt_order_items[ 1 ].
lv_total_amount = ls_order_item-net_amount + ls_order_item-tax_amount.
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC NO_DUP_SUBEXPR

" SAP CI_ prefix format:
... "#EC CI_NO_DUP_SUBEXPR
```

### Subexpressions detected

The check scans statements for duplicate subexpressions, focusing on:
- Table expressions with square brackets: `itab[ ... ]`
- Functional method invocations: `oref->method( ... )` or `class=>method( ... )`

| Statement Pattern | Finding Raised |
| --- | --- |
| `lv_tot = lt_orders[ 1 ]-net + lt_orders[ 1 ]-tax.` | yes (`NO_DUPSBX`) |
| `lv_val = lo_calc->eval( 10 ) + lo_calc->eval( 10 ).` | yes (`NO_DUPSBX`) |
| `DATA(ls) = lt_orders[ 1 ]. lv_tot = ls-net + ls-tax.` | no (Common Subexpression Eliminated) |
| `lv_tot = lt_orders[ 1 ]-net + lt_orders[ 2 ]-tax.` | no (Different subexpression indices) |

### Suppression

When duplicate subexpressions have side effects or intentional non-deterministic results, suppress with `"#EC NO_DUP_SUBEXPR`.


## Related Rules

* [Replace READ TABLE with Table Expressions and line_exists](/rules/pref-read-table) — <code>#EC PREF_TAB_EXPR</code>
* [Sort Internal Tables Before DELETE ADJACENT DUPLICATES](/rules/no-dedup-no-sort) — <code>#EC NO_DEDUP_NO_SORT</code>
* [Specify Explicit Sort Fields with SORT BY](/rules/pref-sort-key) — <code>#EC PREF_SORT_KEY</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_NO_DUP_SUBEXP`
* **ABAP Implementation:** [/skyl/cl_no_dup_subexp.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_no_dup_subexp.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 5841)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L5841)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_NO_DUP_SUBEXP&title=%5BBug%5D%3A%20Issue%20in%20no-dup-subexpr)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20no-dup-subexpr)**
