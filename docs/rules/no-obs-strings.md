---
title: "Replace Obsolete String Statements and POSIX Regular Expressions"
description: "Detect obsolete string statements like PACK, UNPACK, and POSIX regex in ABAP Cloud."
keywords: "no-obs-strings, POSIX regex, PCRE, PACK UNPACK, Clean ABAP"
category: "anti-patterns"
ruleId: "no-obs-strings"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L1337"
---

# Replace Obsolete String Statements and POSIX Regular Expressions

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Anti-Patterns & Bad Practices" />
  <Badge type="danger" text="#EC NO_OBS_STRINGS" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L1337" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Obsolete String and Regex Statements.

> **ATC Finding Message:** `Avoid obsolete string statements (PACK, UNPACK, POSIX REGEX, etc.)`

## Rationale

Legacy string manipulation statements such as PACK, UNPACK, REPLACE ... INTO, and POSIX regular expressions (FIND/REPLACE ... REGEX or CL_ABAP_REGEX POSIX methods) have been superseded by modern string built-in functions, templates, and Perl-Compatible Regular Expressions (PCRE). POSIX regular expressions suffer from quadratic backtracking performance and inconsistent Unicode support, whereas PCRE (via FIND PCRE or XCO regex APIs) is optimized, secure, and standardized across ABAP Cloud.

### Non-Compliant

```abap
FIND REGEX '^[0-9]+$' IN lv_postal_code.
PACK lv_customer_number TO lv_packed_id.
```

### Compliant

```abap
FIND PCRE '^[0-9]+$' IN lv_postal_code.
lv_packed_id = lv_customer_number.
```

## Configuration & Thresholds

This check can be fine-tuned directly in the ATC Check Variant Editor (`CHKV`) in Eclipse ADT:

| Parameter Name | Data Type | Default Value | Description & Guidance |
|---|---|:---:|---|
| `CHECK_PACK` | `Boolean` | <code>true</code> | Report obsolete PACK statements in favor of modern numeric assignment expressions. |
| `CHECK_UNPACK` | `Boolean` | <code>true</code> | Report obsolete UNPACK statements in favor of string padding and format functions. |
| `CHECK_REGEX` | `Boolean` | <code>true</code> | Report obsolete POSIX regular expressions in FIND/REPLACE statements in favor of PCRE. |
| `CHECK_OCCURENCES` | `Boolean` | <code>true</code> | Report obsolete OCCURENCES addition syntax (misspelled variant) in string operations. |
| `CHECK_REPLACE_INTO` | `Boolean` | <code>true</code> | Report obsolete REPLACE ... WITH ... INTO statements in favor of assignment expressions. |

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC NO_OBS_STRINGS

" SAP CI_ prefix format:
... "#EC CI_NO_OBS_STRINGS
```

### Monitored String Constructs

| Legacy Syntax | Modern Replacement |
|---|---|
| `FIND REGEX ...` | `FIND PCRE ...` or XCO Regex APIs |
| `REPLACE REGEX ...` | `REPLACE PCRE ...` |
| `PACK source TO dest.` | Direct numeric assignment `dest = source.` |
| `UNPACK source TO dest.` | String formatting functions or string templates |
| `REPLACE ... WITH ... INTO ...` | String functions `replace( )` or assignment |
| `OCCURENCES` (misspelled) | Use `ALL OCCURRENCES` |
| `CL_ABAP_REGEX=>CREATE_POSIX` | Use PCRE-enabled regex classes |

Suppress with `"#EC NO_OBS_STRINGS`.


## Related Rules

* [Replace Obsolete Arithmetic Statements with Modern Operators](/rules/no-obs-arith) — <code>#EC NO_OBS_ARITH</code>
* [Eliminate Obsolete Control Flow and Procedural Statements](/rules/no-obs-control) — <code>#EC NO_OBS_CONTROL</code>
* [Replace Obsolete Data Declarations with Explicit Types](/rules/no-obs-decl) — <code>#EC NO_OBS_DECL</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_NO_OBS_STRINGS`
* **ABAP Implementation:** [/skyl/cl_no_obs_strings.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_no_obs_strings.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 1337)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L1337)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_NO_OBS_STRINGS&title=%5BBug%5D%3A%20Issue%20in%20no-obs-strings)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20no-obs-strings)**
