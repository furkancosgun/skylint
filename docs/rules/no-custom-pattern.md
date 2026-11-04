---
title: "Disallow Prohibited Naming Patterns and Terminology via Regular Expressions"
description: "Detect and restrict forbidden custom naming patterns, temporary variables, and banned terminology using regex in SAP ATC for ABAP Cloud."
keywords: "no-custom-pattern, regex pattern, Clean ABAP, naming conventions, SAP ATC, ABAP Cloud"
category: "anti-patterns"
ruleId: "no-custom-pattern"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L54"
---

# Disallow Prohibited Naming Patterns and Terminology via Regular Expressions

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Anti-Patterns & Bad Practices" />
  <Badge type="danger" text="#EC NO_CUSTOM_PATTERN" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L54" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Disallow configured custom regex patterns.

> **ATC Finding Message:** `Source code matches forbidden custom regex pattern`

## Rationale

Enterprise governance standards and Clean ABAP guidelines often forbid temporary naming prefixes (such as TMP_* or DEBUG_*), placeholder terms, obsolete package references, or sensitive terminology. The check evaluates every statement token against a configurable regular expression pattern and reports NO_CUSTOM for any match. Enforcing consistent vocabulary across teams prevents incomplete prototypes from entering production releases and maintains clean compliance across ABAP Cloud and SAP S/4HANA solutions.

### Non-Compliant

```abap
DATA lv_todo_customer_id TYPE c LENGTH 10.
```

### Compliant

```abap
DATA lv_verified_customer_id TYPE c LENGTH 10.
```

## Configuration & Thresholds

This check can be fine-tuned directly in the ATC Check Variant Editor (`CHKV`) in Eclipse ADT:

| Parameter Name | Data Type | Default Value | Description & Guidance |
|---|---|:---:|---|
| `PATTERN` | `String` | <code>TODO&#124;FIXME&#124;XXX</code> | Regular expression pattern of forbidden lexemes or identifiers to disallow (defaults to TODO&#124;FIXME&#124;XXX). |

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC NO_CUSTOM_PATTERN

" SAP CI_ prefix format:
... "#EC CI_NO_CUSTOM_PATTERN
```

### Configuration and Pattern Matching

The check scans every token within procedure statements and applies case-insensitive regular expression matching against the configured `PATTERN` attribute.

| Default Pattern | Purpose |
|---|---|
| `TODO|FIXME|XXX` | Prevents technical debt markers and temporary prototype identifiers from reaching production code. |

A finding can be suppressed on an individual statement using the pseudo-comment `"#EC NO_CUSTOM_PATTERN`. Set `PATTERN` to an empty string in ATC variant configuration to disable scanning.


## Related Rules

* [Avoid Using ABAP Keywords as Identifier Names](/rules/no-keyword-name) — <code>#EC NO_KEYWORD_NAME</code>
* [Avoid Reading Environment and Landscape System Fields](/rules/no-hardcoded-env) — <code>#EC NO_HARDCODED_ENV</code>
* [Eliminate Unreachable Dead Code Caused by Constant False Conditions](/rules/no-dead-code) — <code>#EC NO_DEAD_CODE</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_NO_CUSTOM_PATTERN`
* **ABAP Implementation:** [/skyl/cl_no_custom_pattern.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_no_custom_pattern.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 54)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L54)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_NO_CUSTOM_PATTERN&title=%5BBug%5D%3A%20Issue%20in%20no-custom-pattern)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20no-custom-pattern)**
