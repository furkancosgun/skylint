---
title: "Extract Repeated String Literals into Named Constants"
description: "Identify repeated string literals in ABAP procedures and replace magic strings with typed constants for Clean ABAP maintainability."
keywords: "ABAP magic strings, constants refactoring, Clean ABAP, SAP ATC check, no-dup-literals"
category: "anti-patterns"
ruleId: "no-dup-literals"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L3834"
---

# Extract Repeated String Literals into Named Constants

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Anti-Patterns & Bad Practices" />
  <Badge type="danger" text="#EC NO_DUP_LITERALS" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L3834" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Avoid repeating the same string literal.

> **ATC Finding Message:** `Replace repeated literals with a constant`

## Rationale

Repeating identical string literals across a procedure couples disparate code paths to magic values, increasing the risk of typographic errors and making requirement updates error-prone. Defining a central typed constant clarifies business semantics, enables compile-time safety, and simplifies maintenance across ABAP Cloud and SAP S/4HANA solutions.

### Non-Compliant

```abap
IF lv_order_status = 'CANCELLED'.
  log_status( 'CANCELLED' ).
ELSEIF lv_previous_status = 'CANCELLED'.
  clear_status( ).
ENDIF.
```

### Compliant

```abap
CONSTANTS c_status_cancelled TYPE string VALUE 'CANCELLED'.

IF lv_order_status = c_status_cancelled.
  log_status( c_status_cancelled ).
ELSEIF lv_previous_status = c_status_cancelled.
  clear_status( ).
ENDIF.
```

## Configuration & Thresholds

This check can be fine-tuned directly in the ATC Check Variant Editor (`CHKV`) in Eclipse ADT:

| Parameter Name | Data Type | Default Value | Description & Guidance |
|---|---|:---:|---|
| `MIN_OCCURRENCES` | `Integer` | <code>3</code> | Minimum number of identical string literal occurrences in a procedure required to trigger a finding (default 3). |
| `MIN_LENGTH` | `Integer` | <code>3</code> | Minimum character length of string literals to inspect, filtering out short delimiters and trivial tokens (default 3). |

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC NO_DUP_LITERALS

" SAP CI_ prefix format:
... "#EC CI_NO_DUP_LITERALS
```

### How repeated literals are evaluated

The check scans all executable statements within a procedure (excluding `CLASS ... DEFINITION` sections) and counts occurrences of fixed string literals. When an identical string appears at least `MIN_OCCURRENCES` times and meets the `MIN_LENGTH` requirement, finding `NO_DUP_LIT` is reported for each instance.

| Attribute | Default | Description |
| --- | --- | --- |
| `MIN_OCCURRENCES` | 3 | Frequency threshold before a literal is flagged |
| `MIN_LENGTH` | 3 | Length threshold to ignore single characters like `','` or `'/'` |

### Suppression

If a repeated literal is intentionally inline (for example in unit test fixture data), suppress the finding using pseudo-comment `"#EC NO_DUP_LITERALS` on the offending statement.


## Related Rules

* [Fold Adjacent Static String Literals Concatenated with &&](/rules/no-useless-concat) — <code>#EC NO_USELESS_CONCAT</code>
* [Replace Obsolete String Statements and POSIX Regular Expressions](/rules/no-obs-strings) — <code>#EC NO_OBS_STRINGS</code>
* [Compose Messages with String Templates Instead of CONCATENATE](/rules/pref-str-tmpl) — <code>#EC PREF_STR_TMPL</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_NO_DUP_LITERALS`
* **ABAP Implementation:** [/skyl/cl_no_dup_literals.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_no_dup_literals.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 3834)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L3834)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_NO_DUP_LITERALS&title=%5BBug%5D%3A%20Issue%20in%20no-dup-literals)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20no-dup-literals)**
