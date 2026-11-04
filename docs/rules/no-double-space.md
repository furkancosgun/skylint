---
title: "Avoid Consecutive Whitespace Between Tokens"
description: "Flag redundant double spaces between statement tokens on the same line."
keywords: "Clean ABAP, double space, no-double-space"
category: "clean-abap"
ruleId: "no-double-space"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L4727"
---

# Avoid Consecutive Whitespace Between Tokens

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="danger" text="#EC NO_DOUBLE_SPACE" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L4727" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Avoid consecutive whitespace between tokens on the same line.

> **ATC Finding Message:** `Use exactly one space between tokens on the same line`

## Rationale

Tokens on the same line should be separated by exactly one space to maintain uniform formatting and readability.

### Non-Compliant

```abap
DATA  lv_a TYPE i.
```

### Compliant

```abap
DATA lv_a TYPE i.
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC NO_DOUBLE_SPACE

" SAP CI_ prefix format:
... "#EC CI_NO_DOUBLE_SPACE
```


## Related Rules

* [Single Parameter or Field Per Line](/rules/pref-param-1line) — <code>#EC PREF_PARAM_1LINE</code>
* [Avoid Chained Declarations (DATA:, CONSTANTS:, TYPES:)](/rules/no-chained-decl) — <code>#EC NO_CHAINED_DECL</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_NO_DOUBLE_SPACE`
* **ABAP Implementation:** [/skyl/cl_no_double_space.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_no_double_space.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 4727)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L4727)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_NO_DOUBLE_SPACE&title=%5BBug%5D%3A%20Issue%20in%20no-double-space)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20no-double-space)**
