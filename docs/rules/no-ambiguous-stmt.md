---
title: "Make MODIFY, DELETE, INSERT and UPDATE Unambiguous for Itab and Database"
description: "Disambiguate ABAP MODIFY, DELETE, INSERT and UPDATE between internal tables and ABAP SQL by requiring the TABLE keyword or @ host escapes in ATC."
keywords: "ABAP MODIFY TABLE, ambiguous ABAP statement, ABAP SQL @ escape, SAP ATC, no-ambiguous-stmt"
category: "clean-abap"
ruleId: "no-ambiguous-stmt"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L4717"
---

# Make MODIFY, DELETE, INSERT and UPDATE Unambiguous for Itab and Database

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="danger" text="#EC NO_AMBIGUOUS_STMT" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L4717" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Avoid ambiguous statements between itab and database.

> **ATC Finding Message:** `Ambiguous statement; use explicit syntax (TABLE keyword or @ for SQL variables)`

## Rationale

A statement like `MODIFY lt_order_items FROM ls_order_item.` can update an internal table or an ABAP SQL table, and the compiler decides from the target's type - information that is invisible at the call site and easy to break when a variable shadows a DDIC table. The explicit forms (`MODIFY TABLE ...` or `MODIFY zorder FROM @ls_order`) state the intent for the reader and keep the statement stable when tables are renamed. The rule also reports the shorthand forms without a visible target, which are ambiguous by construction.

### Non-Compliant

```abap
MODIFY lt_order_items FROM ls_order_item.
```

### Compliant

```abap
MODIFY TABLE lt_order_items FROM ls_order_item.
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC NO_AMBIGUOUS_STMT

" SAP CI_ prefix format:
... "#EC CI_NO_AMBIGUOUS_STMT
```

### Ambiguous versus explicit forms

| Ambiguous | Why it is ambiguous | Explicit form |
| --- | --- | --- |
| `MODIFY lt_items FROM ls_item.` | itab line update or SQL update? | `MODIFY TABLE lt_items FROM ls_item.` |
| `DELETE lt_items FROM ls_item.` | itab delete or SQL delete? | `DELETE TABLE lt_items FROM ls_item.` or `DELETE lt_items INDEX 1.` |
| `DELETE lt_items.` | clears an itab but looks like SQL | `DELETE TABLE lt_items.` |
| `MODIFY zorder FROM ls_order.` | SQL without an escaped host variable | `MODIFY zorder FROM @ls_order.` |

The following are accepted without a finding:

- any statement that already contains `TABLE`;
- `DELETE ... INDEX`, `DELETE ... ADJACENT` and `MODIFY ... INDEX`;
- SQL `DELETE FROM zorder WHERE ...`;
- SQL statements whose source work area is escaped with `@`, e.g. `INSERT zorder FROM @ls_order` or `UPDATE zorder FROM @ls_order`.

`INSERT` and `UPDATE` are also reported when the statement consists of nothing but the keyword and a target, because no `TABLE` keyword and no escaped host variable identify the table kind.

### Remote readiness

The check is purely token based and uses no RTTI, so it also runs in remote ATC scenarios.


## Related Rules

* [Escape ABAP SQL Host Variables and Table Targets with @](/rules/pref-strict-sql) — <code>#EC PREF_STRICT_SQL</code>
* [Avoid Database Queries Inside Loops (N+1 Query Antipattern)](/rules/no-db-in-loop) — <code>#EC NO_DB_IN_LOOP</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_NO_AMBIGUOUS_STMT`
* **ABAP Implementation:** [/skyl/cl_no_ambiguous_stmt.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_no_ambiguous_stmt.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 4717)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L4717)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_NO_AMBIGUOUS_STMT&title=%5BBug%5D%3A%20Issue%20in%20no-ambiguous-stmt)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20no-ambiguous-stmt)**
