---
title: "Use WITH KEY Instead of WHERE in READ TABLE Statements"
description: "Improve internal table read performance in ABAP by replacing linear READ TABLE WHERE scans with optimized WITH KEY access or table expressions."
keywords: "pref-read-key, READ TABLE WITH KEY, internal table performance, secondary keys, Clean ABAP"
category: "performance"
ruleId: "pref-read-key"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L5410"
---

# Use WITH KEY Instead of WHERE in READ TABLE Statements

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Performance & Database" />
  <Badge type="danger" text="#EC PREF_READ_KEY" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L5410" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

READ With WITH KEY Instead of WHERE.

> **ATC Finding Message:** `READ TABLE WHERE - use WITH KEY so the access benefits from key optimization`

## Rationale

Using `READ TABLE ... WHERE` with conjunctions of equality expressions forces a linear row-by-row table scan because the `WHERE` condition does not engage internal table key optimization or binary search. The `WITH KEY` clause (or modern table expression `itab[ ... ]`) enables the ABAP kernel to exploit primary and secondary sorted or hashed keys for logarithmic O(log N) or constant O(1) single-line lookups. The rule specifically detects `WHERE` clauses consisting solely of `=` or `EQ` comparisons connected by `AND`, which are fully convertible to `WITH KEY`, reporting `PREF_READK` to eliminate unnecessary full table scans.

### Non-Compliant

```abap
READ TABLE lt_deliveries INTO ls_delivery
  WHERE delivery_number = lv_delivery_number
    AND item_number = lv_item_number.
```

### Compliant

```abap
READ TABLE lt_deliveries INTO ls_delivery
  WITH KEY delivery_number = lv_delivery_number
           item_number = lv_item_number.
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC PREF_READ_KEY

" SAP CI_ prefix format:
... "#EC CI_PREF_READ_KEY
```

## Scope and Key Optimization

The check inspects `READ TABLE` statements and flags only those `WHERE` clauses that can be directly mapped to `WITH KEY`:
- Conditions containing only equality operators (`=` or `EQ`) joined by `AND` are flagged.
- Conditions containing disjunctions (`OR`), negations (`NOT`), pattern comparisons (`CS`, `CP`, `LIKE`), range expressions (`IN`, `BETWEEN`), or relational inequalities (`>`, `<`, `>=`, `<=`) are not flagged because `WITH KEY` syntax cannot express them.

Modern ABAP Cloud code can also replace `READ TABLE ... WITH KEY` with table expressions (e.g. `ls_delivery = VALUE #( lt_deliveries[ delivery_number = lv_delivery_number item_number = lv_item_number ] OPTIONAL ).`).


## Related Rules

* [Replace READ TABLE with Table Expressions and line_exists](/rules/pref-read-table) — <code>#EC PREF_TAB_EXPR</code>
* [Filter Internal Tables with LOOP AT WHERE Instead of a CONTINUE Guard](/rules/pref-loop-where) — <code>#EC PREF_LOOP_WHERE</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_PREF_READ_KEY`
* **ABAP Implementation:** [/skyl/cl_pref_read_key.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_pref_read_key.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 5410)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L5410)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_PREF_READ_KEY&title=%5BBug%5D%3A%20Issue%20in%20pref-read-key)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20pref-read-key)**
