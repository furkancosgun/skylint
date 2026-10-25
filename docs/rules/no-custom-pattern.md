---
title: "Disallow Configured Custom Regex Patterns"
description: "Disallow Configured Custom Regex Patterns - Clean ABAP guidelines, modern SAP syntax rules, and automated ATC code inspection for SAP S/4HANA and ABAP Cloud."
keywords: "Clean ABAP, SAP ATC Check, ABAP Cloud, S/4HANA Readiness, no-custom-pattern, anti-patterns"
category: "anti-patterns"
ruleId: "no-custom-pattern"
---

# Disallow Configured Custom Regex Patterns

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Anti-Patterns & Bad Practices" />
  <Badge type="danger" text="#EC NO_CUSTOM_PATTERN" />
  <Badge type="info" text="Remote Enabled" />
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

* **Native ATC Class:** `ZCL_SKYLINT_NO_CUSTOM_PATTERN`
* **Implementation File:** [zcl_skylint_no_custom_pattern.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_no_custom_pattern.clas.abap)
