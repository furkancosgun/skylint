---
title: "Declare Standard Internal Tables Explicitly with TYPE STANDARD TABLE OF"
description: "Enforce explicit TYPE STANDARD TABLE OF declarations over ambiguous TYPE TABLE OF shorthand in modern ABAP Cloud code."
keywords: "pref-std-table, STANDARD TABLE, internal table, Clean ABAP, ABAP Cloud"
category: "clean-abap"
ruleId: "pref-std-table"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L3693"
---

# Declare Standard Internal Tables Explicitly with TYPE STANDARD TABLE OF

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="warning" text="QuickFix Ready" />
  <Badge type="danger" text="#EC PREF_STD_TABLE" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L3693" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Prefer explicit TYPE STANDARD TABLE OF over TYPE TABLE OF.

> **ATC Finding Message:** `Specify the table kind explicitly: TYPE STANDARD TABLE OF`

## Rationale

The shorthand declaration TYPE TABLE OF implicitly defaults to a standard internal table, requiring readers to know the language default to deduce access complexity and memory characteristics. Explicitly writing TYPE STANDARD TABLE OF clarifies table categorization alongside SORTED and HASHED alternatives, making linear search costs transparent and easing future refactoring when changing table categories. Skylint scans type sequences for TYPE TABLE OF and reports PREF_STDTB with the ADD_STDTAB quickfix.

### Non-Compliant

```abap
DATA lt_sales_orders TYPE TABLE OF zsales_order.
```

### Compliant

```abap
DATA lt_sales_orders TYPE STANDARD TABLE OF zsales_order.
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
... "#EC PREF_STD_TABLE

" SAP CI_ prefix format:
... "#EC CI_PREF_STD_TABLE
```

## Detection and Quickfix Details

The check identifies occurrences of the token sequence `TYPE TABLE OF` across all declaration and typing contexts (`DATA`, `TYPES`, `METHODS` parameter signatures, and `FIELD-SYMBOLS`). The `ADD_STDTAB` quickfix automatically rewrites the sequence as `TYPE STANDARD TABLE OF`.

Suppress individual findings with pseudo comment `"#EC PREF_STD_TABLE`.


## Related Rules

* [Restrict Database Modifications to Customer-Owned Tables](/rules/no-mod-std-table) — <code>#EC NO_MOD_STD_TABLE</code>
* [Replace READ TABLE with Table Expressions and line_exists](/rules/pref-read-table) — <code>#EC PREF_TAB_EXPR</code>
* [Use lines( ) Instead of DESCRIBE TABLE LINES](/rules/pref-lines) — <code>#EC PREF_LINES</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_PREF_STD_TABLE`
* **ABAP Implementation:** [/skyl/cl_pref_std_table.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_pref_std_table.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 3693)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L3693)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_PREF_STD_TABLE&title=%5BBug%5D%3A%20Issue%20in%20pref-std-table)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20pref-std-table)**
