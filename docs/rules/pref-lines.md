---
title: "Prefer lines( ) over DESCRIBE TABLE"
description: "Prefer lines( ) over DESCRIBE TABLE - Clean ABAP guidelines, modern SAP syntax rules, and automated ATC code inspection for SAP S/4HANA and ABAP Cloud."
keywords: "Clean ABAP, SAP ATC Check, ABAP Cloud, S/4HANA Readiness, pref-lines, clean-abap"
category: "clean-abap"
ruleId: "pref-lines"
---

# Prefer lines( ) over DESCRIBE TABLE

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="warning" text="QuickFix Ready" />
  <Badge type="danger" text="#EC PREF_LINES" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Prefer lines( ) over DESCRIBE TABLE ... LINES.

> **ATC Finding Message:** `Use lines( ) function instead of DESCRIBE TABLE ... LINES`

## Rationale

DESCRIBE TABLE LINES requires an extra variable and separates the question about table size from the code that uses the answer. The lines( ) built-in returns the row count as a value and can be embedded directly in conditions and expressions. This reduces temporary variables and makes the intent obvious at the call site.

### Non-Compliant

```abap
DESCRIBE TABLE lt_items LINES lv_count.
IF lv_count = 0.
  RETURN.
ENDIF.
```

### Compliant

```abap
IF lines( lt_items ) = 0.
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


## Related Rules

* [Modernize READ TABLE (Table Expressions & line_exists)](/rules/pref-read-table) — <code>#EC PREF_TAB_EXPR</code>
* [Prefer FILTER for a Simple LOOP with IF and APPEND](/rules/pref-filter) — <code>#EC PREF_FILTER</code>
* [Prefer REDUCE #( ) Expression over Simple Aggregation LOOP](/rules/pref-reduce) — <code>#EC PREF_REDUCE</code>

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_PREF_LINES`
* **Implementation File:** [zcl_skylint_pref_lines.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_pref_lines.clas.abap)
