---
title: "Specify ASCENDING or DESCENDING on Every Sort Key"
description: "Require explicit ASCENDING or DESCENDING on ABAP SORT keys to remove implicit ordering and stabilise multi-key internal table sorts in ATC."
keywords: "ABAP SORT ASCENDING DESCENDING, SORT BY internal table, implicit sort order ABAP, SAP ATC, pref-sort-order"
category: "clean-abap"
ruleId: "pref-sort-order"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L4660"
---

# Specify ASCENDING or DESCENDING on Every Sort Key

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="danger" text="#EC PREF_SORT_ORDER" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L4660" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Explicitly specify ASCENDING or DESCENDING sort order.

> **ATC Finding Message:** `Specify ASCENDING or DESCENDING sort order explicitly`

## Rationale

`SORT lt_orders BY customer_id order_date.` silently falls back to the implicit ascending order, and a later edit that adds a descending key mixes explicit and implicit directions in one statement - the classic source of a mysteriously ordered list. Writing the direction for every key, or one direction before BY, makes the intent explicit, stable and reviewable. The check can additionally demand an explicit order for plain table sorts that omit BY entirely.

### Non-Compliant

```abap
SORT lt_orders BY customer_id order_date.
```

### Compliant

```abap
SORT lt_orders BY customer_id ASCENDING order_date DESCENDING.
```

## Configuration & Thresholds

This check can be fine-tuned directly in the ATC Check Variant Editor (`CHKV`) in Eclipse ADT:

| Parameter Name | Data Type | Default Value | Description & Guidance |
|---|---|:---:|---|
| `CHECK_BY_ONLY` | `Boolean` | <code>true</code> | Only require an explicit direction when the BY addition is used; set to false to also report plain SORT lt_orders. (default enabled). |

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC PREF_SORT_ORDER

" SAP CI_ prefix format:
... "#EC CI_PREF_SORT_ORDER
```

### What counts as explicit

| Statement | Result |
| --- | --- |
| `SORT lt_orders BY customer_id order_date.` | `PREF_SORT` - the second key falls back to the implicit order |
| `SORT lt_orders BY customer_id ASCENDING order_date DESCENDING.` | ok - every key has a direction |
| `SORT lt_orders DESCENDING BY customer_id order_date.` | ok - the direction before `BY` applies to all keys |
| `SORT lt_orders BY field1 AS TEXT ASCENDING field2 DESCENDING.` | ok - `AS TEXT` is a modifier, not a key |
| `SORT lt_orders BY (lv_dynamic_field).` | ok - dynamic keys are not evaluated |
| `SORT lt_orders.` | reported only when `CHECK_BY_ONLY` is off |

The check reports the whole `SORT` statement once, on the first key it finds without a direction, so a statement with several unspecified keys produces a single finding.

### Tuning

Only ascending order is implicit in ABAP, so the default configuration (`CHECK_BY_ONLY = abap_true`) targets the real risk: mixed or missing directions after `BY`. Setting `CHECK_BY_ONLY = abap_false` additionally reports `SORT lt_orders.`; that is stricter than the Clean ABAP baseline and usually only worth enabling for new code. Suppress an intentionally stable sort (an itab that is already sorted and may be re-sorted cheaply) with `"#EC PREF_SORT_ORDER`.


## Related Rules

* [Do Not Mutate or Sort Tables Currently Being Looped](/rules/no-mod-loop-tab) — <code>#EC NO_MOD_LOOP_TAB</code>
* [Eliminate Obsolete Control Flow and Procedural Statements](/rules/no-obs-control) — <code>#EC NO_OBS_CONTROL</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_PREF_SORT_ORDER`
* **ABAP Implementation:** [/skyl/cl_pref_sort_order.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_pref_sort_order.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 4660)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L4660)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_PREF_SORT_ORDER&title=%5BBug%5D%3A%20Issue%20in%20pref-sort-order)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20pref-sort-order)**
