---
title: "Prefer Pass-by-Reference for Internal Tables in Method Signatures"
description: "Eliminate deep copy memory overhead in SAP ABAP methods by passing internal tables by reference instead of by value."
keywords: "Pass by reference ABAP, Pass by value memory copy, Clean ABAP Method Parameters, SAP Memory Management"
category: "performance"
ruleId: "pref-pass-by-ref"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L2951"
---

# Prefer Pass-by-Reference for Internal Tables in Method Signatures

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Performance & Database" />
  <Badge type="warning" text="QuickFix Ready" />
  <Badge type="danger" text="#EC PREF_PASS_BY_REF" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L2951" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Slow Parameter Passing.

> **ATC Finding Message:** `Avoid pass-by-value for importing method parameters`

## Rationale

Declaring method parameters with `VALUE(it_table)` forces the ABAP runtime to perform an immediate deep copy of the entire table into a new memory allocation upon invocation. If an internal table containing thousands of rows is passed across multiple layers, memory consumption multiplies rapidly and garbage collection pressure causes latency spikes.

**Best Practice:** Pass internal tables by reference (`it_table TYPE ...` without the `VALUE` keyword). In ABAP, parameters are passed by reference by default, which passes only a pointer ($O(1)$ cost).

### Non-Compliant

```abap
" Anti-pattern: Deep-copies the entire table buffer on every method invocation
METHODS calculate_totals
  IMPORTING
    VALUE(it_items) TYPE ty_item_table.
```

### Compliant

```abap
" Clean ABAP: Zero-copy pointer reference passed instantly
METHODS calculate_totals
  IMPORTING
    it_items TYPE ty_item_table.
```

## Automated QuickFix

This rule provides an **automated QuickFix** directly in Eclipse ABAP Development Tools (ADT):
1. Position the cursor on the flagged statement.
2. Press <kbd>Ctrl</kbd> + <kbd>1</kbd> (Quick Assist).
3. Select the automated refactoring to apply the clean syntax immediately.

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC PREF_PASS_BY_REF

" SAP CI_ prefix format:
... "#EC CI_PREF_PASS_BY_REF
```


## Related Rules

* [Limit Method Parameter Count and Require Multi-Line Signatures](/rules/max-params) — <code>#EC MAX_PARAMS_COUNT</code>
* [Avoid Obsolete CALL METHOD](/rules/no-call-method) — <code>#EC NO_CALL_METHOD</code>
* [Omit Redundant EXPORTING in Method Calls](/rules/no-call-exporting) — <code>#EC NO_CALL_EXPORTING</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_PREF_PASS_BY_REF`
* **ABAP Implementation:** [/skyl/cl_pref_pass_by_ref.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_pref_pass_by_ref.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 2951)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L2951)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_PREF_PASS_BY_REF&title=%5BBug%5D%3A%20Issue%20in%20pref-pass-by-ref)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20pref-pass-by-ref)**
