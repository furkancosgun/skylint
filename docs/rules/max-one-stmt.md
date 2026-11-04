---
title: "Limit One Statement per Source Code Line"
description: "Enforce one ABAP statement per line to ensure clear Git diffs, accurate debugger stepping, and clean code formatting."
keywords: "max-one-stmt, one statement per line, Clean ABAP, SAP ATC, code formatting"
category: "metrics"
ruleId: "max-one-stmt"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L2757"
---

# Limit One Statement per Source Code Line

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Metrics & Complexity Limits" />
  <Badge type="danger" text="#EC MAX_ONE_STMT" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L2757" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Max One Statement Per Line.

> **ATC Finding Message:** `Only one statement is allowed per line`

## Rationale

Writing multiple statements on a single source line severely compromises code readability, debugger operation, and Git history tracking. In modern development with Eclipse ADT, breakpoints and single-step debugging operate at the line level: when multiple statements share one line, stepping into individual operations becomes impossible or misleading. Furthermore, line-level diffs in version control cannot isolate which statement was altered, obscuring change intent during peer code reviews. Clean ABAP mandates exactly one statement per source line.

### Non-Compliant

```abap
lv_order_status = 'OPEN'. lv_item_count = 0. CLEAR ls_billing_header.
```

### Compliant

```abap
lv_order_status = 'OPEN'.
lv_item_count = 0.
CLEAR ls_billing_header.
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC MAX_ONE_STMT

" SAP CI_ prefix format:
... "#EC CI_MAX_ONE_STMT
```

## Evaluation Details

The check iterates through all procedure statements and compares the start line of the current statement with the end line of the preceding statement. If `lv_stmt_start = lv_prev_end_line`, the subsequent statement is reported.

| Finding Code | Severity | Trigger | Suppression |
|---|---|---|---|
| `MAX_1STMT` | Warning | Statement begins on the same line where the previous statement ended | `##MAX_ONE_STMT` or `"#EC MAX_ONE_STMT` |

### Formatting Impact
Never use colon-chains or sequential statements on the same line (`a = 1. b = 2.`). Always format each statement onto a distinct source line with appropriate indentation.


## Related Rules

* [Limit Source Code Line Length to Avoid Horizontal Scrolling](/rules/max-line-len) — <code>#EC MAX_LINE_LEN</code>
* [Limit Method Parameter Count and Keep One Parameter per Line](/rules/max-params) — <code>#EC MAX_PARAMS_COUNT</code>
* [Limit Number of Return Statements per Procedure](/rules/max-returns) — <code>#EC MAX_RETURNS</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_MAX_ONE_STMT`
* **ABAP Implementation:** [/skyl/cl_max_one_stmt.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_max_one_stmt.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 2757)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L2757)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_MAX_ONE_STMT&title=%5BBug%5D%3A%20Issue%20in%20max-one-stmt)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20max-one-stmt)**
