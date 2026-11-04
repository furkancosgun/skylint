---
title: "Declare Character Lengths with Explicit LENGTH Clause Instead of Parenthesized Syntax"
description: "Replace legacy parenthesized length specifications in ABAP declarations with modern TYPE LENGTH syntax and automated quickfixes."
keywords: "no-inline-len, Clean ABAP, ABAP Cloud, LENGTH clause, DATA declaration, SAP ATC"
category: "anti-patterns"
ruleId: "no-inline-len"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L2728"
---

# Declare Character Lengths with Explicit LENGTH Clause Instead of Parenthesized Syntax

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Anti-Patterns & Bad Practices" />
  <Badge type="warning" text="QuickFix Ready" />
  <Badge type="danger" text="#EC NO_INLINE_LEN" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L2728" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Avoid inline length specification in declarations.

> **ATC Finding Message:** `Avoid length in parentheses; use TYPE ... LENGTH ...`

## Rationale

Specifying variable lengths directly on identifiers using parentheses, such as DATA lv_code(10) TYPE c, is legacy ABAP syntax that easily confuses identifier names with function calls, array indices, or substring offsets. Modern ABAP Cloud and Clean ABAP standards require explicit length declarations using the TYPE ... LENGTH ... addition or domain-specific named types. The ATC check flags parenthesized lengths in DATA, CONSTANTS, and STATICS statements with NO_INL_LEN and provides the USELENGTH quickfix to rewrite the statement cleanly.

### Non-Compliant

```abap
DATA lv_postal_code(10) TYPE c.
```

### Compliant

```abap
DATA lv_postal_code TYPE c LENGTH 10.
```

## Automated QuickFix

This rule provides an **automated QuickFix** directly in Eclipse ABAP Development Tools (ADT):
1. Position the cursor on the flagged statement.
2. Press <kbd>Ctrl</kbd> + <kbd>1</kbd> (Quick Assist).
3. Select the automated refactoring to apply the clean syntax immediately.

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC NO_INLINE_LEN

" SAP CI_ prefix format:
... "#EC CI_NO_INLINE_LEN
```

## Detection and Quickfix Details

The check evaluates `DATA`, `CONSTANTS`, and `STATICS` statements whose identifier token matches the pattern `*(*)` with an embedded length specification. When flagged, the check offers the `USELENGTH` quickfix, which automatically transforms declarations into modern `TYPE c LENGTH ...` syntax.

| Legacy Syntax | Modern Clean ABAP Replacement |
|---|---|
| `DATA lv_code(10) TYPE c.` | `DATA lv_code TYPE c LENGTH 10.` |
| `DATA lv_flag(1).` | `DATA lv_flag TYPE c LENGTH 1.` |
| `CONSTANTS lc_prefix(4) TYPE c VALUE 'INV-'.` | `CONSTANTS lc_prefix TYPE c LENGTH 4 VALUE 'INV-'.` |

### Suppression
Suppress findings with the pseudo comment `"#EC NO_INLINE_LEN`.


## Related Rules

* [Prefer Inline Declarations over Separate DATA and Assignment](/rules/pref-inline) — <code>#EC PREF_INLINE</code>
* [Avoid Chained Declarations for Variables, Types, and Constants](/rules/no-chained-decl) — <code>#EC NO_CHAINED_DECL</code>
* [Avoid Chained Assignments Binding Multiple Targets Simultaneously](/rules/no-chained-assign) — <code>#EC NO_CHAINED_ASSIGN</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_NO_INLINE_LEN`
* **ABAP Implementation:** [/skyl/cl_no_inline_len.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_no_inline_len.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 2728)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L2728)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_NO_INLINE_LEN&title=%5BBug%5D%3A%20Issue%20in%20no-inline-len)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20no-inline-len)**
