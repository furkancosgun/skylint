---
title: "Avoid Duplicate Subexpressions in the Same Statement"
description: "Avoid duplicate table expressions and method calls in the same ABAP statement (Common Subexpression Elimination)."
keywords: "ABAP Common Subexpression Elimination, Duplicate Table Expression, ABAP Hash Lookup Optimization, Clean ABAP Performance"
category: "anti-patterns"
ruleId: "no-dup-subexpr"
---

# Avoid Duplicate Subexpressions in the Same Statement

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="info" text="Note" />
  <Badge type="tip" text="Anti-Patterns & Bad Practices" />
  <Badge type="danger" text="#EC NO_DUP_SUBEXPR" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Avoid duplicate subexpressions in the same statement.

> **ATC Finding Message:** `Avoid repeating duplicate subexpressions; evaluate once into a variable`

## Rationale

Evaluating the exact same table expression (e.g. `lt_orders[ 1 ]-net + lt_orders[ 1 ]-vat`) or method call multiple times in the same statement triggers redundant internal table index lookups, hash computations, or method executions. In performance-critical logic, this causes unnecessary overhead.

**Best Practice:** Evaluate the common subexpression once into a local helper variable or field-symbol and reuse it.

### Non-Compliant

```abap
lv_total = lt_orders[ 1 ]-net + lt_orders[ 1 ]-vat.
```

### Compliant

```abap
DATA(ls_order) = lt_orders[ 1 ].
lv_total = ls_order-net + ls_order-vat.
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC NO_DUP_SUBEXPR

" SAP CI_ prefix format:
... "#EC CI_NO_DUP_SUBEXPR
```


## Related Rules

* [Modernize READ TABLE (Table Expressions & line_exists)](/rules/pref-read-table) — <code>#EC PREF_TAB_EXPR</code>
* [Sort Internal Tables Before DELETE ADJACENT DUPLICATES](/rules/no-dedup-no-sort) — <code>#EC NO_DEDUP_NO_SORT</code>
* [Specify an Explicit SORT Key with BY](/rules/pref-sort-key) — <code>#EC PREF_SORT_KEY</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_NO_DUP_SUBEXP`
* **Implementation File:** [#skyl#cl_no_dup_subexp.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_no_dup_subexp.clas.abap)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_NO_DUP_SUBEXP&title=%5BBug%5D%3A%20Issue%20in%20no-dup-subexpr)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20no-dup-subexpr)**
