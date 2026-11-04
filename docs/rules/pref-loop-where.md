---
title: "Prefer LOOP AT WHERE over IF CONTINUE Guards"
description: "Prefer LOOP AT WHERE over initial IF CONTINUE guards in ABAP internal table processing. Clean ABAP table handling, readable loop filters, and automated ATC inspection for SAP S/4HANA and ABAP Cloud."
keywords: "LOOP AT WHERE ABAP, Clean ABAP Tables, Internal Table Filter, AbapLint LOOP WHERE, ATC Code Review"
category: "clean-abap"
ruleId: "pref-loop-where"
---

# Prefer LOOP AT WHERE over IF CONTINUE Guards

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="danger" text="#EC PREF_LOOP_WHERE" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Filter LOOP AT With a WHERE Clause.

> **ATC Finding Message:** `Loop starts with an IF CONTINUE guard - filter rows with WHERE instead`

## Rationale

Filtering internal table rows with the WHERE clause of LOOP AT is more efficient and more readable than starting the loop with an initial IF ... CONTINUE guard. The ABAP runtime evaluates the WHERE condition directly during row traversal, skipping non-matching rows before the loop body executes. Clean ABAP (Tables section) recommends LOOP AT ... WHERE over nested filtering inside the loop body.

### Non-Compliant

```abap
LOOP AT lt_rows INTO ls_row.
  IF ls_row-status <> 'X'.
    CONTINUE.
  ENDIF.
  " loop body
ENDLOOP.
```

### Compliant

```abap
LOOP AT lt_rows INTO ls_row WHERE status = 'X'.
  " loop body
ENDLOOP.
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC PREF_LOOP_WHERE

" SAP CI_ prefix format:
... "#EC CI_PREF_LOOP_WHERE
```


## Related Rules

* [Merge Nested IF Statements](/rules/pref-merge-ifs) — <code>#EC PREF_MERGE_IFS</code>
* [Avoid Redundant CONTINUE at End of Loop](/rules/no-useless-cont) — <code>#EC NO_USELESS_CONT</code>
* [Modernize READ TABLE (Table Expressions & line_exists)](/rules/pref-read-table) — <code>#EC PREF_TAB_EXPR</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_PREF_LOOP_WHERE`
* **Implementation File:** [#skyl#cl_pref_loop_where.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_pref_loop_where.clas.abap)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_PREF_LOOP_WHERE&title=%5BBug%5D%3A%20Issue%20in%20pref-loop-where)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20pref-loop-where)**
