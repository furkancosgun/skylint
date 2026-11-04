---
title: "Do Not Mutate or Sort Tables Currently Being Looped"
description: "Prevent iterator corruption and performance degradation in ABAP loops by avoiding APPEND, INSERT, DELETE, or SORT on tables being traversed."
keywords: "no-mod-loop-tab, table mutation in loop, SORT in loop, Clean ABAP loop iterator, SAP ATC"
category: "performance"
ruleId: "no-mod-loop-tab"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L3345"
---

# Do Not Mutate or Sort Tables Currently Being Looped

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Performance & Database" />
  <Badge type="danger" text="#EC NO_MOD_LOOP_TAB" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L3345" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Avoid mutating or sorting tables inside loops.

> **ATC Finding Messages:**
> - `Do not add, delete, sort, collect, or clear rows from the table currently being looped`
> - `Avoid sorting internal tables inside loops to prevent severe performance degradation`

## Rationale

Mutating the internal table currently being traversed inside a LOOP AT itab block invalidates the loop iterator and destabilizes index tracking. Appending, inserting, or deleting rows alters sy-tabix and row positions, causing skipped elements, duplicate record processing, or runtime boundary violations. Sorting the driving table within the loop scrambles iteration order and corrupts internal binary search states. Furthermore, executing SORT on any internal table inside a loop introduces an O(N * M log M) algorithmic bottleneck. Clean ABAP requires modifying rows in-place using field symbols, collecting additions into a separate result table, and pre-sorting tables before entering loops.

### Non-Compliant

```abap
LOOP AT lt_items INTO DATA(ls_item).
  IF ls_item-is_cancelled = abap_true.
    DELETE lt_items INDEX sy-tabix.
  ENDIF.
  SORT lt_items BY item_id.
ENDLOOP.
```

### Compliant

```abap
DELETE lt_items WHERE is_cancelled = abap_true.
SORT lt_items BY item_id.

LOOP AT lt_items ASSIGNING FIELD-SYMBOL(<ls_item>).
  " Process active item safely in memory
ENDLOOP.
```

## Configuration & Thresholds

This check can be fine-tuned directly in the ATC Check Variant Editor (`CHKV`) in Eclipse ADT:

| Parameter Name | Data Type | Default Value | Description & Guidance |
|---|---|:---:|---|
| `CHECK_APPEND` | `Boolean` | <code>true</code> | Detect APPEND statements targeting the loop driving table (default true). |
| `CHECK_INSERT` | `Boolean` | <code>true</code> | Detect INSERT statements targeting the loop driving table (default true). |
| `CHECK_MODIFY` | `Boolean` | <code>true</code> | Detect MODIFY statements targeting the loop driving table (default true). |
| `CHECK_DELETE` | `Boolean` | <code>true</code> | Detect DELETE statements targeting the loop driving table (default true). |
| `CHECK_CLEAR` | `Boolean` | <code>true</code> | Detect CLEAR and FREE statements targeting the loop driving table (default true). |
| `CHECK_SORT` | `Boolean` | <code>true</code> | Detect SORT statements targeting the loop driving table (default true). |
| `CHECK_SORT_ANY` | `Boolean` | <code>true</code> | Detect SORT statements on any internal table inside a loop body (default true). |
| `CHECK_COLLECT` | `Boolean` | <code>true</code> | Detect COLLECT statements targeting the loop driving table (default true). |

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC NO_MOD_LOOP_TAB

" SAP CI_ prefix format:
... "#EC CI_NO_MOD_LOOP_TAB
```

### Detection Details

The check tracks an internal stack of active `LOOP AT <table_name>` contexts. Finding code `NO_MOD_LTB` is raised when operations mutate the driving table, while `NO_SORT_LP` is reported when any internal table is sorted within a loop body.

| Configuration Parameter | Targeted Statement |
| --- | --- |
| `CHECK_APPEND` | `APPEND ... TO <loop_table>` |
| `CHECK_INSERT` | `INSERT ... INTO [TABLE] <loop_table>` |
| `CHECK_MODIFY` | `MODIFY [TABLE] <loop_table>` |
| `CHECK_DELETE` | `DELETE [TABLE] <loop_table>` or `DELETE ADJACENT` |
| `CHECK_CLEAR` | `CLEAR <loop_table>` or `FREE <loop_table>` |
| `CHECK_SORT` | `SORT <loop_table>` |
| `CHECK_SORT_ANY` | `SORT <any_table>` inside loop |
| `CHECK_COLLECT` | `COLLECT ... INTO <loop_table>` |

Suppress intentional mutations with the pseudo comment `"#EC NO_MOD_LOOP_TAB`.


## Related Rules

* [Avoid String Accumulation Inside Loops (Quadratic Memory Growth)](/rules/no-concat-loop) — <code>#EC NO_CONCAT_LOOP</code>
* [Restrict Database Modifications to Customer-Owned Tables](/rules/no-mod-std-table) — <code>#EC NO_MOD_STD_TABLE</code>
* [Specify TRANSPORTING in Internal Table MODIFY Inside Loops](/rules/pref-transport) — <code>#EC PREF_TRANSPORT</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_NO_MOD_LOOP_TAB`
* **ABAP Implementation:** [/skyl/cl_no_mod_loop_tab.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_no_mod_loop_tab.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 3345)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L3345)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_NO_MOD_LOOP_TAB&title=%5BBug%5D%3A%20Issue%20in%20no-mod-loop-tab)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20no-mod-loop-tab)**
