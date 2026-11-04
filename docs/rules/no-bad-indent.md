---
title: "Statement Indentation Must Match Block Nesting"
description: "Statement Indentation Must Match Block Nesting - Clean ABAP guidelines, modern SAP syntax rules, and automated ATC code inspection for SAP S/4HANA and ABAP Cloud."
keywords: "Clean ABAP, SAP ATC Check, ABAP Cloud, S/4HANA Readiness, no-bad-indent, clean-abap"
category: "clean-abap"
ruleId: "no-bad-indent"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L3493"
---

# Statement Indentation Must Match Block Nesting

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="warning" text="QuickFix Ready" />
  <Badge type="danger" text="#EC NO_BAD_INDENT" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L3493" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Bad Statement Indentation.

> **ATC Finding Message:** `Statement indentation does not match block nesting`

## Rationale

Indentation is the fastest visual cue for block nesting, so inconsistent indentation misleads readers about which statements belong together. It also creates noisy diffs when a formatter runs. Indent each block level consistently.

### Non-Compliant

```abap
METHOD calculate.
DATA lv_total TYPE i.
  LOOP AT lt_items INTO ls_item.
lv_total = lv_total + ls_item-amount.
  ENDLOOP.
ENDMETHOD.
```

### Compliant

```abap
METHOD calculate.
  DATA lv_total TYPE i.
  LOOP AT lt_items INTO ls_item.
    lv_total = lv_total + ls_item-amount.
  ENDLOOP.
ENDMETHOD.
```

## Automated QuickFix

This rule provides an **automated QuickFix** directly in Eclipse ABAP Development Tools (ADT):
1. Position the cursor on the flagged statement.
2. Press <kbd>Ctrl</kbd> + <kbd>1</kbd> (Quick Assist).
3. Select the automated refactoring to apply the clean syntax immediately.

## Configuration & Thresholds

This check can be fine-tuned directly in the ATC Check Variant Editor (`CHKV`) in Eclipse ADT:

| Parameter Name | Data Type | Default Value | Description & Guidance |
|---|---|:---:|---|
| `INDENT_STEP` | `Integer` | <code>2</code> | Standard indentation step per nested block level (default: 2 spaces) |

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC NO_BAD_INDENT

" SAP CI_ prefix format:
... "#EC CI_NO_BAD_INDENT
```


## Related Rules

* [Limit Control Flow Nesting Depth (Guard Clause Enforcement)](/rules/max-nesting) — <code>#EC MAX_NESTING</code>
* [Limit Method and Constructor Statement Length](/rules/max-method-len) — <code>#EC MAX_METHOD_LEN</code>
* [Limit Source Code Line Length (Avoid Horizontal Scrolling)](/rules/max-line-len) — <code>#EC MAX_LINE_LEN</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_NO_BAD_INDENT`
* **ABAP Implementation:** [/skyl/cl_no_bad_indent.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_no_bad_indent.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 3493)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L3493)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_NO_BAD_INDENT&title=%5BBug%5D%3A%20Issue%20in%20no-bad-indent)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20no-bad-indent)**
