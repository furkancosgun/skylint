---
title: "Use lines( ) Instead of DESCRIBE TABLE LINES"
description: "Replace DESCRIBE TABLE LINES with the lines( ) built-in to drop temporary counters and obsolete statements in ABAP Cloud."
keywords: "pref-lines, lines( ), DESCRIBE TABLE, obsolete statement, Clean ABAP"
category: "clean-abap"
ruleId: "pref-lines"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L360"
---

# Use lines( ) Instead of DESCRIBE TABLE LINES

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="warning" text="QuickFix Ready" />
  <Badge type="danger" text="#EC PREF_LINES" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L360" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Prefer lines( ) over DESCRIBE TABLE ... LINES.

> **ATC Finding Message:** `Use lines( ) function instead of DESCRIBE TABLE ... LINES`

## Rationale

DESCRIBE TABLE ... LINES writes the row count into a helper variable, so the question about the table size and the code that uses the answer are separated by an extra declaration and an extra statement. The lines( ) built-in returns the count as a value, which can be tested inline in IF or WHILE and passed to any expression without a temporary variable. The check reports PREF_LINES and the TOLINES quickfix replaces the statement with an equivalent lines( ) assignment.

### Non-Compliant

```abap
DESCRIBE TABLE lt_order_items LINES lv_item_count.
IF lv_item_count = 0.
  RETURN.
ENDIF.
```

### Compliant

```abap
IF lines( lt_order_items ) = 0.
  RETURN.
ENDIF.
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
... "#EC PREF_LINES

" SAP CI_ prefix format:
... "#EC CI_PREF_LINES
```

## Scope

`DESCRIBE TABLE ... KIND` and `... OCCURS` are not reported, because `lines( )` only replaces the row count. The `TOLINES` quickfix always produces the assignment form `target = lines( itab ).`; inline it manually when the count is used only once, as in the good example.


## Related Rules

* [Replace READ TABLE with Table Expressions and line_exists](/rules/pref-read-table) — <code>#EC PREF_TAB_EXPR</code>
* [Replace Single-Statement Aggregation LOOP with REDUCE](/rules/pref-reduce) — <code>#EC PREF_REDUCE</code>
* [Declare Standard Internal Tables Explicitly with TYPE STANDARD TABLE OF](/rules/pref-std-table) — <code>#EC PREF_STD_TABLE</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_PREF_LINES`
* **ABAP Implementation:** [/skyl/cl_pref_lines.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_pref_lines.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 360)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L360)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_PREF_LINES&title=%5BBug%5D%3A%20Issue%20in%20pref-lines)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20pref-lines)**
