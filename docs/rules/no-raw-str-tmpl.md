---
title: "Avoid String Templates Without Embedded Expressions"
description: "Detect ABAP string templates such as |Fixed text| and || that contain no embedded expression and should be plain literals instead."
keywords: "ABAP string template, empty template, no-raw-str-tmpl, string literal, Clean ABAP"
category: "clean-abap"
ruleId: "no-raw-str-tmpl"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L5235"
---

# Avoid String Templates Without Embedded Expressions

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="danger" text="#EC NO_RAW_STR_TMPL" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L5235" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Avoid string templates without embedded expressions.

> **ATC Finding Message:** `String template has no embedded expressions { }; use string literal or backticks`

## Rationale

A string template such as |Hello World| is compiled as a string template with a format-driven evaluation path, yet it contains no embedded expression, so the runtime pays for template handling that a plain character or string literal does not need. It also misleads readers, who expect { ... } placeholders and start looking for dynamic content that does not exist. The check scans the token stream of every statement for a | token and reports NO_RAWTMPL when the closing | is reached without a { expression, so empty templates || and static templates |text| are detected with one finding code but controlled by two independent switches. Only templates that really interpolate or format an expression should use the string template syntax.

### Non-Compliant

```abap
DATA(lv_greeting) = |Hello World|.
DATA(lv_blank) = ||.
```

### Compliant

```abap
DATA(lv_greeting) = 'Hello World'.
DATA(lv_message) = |Order { lv_order_id } created|.
```

## Configuration & Thresholds

This check can be fine-tuned directly in the ATC Check Variant Editor (`CHKV`) in Eclipse ADT:

| Parameter Name | Data Type | Default Value | Description & Guidance |
|---|---|:---:|---|
| `CHECK_EMPTY_TEMPLATE` | `Boolean` | <code>true</code> | Report empty string templates written as &#124;&#124; - replace them with an empty character literal or an empty string. Default true. |
| `CHECK_STATIC_TEMPLATE` | `Boolean` | <code>true</code> | Report string templates without any { } expression, e.g. &#124;Fixed text&#124;. Default true; set false if your team uses templates purely as a visual marker. |

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC NO_RAW_STR_TMPL

" SAP CI_ prefix format:
... "#EC CI_NO_RAW_STR_TMPL
```

## Parameters

| Parameter | Default | Effect |
| --- | --- | --- |
| `CHECK_EMPTY_TEMPLATE` | `true` | report an empty template `||` |
| `CHECK_STATIC_TEMPLATE` | `true` | report `|text|` without `{ }` |

## Notes

- The criterion is the presence of a `{` token between the opening and the closing `|`; a template that only contains escaped braces but no expression is still reported.
- Templates with formatting options (`|{ lv_amount NUMBER = USER }|`) are not reported.
- A backtick literal (`` `text` ``) is a string literal and is never reported, even when it contains a `{`.
- The finding is reported on the opening `|` token, so the marker points exactly at the template that must change.

## Replacement table

| Reported | Replacement |
| --- | --- |
| `||` | `''` (empty character literal) or `` `` `` (empty string) |
| `|Fixed text|` | `'Fixed text'` for a text literal, `` `Fixed text` `` when trailing blanks matter |
| `|Status: OK|` | `'Status: OK'` |
| `|Total: { lv_total }|` | keep it - it embeds an expression |


## Related Rules

* [Compose Messages with String Templates Instead of CONCATENATE](/rules/pref-str-tmpl) — <code>#EC PREF_STR_TMPL</code>
* [Fold Adjacent Static String Literals Concatenated with &&](/rules/no-useless-concat) — <code>#EC NO_USELESS_CONCAT</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_NO_RAW_STR_TMPL`
* **ABAP Implementation:** [/skyl/cl_no_raw_str_tmpl.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_no_raw_str_tmpl.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 5235)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L5235)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_NO_RAW_STR_TMPL&title=%5BBug%5D%3A%20Issue%20in%20no-raw-str-tmpl)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20no-raw-str-tmpl)**
