---
title: "Avoid Obsolete String and POSIX Regex Statements"
description: "Avoid Obsolete String and POSIX Regex Statements - Clean ABAP guidelines, modern SAP syntax rules, and automated ATC code inspection for SAP S/4HANA and ABAP Cloud."
keywords: "Clean ABAP, SAP ATC Check, ABAP Cloud, S/4HANA Readiness, no-obs-strings, anti-patterns"
category: "anti-patterns"
ruleId: "no-obs-strings"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L1336"
---

# Avoid Obsolete String and POSIX Regex Statements

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Anti-Patterns & Bad Practices" />
  <Badge type="danger" text="#EC NO_OBS_STRINGS" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L1336" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Obsolete String and Regex Statements.

> **ATC Finding Message:** `Avoid obsolete string statements (PACK, UNPACK, POSIX REGEX, etc.)`

## Rationale

Statements such as PACK, UNPACK, REPLACE ... INTO, and FIND/REPLACE with REGEX / OCCURENCES (along with POSIX regular expression classes like CL_ABAP_REGEX=>CREATE_POSIX) are legacy constructs superseded by modern PCRE (Perl-Compatible Regular Expressions via PCRE keywords / XCO regex) and standard string expressions / built-ins.

### Non-Compliant

```abap
PACK lv_source TO lv_packed.
FIND REGEX 'pattern' IN lv_text.
```

### Compliant

```abap
FIND PCRE 'pattern' IN lv_text.
```

## Configuration & Thresholds

This check can be fine-tuned directly in the ATC Check Variant Editor (`CHKV`) in Eclipse ADT:

| Parameter Name | Data Type | Default Value | Description & Guidance |
|---|---|:---:|---|
| `CHECK_PACK` | `Boolean` | <code>true</code> | Detect obsolete PACK statement (prefer numeric assignment) |
| `CHECK_UNPACK` | `Boolean` | <code>true</code> | Detect obsolete UNPACK statement |
| `CHECK_REGEX` | `Boolean` | <code>true</code> | Detect obsolete POSIX regex statements in favour of PCRE |
| `CHECK_OCCURENCES` | `Boolean` | <code>true</code> | Detect obsolete OCCURRENCES addition syntax |
| `CHECK_REPLACE_INTO` | `Boolean` | <code>true</code> | Detect obsolete REPLACE ... WITH ... INTO syntax |

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC NO_OBS_STRINGS

" SAP CI_ prefix format:
... "#EC CI_NO_OBS_STRINGS
```


## Related Rules

* [Avoid Obsolete Arithmetic and Assignment Statements](/rules/no-obs-arith) — <code>#EC NO_OBS_ARITH</code>
* [Avoid Obsolete Control Flow and Procedural Forms](/rules/no-obs-control) — <code>#EC NO_OBS_CONTROL</code>
* [Avoid Obsolete Declarations and Table Headers](/rules/no-obs-decl) — <code>#EC NO_OBS_DECL</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_NO_OBS_STRINGS`
* **ABAP Implementation:** [/skyl/cl_no_obs_strings.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_no_obs_strings.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 1336)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L1336)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_NO_OBS_STRINGS&title=%5BBug%5D%3A%20Issue%20in%20no-obs-strings)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20no-obs-strings)**
