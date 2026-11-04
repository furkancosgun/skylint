---
title: "Prefer REDUCE #( ) Expression over Simple Aggregation LOOP"
description: "Prefer REDUCE #( ) Expression over Simple Aggregation LOOP - Clean ABAP guidelines, modern SAP syntax rules, and automated ATC code inspection for SAP S/4HANA and ABAP Cloud."
keywords: "Clean ABAP, SAP ATC Check, ABAP Cloud, S/4HANA Readiness, pref-reduce, clean-abap"
category: "clean-abap"
ruleId: "pref-reduce"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L238"
---

# Prefer REDUCE #( ) Expression over Simple Aggregation LOOP

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="danger" text="#EC PREF_REDUCE" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L238" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Prefer REDUCE #( ) expression over simple aggregation LOOP.

> **ATC Finding Message:** `Prefer REDUCE #( ) expression over simple aggregation LOOP`

## Rationale

A loop that only accumulates a sum or builds a single aggregated value mixes imperative control flow with a simple calculation and hides the real intent. Such loops are longer to read and easy to break when the accumulator initialization or the loop body changes. REDUCE #( ) expresses the aggregation declaratively inside one expression and removes the mutable helper state. Use REDUCE for straightforward sums, counts, and string concatenation, and keep a loop only when it performs additional side effects.

### Non-Compliant

```abap
LOOP AT lt_orders INTO ls_order.
  lv_total = lv_total + ls_order-amount.
ENDLOOP.
```

### Compliant

```abap
lv_total = REDUCE i( INIT total = 0
  FOR ls_order IN lt_orders
  NEXT total = total + ls_order-amount ).
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC PREF_REDUCE

" SAP CI_ prefix format:
... "#EC CI_PREF_REDUCE
```


## Related Rules

* [Prefer lines( ) over DESCRIBE TABLE](/rules/pref-lines) — <code>#EC PREF_LINES</code>
* [Modernize READ TABLE (Table Expressions & line_exists)](/rules/pref-read-table) — <code>#EC PREF_TAB_EXPR</code>
* [Prefer ASSIGNING over LOOP INTO Copy Targets](/rules/no-loop-into) — <code>#EC NO_LOOP_INTO</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_PREF_REDUCE`
* **ABAP Implementation:** [/skyl/cl_pref_reduce.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_pref_reduce.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 238)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L238)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_PREF_REDUCE&title=%5BBug%5D%3A%20Issue%20in%20pref-reduce)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20pref-reduce)**
