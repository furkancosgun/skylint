---
title: "Modernize Downcasting with CAST #( ) Expressions and Inline Redundant Helpers"
description: "Modernize ABAP downcasts using CAST #( ) constructor expressions and eliminate redundant intermediate variables in ABAP Cloud."
keywords: "pref-downcast, CAST #(), downcast, Clean ABAP, ABAP Cloud"
category: "clean-abap"
ruleId: "pref-downcast"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L3313"
---

# Modernize Downcasting with CAST #( ) Expressions and Inline Redundant Helpers

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="warning" text="QuickFix Ready" />
  <Badge type="danger" text="#EC PREF_CAST" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L3313" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Modernize Downcasting (CAST #( ) & inlining).

> **ATC Finding Messages:**
> - `Prefer CAST #( ) constructor expression over ?= downcast`
> - `CAST helper is read exactly once in the next statement; inline it`

## Rationale

The legacy ?= and MOVE ?TO operators are obsolete procedural downcast idioms that cannot participate in functional chaining or modern expression trees. Using modern constructor expression CAST #( ) produces clean, type-safe downcasts and enables chaining directly into method calls or assignments. Furthermore, declaring temporary single-use helper variables solely to store downcast results introduces clutter and unnecessary state. Skylint identifies obsolete cast syntax (PREF_CAST) and single-use intermediate downcast variables (PREF_INLCS), providing quickfixes TOCAST and INLINECST.

### Non-Compliant

```abap
lo_billing_item ?= lo_source_item.
DATA(lo_invoice_node) = CAST lcl_invoice_node( io_tree_node ).
lv_total_amount = lo_invoice_node->get_total_amount( ).
```

### Compliant

```abap
lo_billing_item = CAST #( lo_source_item ).
lv_total_amount = CAST lcl_invoice_node( io_tree_node )->get_total_amount( ).
```

## Automated QuickFix

This rule provides an **automated QuickFix** directly in Eclipse ABAP Development Tools (ADT):
1. Position the cursor on the flagged statement.
2. Press <kbd>Ctrl</kbd> + <kbd>1</kbd> (Quick Assist).
3. Select the automated refactoring to apply the clean syntax immediately.

## Configuration & Thresholds

This check can be fine-tuned directly in the ATC Check Variant Editor (`CHKV`) in Eclipse ADT:

| Parameter Name | Data Type | Default Value | Description & Guidance |
|---|---|:---:|---|
| `CHECK_CAST_SYNTAX` | `Boolean` | <code>true</code> | Report obsolete downcast operators (?= and MOVE ?TO) in favor of the modern CAST #( ) constructor expression. |
| `CHECK_INLINE_CAST` | `Boolean` | <code>true</code> | Report intermediate single-use variables holding downcast results that can be directly inlined into subsequent statements. |

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC PREF_CAST

" SAP CI_ prefix format:
... "#EC CI_PREF_CAST
```

## Detection Capabilities and Quickfixes

1. **Downcast Operator Modernization (`PREF_CAST`):** Identifies `?=` and `MOVE ... ?TO ...` assignments, offering the `TOCAST` quickfix to convert them into `target = CAST #( source )`.
2. **Downcast Inlining (`PREF_INLCS`):** Identifies inline declarations `DATA(lo_typed) = CAST type( lo_base )` where `lo_typed` is consumed exactly once in the immediately following statement as a method call receiver or assignment source, offering the `INLINECST` quickfix to inline the expression.

Suppress findings using pseudo comments `"#EC PREF_DOWNCAST` / `"#EC PREF_INLINE_CAST`.


## Related Rules

* [Prefer NEW #( ) for Object Creation and RAISE EXCEPTION NEW](/rules/pref-new-op) — <code>#EC PREF_NEW_OPERATOR</code>
* [Declare Instance Constructor in PUBLIC SECTION Regardless of Instantiation Scope](/rules/pref-pub-ctor) — <code>#EC PREF_PUB_CTOR</code>
* [Name Static Factory Methods CREATE_* When They Return Their Own Class](/rules/pref-factory-name) — <code>#EC PREF_FACTORY_NAME</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_PREF_DOWNCAST`
* **ABAP Implementation:** [/skyl/cl_pref_downcast.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_pref_downcast.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 3313)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L3313)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_PREF_DOWNCAST&title=%5BBug%5D%3A%20Issue%20in%20pref-downcast)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20pref-downcast)**
