---
title: "Prefer Modern Inline Declarations in ABAP 7.40+"
description: "Prefer Modern Inline Declarations in ABAP 7.40+ - Clean ABAP guidelines, modern SAP syntax rules, and automated ATC code inspection for SAP S/4HANA and ABAP Cloud."
keywords: "Clean ABAP, SAP ATC Check, ABAP Cloud, S/4HANA Readiness, pref-inline, clean-abap"
category: "clean-abap"
ruleId: "pref-inline"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L2757"
---

# Prefer Modern Inline Declarations in ABAP 7.40+

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="warning" text="QuickFix Ready" />
  <Badge type="danger" text="#EC PREF_INLINE" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L2757" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Prefer Inline Declarations.

> **ATC Finding Message:** `Prefer inline declaration over separate DATA and assignment`

## Rationale

Declaring a variable at the top and assigning it in the very next statement separates the declaration from its first use. Inline DATA( ) keeps the variable close to where it is needed and shortens its lifetime in the reader mind. Use inline declarations when the type is obvious from the initial value.

### Non-Compliant

```abap
DATA lv_name TYPE string.
lv_name = |Order { lv_id }|.
```

### Compliant

```abap
DATA(lv_name) = |Order { lv_id }|.
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
... "#EC PREF_INLINE

" SAP CI_ prefix format:
... "#EC CI_PREF_INLINE
```


## Related Rules

* [Avoid Obsolete Inline Length Specifications (var(len))](/rules/no-inline-len) — <code>#EC NO_INLINE_LEN</code>
* [Avoid Chained Declarations (DATA:, CONSTANTS:, TYPES:)](/rules/no-chained-decl) — <code>#EC NO_CHAINED_DECL</code>
* [Routine Declaration Hygiene (Top Placement & Order)](/rules/pref-declarations) — <code>#EC DEF_TOP</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_PREF_INLINE`
* **ABAP Implementation:** [/skyl/cl_pref_inline.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_pref_inline.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 2757)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L2757)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_PREF_INLINE&title=%5BBug%5D%3A%20Issue%20in%20pref-inline)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20pref-inline)**
