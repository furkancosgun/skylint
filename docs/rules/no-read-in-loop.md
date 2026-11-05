---
title: "Avoid Linear READ TABLE Scans Inside Loops"
description: "Find READ TABLE statements with WITH KEY or WHERE inside a loop, which rescan the internal table on every pass, and replace them with hashed or sorted table keys."
keywords: "no-read-in-loop, READ TABLE inside loop, O(N*M) internal table scan, hashed table lookup ABAP, ABAP loop performance, SAP ATC check"
category: "performance"
ruleId: "no-read-in-loop"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L5955"
---

# Avoid Linear READ TABLE Scans Inside Loops

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Performance & Database" />
  <Badge type="danger" text="#EC NO_READ_LOOP" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L5955" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Avoid linear READ TABLE scans inside loop iterations.

> **ATC Finding Messages:**
> - `READ TABLE ... WITH KEY inside a loop scans the table on every pass`
> - `READ TABLE ... WHERE inside a loop scans the table on every pass`

## Rationale

A READ TABLE that addresses rows through WITH KEY or WHERE walks the internal table entry by entry, so placing it inside a LOOP turns the routine into an O(N*M) scan: doubling both tables quadruples the work, and code that passes a smoke test with fifty rows stalls once production feeds it fifty thousand. Declaring the looked-up table as HASHED or SORTED with the searched component as key, or resolving the values in one pass before the loop, keeps each lookup at constant or logarithmic cost. The rule reports only the linear access forms; reads through WITH TABLE KEY, BINARY SEARCH or INDEX address a declared key and stay unreported.

### Non-Compliant

```abap
LOOP AT lt_orders INTO DATA(ls_order).
  READ TABLE lt_items INTO DATA(ls_item) WITH KEY order_id = ls_order-id.
  APPEND ls_item TO lt_selected.
ENDLOOP.
```

### Compliant

```abap
DATA lt_items_by_id TYPE HASHED TABLE OF ty_item WITH UNIQUE KEY order_id.
lt_items_by_id = VALUE #( FOR ls_item IN lt_items ( ( ls_item ) ) ).

LOOP AT lt_orders INTO DATA(ls_order).
  READ TABLE lt_items_by_id INTO DATA(ls_item) WITH TABLE KEY order_id = ls_order-id.
  APPEND ls_item TO lt_selected.
ENDLOOP.
```

## Configuration & Thresholds

This check can be fine-tuned directly in the ATC Check Variant Editor (`CHKV`) in Eclipse ADT:

| Parameter Name | Data Type | Default Value | Description & Guidance |
|---|---|:---:|---|
| `CHECK_WITH_KEY` | `Boolean` | <code>true</code> | Report READ TABLE ... WITH KEY inside a loop, because the key is compared against every row. Disable when a codebase only treats the WHERE form as a defect while table types are still being converted. |
| `CHECK_WHERE` | `Boolean` | <code>true</code> | Report READ TABLE ... WHERE inside a loop, because a WHERE condition never engages a table key and always visits all rows. Disable to allow condition based reads during a migration. |

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC NO_READ_LOOP

" SAP CI_ prefix format:
... "#EC CI_NO_READ_LOOP
```

## Access forms

Only `READ TABLE` statements inside a `LOOP`, `DO` or `WHILE` body are evaluated, and key access is separated from linear access:

| Access form | Inside a loop |
|---|---|
| `READ TABLE lt INTO ls WITH KEY f = v.` | reported (`NO_RD_WKEY`) |
| `READ TABLE lt TRANSPORTING NO FIELDS WITH KEY f = v.` | reported (`NO_RD_WKEY`) |
| `READ TABLE lt INTO ls WHERE f = v.` | reported (`NO_RD_WHRE`) |
| `READ TABLE lt INTO ls WITH TABLE KEY f = v.` | allowed, addresses a declared key |
| `READ TABLE lt INTO ls WITH KEY f = v BINARY SEARCH.` | allowed, logarithmic search |
| `READ TABLE lt INTO ls INDEX lv_index.` | allowed, constant time |

## Notes

- `READ LINE`, `READ REPORT`, `READ DATASET` and the EML `READ ENTITIES` form are not internal table reads and are never reported.
- Keyword tokens are only recognised when they carry no compiler reference, so a variable or component named `where` or `key` cannot raise a finding.
- The loop does not have to iterate over the table being read; a linear read of any table while a loop is open repeats the scan on every pass.
- Fix a finding by declaring the read table `HASHED` or `SORTED` with the searched component as key and reading it with `WITH TABLE KEY`, or by resolving all lookups in a single pass before the loop.
- Suppress an intentional read with `"#EC NO_READ_LOOP` on the statement.


## Related Rules

* [Avoid Unindexed Nested LOOP AT Statements](/rules/no-nested-loop) — <code>#EC NO_NESTED_LOOP</code>
* [Use WITH KEY Instead of WHERE in READ TABLE Statements](/rules/pref-read-key) — <code>#EC PREF_READ_KEY</code>
* [Avoid Database Queries Inside Loops (N+1 Query Antipattern)](/rules/no-db-in-loop) — <code>#EC NO_DB_IN_LOOP</code>
* [Do Not Mutate or Sort Tables Currently Being Looped](/rules/no-mod-loop-tab) — <code>#EC NO_MOD_LOOP_TAB</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_NO_READ_IN_LOOP`
* **ABAP Implementation:** [/skyl/cl_no_read_in_loop.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_no_read_in_loop.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 5955)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L5955)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_NO_READ_IN_LOOP&title=%5BBug%5D%3A%20Issue%20in%20no-read-in-loop)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20no-read-in-loop)**
