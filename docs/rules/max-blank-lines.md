---
title: "Limit Consecutive Blank Lines"
description: "Limit consecutive blank lines in ABAP source code for compact, readable formatting. Clean ABAP style rules, automatic empty line detection, and ATC code inspection for SAP S/4HANA and ABAP Cloud."
keywords: "Blank Lines ABAP, Source Code Formatting, Clean ABAP Style, Code Readability, ATC Code Review"
category: "clean-abap"
ruleId: "max-blank-lines"
---

# Limit Consecutive Blank Lines

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="danger" text="#EC MAX_BLANK_LINES" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

No Excessive Consecutive Empty Lines.

> **ATC Finding Message:** `Too many consecutive empty lines - collapse them`

## Rationale

Multiple consecutive empty lines scatter related code and suggest removed or unfinished logic. Keep source files compact with a single blank line to separate logical sections. The check measures the empty lines between consecutive statements in a procedure. Note: comment-only lines are not visible to the parser and are counted as empty space; configure MAX_BLANKS to your team standard.

### Non-Compliant

```abap
lv_total = 1.


lv_total = lv_total + 2.
```

### Compliant

```abap
lv_total = 1.

lv_total = lv_total + 2.
```

## Configuration & Thresholds

This check can be fine-tuned directly in the ATC Check Variant Editor (`CHKV`) in Eclipse ADT:

| Parameter Name | Data Type | Default Value | Description & Guidance |
|---|---|:---:|---|
| `MAX_BLANKS` | `Integer` | <code>1</code> | Maximum number of consecutive blank lines allowed between statements (default: 1) |

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC MAX_BLANK_LINES

" SAP CI_ prefix format:
... "#EC CI_MAX_BLANK_LINES
```


## Related Rules

* [Limit Source Code Line Length (Avoid Horizontal Scrolling)](/rules/max-line-len) — <code>#EC MAX_LINE_LEN</code>
* [Limit Method and Constructor Statement Length](/rules/max-method-len) — <code>#EC MAX_METHOD_LEN</code>
* [Limit One Statement per Source Code Line (No Inline Colon Chains)](/rules/max-one-stmt) — <code>#EC MAX_ONE_STMT</code>

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_MAX_BLANK_LINES`
* **Implementation File:** [zcl_skylint_max_blank_lines.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_max_blank_lines.clas.abap)
