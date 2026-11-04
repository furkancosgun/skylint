---
title: "Disallow Configured Custom Regex Patterns"
description: "Disallow Configured Custom Regex Patterns - Clean ABAP guidelines, modern SAP syntax rules, and automated ATC code inspection for SAP S/4HANA and ABAP Cloud."
keywords: "Clean ABAP, SAP ATC Check, ABAP Cloud, S/4HANA Readiness, no-custom-pattern, anti-patterns"
category: "anti-patterns"
ruleId: "no-custom-pattern"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L55"
---

# Disallow Configured Custom Regex Patterns

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Anti-Patterns & Bad Practices" />
  <Badge type="danger" text="#EC NO_CUSTOM_PATTERN" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L55" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Disallow configured custom regex patterns.

> **ATC Finding Message:** `Source code matches forbidden custom regex pattern`

## Rationale

Enterprise coding standards often require banning specific placeholder comments (such as TODO, FIXME, XXX), temporary variable patterns (such as TMP_* or DEBUG_*), sensitive keywords, or prohibited terminology. This check inspects all tokens against a configurable table of regular expressions, reporting any prohibited matches.

### Non-Compliant

```abap
" Flagged when 'TODO' is configured in PATTERNS
DATA lv_todo_item TYPE i.
```

### Compliant

```abap
DATA lv_clean_item TYPE i.
```

## Configuration & Thresholds

This check can be fine-tuned directly in the ATC Check Variant Editor (`CHKV`) in Eclipse ADT:

| Parameter Name | Data Type | Default Value | Description & Guidance |
|---|---|:---:|---|
| `PATTERN` | `String` | <code>TODO&#124;FIXME&#124;XXX</code> | Regular expression pattern to disallow (defaults to TODO&#124;FIXME&#124;XXX) |

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC NO_CUSTOM_PATTERN

" SAP CI_ prefix format:
... "#EC CI_NO_CUSTOM_PATTERN
```


## Related Rules

* [Avoid Using ABAP Keywords as Identifier Names](/rules/no-keyword-name) — <code>#EC NO_KEYWORD_NAME</code>
* [Avoid Hardcoding System & Tenant Environment Checks (sy-sysid, sy-mandt)](/rules/no-hardcoded-env) — <code>#EC NO_HARDCODED_ENV</code>
* [Avoid Dead Code with Constant Conditions](/rules/no-dead-code) — <code>#EC NO_DEAD_CODE</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_NO_CUSTOM_PATTERN`
* **ABAP Implementation:** [/skyl/cl_no_custom_pattern.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_no_custom_pattern.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 55)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L55)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_NO_CUSTOM_PATTERN&title=%5BBug%5D%3A%20Issue%20in%20no-custom-pattern)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20no-custom-pattern)**
