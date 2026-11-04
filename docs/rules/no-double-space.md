---
title: "Use Exactly One Space Between Tokens on the Same Line"
description: "Flag redundant double spaces and column alignment padding between ABAP tokens so diffs stay minimal and formatting matches any code formatter."
keywords: "ABAP double space, code formatting ABAP, alignment whitespace, SAP ATC, no-double-space"
category: "clean-abap"
ruleId: "no-double-space"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L4861"
---

# Use Exactly One Space Between Tokens on the Same Line

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="danger" text="#EC NO_DOUBLE_SPACE" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L4861" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Avoid consecutive whitespace between tokens on the same line.

> **ATC Finding Message:** `Use exactly one space between tokens on the same line`

## Rationale

Column-aligned declarations and stray double spaces make diffs noisy: renaming one identifier forces realignment of a whole block, and reviewers cannot separate the semantic change from the whitespace noise. A single space between tokens keeps lines stable under renames, keeps the 120-character limit usable and works with any formatter or editor setting. The check compares each token's column with the end of the previous token and reports the first padded gap per statement.

### Non-Compliant

```abap
DATA lv_order_count      TYPE i.
DATA lv_customer_name    TYPE string.
```

### Compliant

```abap
DATA lv_order_count TYPE i.
DATA lv_customer_name TYPE string.
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC NO_DOUBLE_SPACE

" SAP CI_ prefix format:
... "#EC CI_NO_DOUBLE_SPACE
```

### What is reported

`NO_DBL_SPC` is raised on the token whose column is greater than `previous token column + previous token length + 1` on the same source line, that is whenever more than one space separates two tokens. Only the first padded gap per statement is reported.

| Snippet | Result |
| --- | --- |
| `DATA  lv_order_count TYPE i.` | reported - two spaces after `DATA` |
| `DATA lv_order_count      TYPE i.` | reported - declaration alignment padding |
| `DATA lv_order_count TYPE i.` | ok |
| `account = VALUE #( street = 'Main Street' city = 'Walldorf' ).` | reported - padding between the parameter assignments |

### Alignment across lines

Alignment is only a problem **within** one line. A declaration that continues on the next line (the usual `TYPES ... BEGIN OF ... END OF` layout) and a parameter that is wrapped onto its own line are both fine, because no two tokens share a padded line. Splitting a long statement over several lines is therefore the recommended fix for both this rule and `pref-param-1line`.

An intentionally aligned one-liner can be suppressed with `"#EC NO_DOUBLE_SPACE` on the statement.


## Related Rules

* [One Parameter or Structure Component per Line](/rules/pref-param-1line) — <code>#EC PREF_PARAM_1LINE</code>
* [Avoid Chained Declarations for Variables, Types, and Constants](/rules/no-chained-decl) — <code>#EC NO_CHAINED_DECL</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_NO_DOUBLE_SPACE`
* **ABAP Implementation:** [/skyl/cl_no_double_space.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_no_double_space.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 4861)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L4861)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_NO_DOUBLE_SPACE&title=%5BBug%5D%3A%20Issue%20in%20no-double-space)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20no-double-space)**
