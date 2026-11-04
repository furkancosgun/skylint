---
title: "Avoid Obsolete Inline Length Specifications (var(len))"
description: "Avoid Obsolete Inline Length Specifications (var(len)) - Clean ABAP guidelines, modern SAP syntax rules, and automated ATC code inspection for SAP S/4HANA and ABAP Cloud."
keywords: "Clean ABAP, SAP ATC Check, ABAP Cloud, S/4HANA Readiness, no-inline-len, anti-patterns"
category: "anti-patterns"
ruleId: "no-inline-len"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L2675"
---

# Avoid Obsolete Inline Length Specifications (var(len))

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Anti-Patterns & Bad Practices" />
  <Badge type="warning" text="QuickFix Ready" />
  <Badge type="danger" text="#EC NO_INLINE_LEN" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L2675" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Avoid inline length specification in declarations.

> **ATC Finding Message:** `Avoid length in parentheses; use TYPE ... LENGTH ...`

## Rationale

The legacy lv_name(10) syntax mixes the identifier and its length and is easy to misread as a substring or function call. Modern ABAP writes the type and length as separate, explicit tokens. Use TYPE c LENGTH n or a named type so the declaration is unambiguous.

### Non-Compliant

```abap
DATA lv_country(2) TYPE c.
```

### Compliant

```abap
DATA lv_country TYPE c LENGTH 2.
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


## Related Rules

* [Prefer Modern Inline Declarations in ABAP 7.40+](/rules/pref-inline) — <code>#EC PREF_INLINE</code>
* [Avoid Chained Declarations (DATA:, CONSTANTS:, TYPES:)](/rules/no-chained-decl) — <code>#EC NO_CHAINED_DECL</code>
* [Avoid Chained Assignments (a = b = c = 1)](/rules/no-chained-assign) — <code>#EC NO_CHAINED_ASSIGN</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_NO_INLINE_LEN`
* **ABAP Implementation:** [/skyl/cl_no_inline_len.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_no_inline_len.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 2675)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L2675)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_NO_INLINE_LEN&title=%5BBug%5D%3A%20Issue%20in%20no-inline-len)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20no-inline-len)**
