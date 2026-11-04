---
title: "Limit Consecutive Blank Lines Between Statements"
description: "Report excessive consecutive blank lines between ABAP statements with a configurable MAX_BLANKS threshold - compact, reviewable method bodies."
keywords: "ABAP blank lines, max-blank-lines, source formatting, code readability, Clean ABAP"
category: "clean-abap"
ruleId: "max-blank-lines"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L5379"
---

# Limit Consecutive Blank Lines Between Statements

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="danger" text="#EC MAX_BLANK_LINES" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L5379" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

No Excessive Consecutive Empty Lines.

> **ATC Finding Message:** `Too many consecutive empty lines - collapse them`

## Rationale

Long runs of empty lines break the visual grouping of a method: readers cannot tell whether a block was deleted, a merge conflict happened or the author simply pressed Enter twice, and the code appears to have gaps where logic is missing. Oversized gaps also push related statements apart on screen, so reviews and diffs become harder to follow, especially when comments are separated from the code they describe. The check measures the distance between the end line of the previous statement (including continuation lines) and the start line of the next statement inside a procedure and reports MAX_BLANKL when more than MAX_BLANKS lines are empty. Comment-only lines are invisible to the parser and therefore count as empty space, which keeps the measurement deterministic.

### Non-Compliant

```abap
DATA(lv_total) = 0.


lv_total = lv_total + 10.
```

### Compliant

```abap
DATA(lv_total) = 0.

lv_total = lv_total + 10.
```

## Configuration & Thresholds

This check can be fine-tuned directly in the ATC Check Variant Editor (`CHKV`) in Eclipse ADT:

| Parameter Name | Data Type | Default Value | Description & Guidance |
|---|---|:---:|---|
| `MAX_BLANKS` | `Integer` | <code>1</code> | Maximum number of consecutive empty lines allowed between two statements. Default 1 keeps logical groups separated; 0 enforces compact code, 2 tolerates wider visual separation. |

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC MAX_BLANK_LINES

" SAP CI_ prefix format:
... "#EC CI_MAX_BLANK_LINES
```

## How the distance is measured

The check compares the first line of the current statement with the last line occupied by the previous statement, including continuation lines and a trailing comment on the same line:

```text
distance = current_start_line - previous_end_line - 1
```

A finding is raised when `distance > MAX_BLANKS`.

| `MAX_BLANKS` | Effect |
| --- | --- |
| `0` | no empty line allowed between two statements |
| `1` (default) | one empty line may separate logical groups |
| `2` | two empty lines are tolerated |

## Notes

- Comment-only lines are not statements and count as empty space, so a comment block surrounded by blank lines can trigger the finding.
- Multi-line statements are measured with their last token, so a long `SELECT` or constructor expression is never mistaken for a gap.
- Only procedures are inspected; blank lines in the class definition part are ignored.
- Suppress the position with `"#EC MAX_BLANK_LINES` on the statement that follows the gap.


## Related Rules

* [Limit Source Code Line Length to Avoid Horizontal Scrolling](/rules/max-line-len) — <code>#EC MAX_LINE_LEN</code>
* [Limit Method and Constructor Statement Length](/rules/max-method-len) — <code>#EC MAX_METHOD_LEN</code>
* [Limit One Statement per Source Code Line](/rules/max-one-stmt) — <code>#EC MAX_ONE_STMT</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_MAX_BLANK_LINES`
* **ABAP Implementation:** [/skyl/cl_max_blank_lines.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_max_blank_lines.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 5379)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L5379)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_MAX_BLANK_LINES&title=%5BBug%5D%3A%20Issue%20in%20max-blank-lines)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20max-blank-lines)**
