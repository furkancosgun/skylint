---
title: "Specify TRANSPORTING in Internal Table MODIFY Inside Loops"
description: "Optimize ABAP internal table mutations inside loops by specifying TRANSPORTING fields or using in-place field symbols to eliminate full-structure copying."
keywords: "pref-transport, MODIFY itab, TRANSPORTING, Clean ABAP, SAP ATC performance"
category: "performance"
ruleId: "pref-transport"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L2542"
---

# Specify TRANSPORTING in Internal Table MODIFY Inside Loops

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Performance & Database" />
  <Badge type="danger" text="#EC PREF_TRANSPORT" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L2542" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Avoid MODIFY itab in LOOP without TRANSPORTING clause.

> **ATC Finding Message:** `Specify TRANSPORTING fields in MODIFY itab inside loop for performance`

## Rationale

Using MODIFY itab FROM workarea inside a loop without a TRANSPORTING clause causes the ABAP runtime to perform a full deep copy of every component from the work area into the internal table row on every iteration. For wide table structures, nested tables, or tables with large text fields, copying untouched columns wastes significant CPU cycles, causes CPU cache misses, and triggers memory reallocations. Clean ABAP recommends adding TRANSPORTING to update only modified columns, or even better, updating fields directly in memory using field symbols (ASSIGNING FIELD-SYMBOL) for zero-copy performance.

### Non-Compliant

```abap
LOOP AT lt_orders INTO DATA(ls_order).
  ls_order-processing_status = 'COMPLETED'.
  MODIFY lt_orders FROM ls_order INDEX sy-tabix.
ENDLOOP.
```

### Compliant

```abap
LOOP AT lt_orders ASSIGNING FIELD-SYMBOL(<ls_order>).
  <ls_order>-processing_status = 'COMPLETED'.
ENDLOOP.
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC PREF_TRANSPORT

" SAP CI_ prefix format:
... "#EC CI_PREF_TRANSPORT
```

### Detection Details

The check evaluates `MODIFY` statements inside `LOOP ... ENDLOOP` blocks targeting internal tables (identified by `FROM` or `INDEX`). If the `TRANSPORTING` clause is omitted, finding code `PREF_TRNSP` is reported. Database table `MODIFY` statements are automatically excluded.

### Modern Zero-Copy Alternatives

While adding `TRANSPORTING col1 col2` eliminates unnecessary field copying, the preferred Clean ABAP approach is mutating table rows in place using field symbols: `LOOP AT lt_tab ASSIGNING FIELD-SYMBOL(<ls_row>)`. This completely avoids the overhead of `MODIFY` statements.

Suppress intentional full-structure updates with the pseudo comment `"#EC PREF_TRANSPORT`.


## Related Rules

* [Do Not Mutate or Sort Tables Currently Being Looped](/rules/no-mod-loop-tab) — <code>#EC NO_MOD_LOOP_TAB</code>
* [Prefer ASSIGNING Field Symbols Over LOOP INTO Copy Targets](/rules/no-loop-into) — <code>#EC NO_LOOP_INTO</code>
* [Replace READ TABLE with Table Expressions and line_exists](/rules/pref-read-table) — <code>#EC PREF_TAB_EXPR</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_PREF_TRANSPORT`
* **ABAP Implementation:** [/skyl/cl_pref_transport.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_pref_transport.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 2542)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L2542)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_PREF_TRANSPORT&title=%5BBug%5D%3A%20Issue%20in%20pref-transport)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20pref-transport)**
