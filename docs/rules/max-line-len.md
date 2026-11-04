---
title: "Limit Source Code Line Length to Avoid Horizontal Scrolling"
description: "Enforce a 120-character line length limit in ABAP code to prevent horizontal scrolling and keep side-by-side Git diffs readable."
keywords: "max-line-len, line length limit, Clean ABAP, SAP ATC, Eclipse ADT formatting"
category: "metrics"
ruleId: "max-line-len"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L3424"
---

# Limit Source Code Line Length to Avoid Horizontal Scrolling

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Metrics & Complexity Limits" />
  <Badge type="danger" text="#EC MAX_LINE_LEN" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L3424" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Maximum Line Length.

> **ATC Finding Message:** `Line length exceeds configured maximum limit`

## Rationale

Source lines that exceed standard display widths (typically 120 characters) force developers to scroll horizontally during code reviews and side-by-side Git diff inspections in Eclipse ADT and web repositories. Long horizontal lines obscure trailing boolean operators, closing parentheses, and inline expressions, creating blind spots where logic defects and syntax errors frequently hide. Clean ABAP formatting standards recommend wrapping statements intelligently before reaching 120 characters, aligning continuations under the parent keyword or expression for optimal scanning.

### Non-Compliant

```abap
DATA(lo_order_service) = zcl_order_service_factory=>get_instance( )->create_order_processor( is_sales_header = ls_sales_header iv_simulate = abap_true iv_auto_commit = abap_false ).
```

### Compliant

```abap
DATA(lo_order_service) = zcl_order_service_factory=>get_instance( )->create_order_processor(
  is_sales_header = ls_sales_header
  iv_simulate     = abap_true
  iv_auto_commit  = abap_false ).
```

## Configuration & Thresholds

This check can be fine-tuned directly in the ATC Check Variant Editor (`CHKV`) in Eclipse ADT:

| Parameter Name | Data Type | Default Value | Description & Guidance |
|---|---|:---:|---|
| `MAX_LENGTH` | `Integer` | <code>120</code> | Maximum allowable character length per source code line before reporting (default: 120). |

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC MAX_LINE_LEN

" SAP CI_ prefix format:
... "#EC CI_MAX_LINE_LEN
```

## Column Calculation

The check iterates over tokens in each statement and computes the ending column position (`column + strlen( lexeme ) - 1`), with an extra column offset for statement-terminating periods. If any token's end column exceeds `MAX_LENGTH`, a finding is generated for the statement.

| Finding Code | Severity | Default Limit | Suppression |
|---|---|---|---|
| `MAX_LINLEN` | Warning | `MAX_LENGTH` (120 columns) | `##MAX_LINE_LEN` or `"#EC MAX_LINE_LEN` |

### Formatting Guideline
Configure Eclipse ADT print margins to 120 characters and break long expressions across multiple lines, aligning arguments or conditions vertically.


## Related Rules

* [Limit Method and Constructor Statement Length](/rules/max-method-len) — <code>#EC MAX_METHOD_LEN</code>
* [Limit One Statement per Source Code Line](/rules/max-one-stmt) — <code>#EC MAX_ONE_STMT</code>
* [Limit Method Parameter Count and Keep One Parameter per Line](/rules/max-params) — <code>#EC MAX_PARAMS_COUNT</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_MAX_LINE_LEN`
* **ABAP Implementation:** [/skyl/cl_max_line_len.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_max_line_len.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 3424)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L3424)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_MAX_LINE_LEN&title=%5BBug%5D%3A%20Issue%20in%20max-line-len)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20max-line-len)**
