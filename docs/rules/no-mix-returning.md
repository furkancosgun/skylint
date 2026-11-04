---
title: "Do Not Mix RETURNING with EXPORTING or CHANGING"
description: "Do Not Mix RETURNING with EXPORTING or CHANGING - Clean ABAP guidelines, modern SAP syntax rules, and automated ATC code inspection for SAP S/4HANA and ABAP Cloud."
keywords: "Clean ABAP, SAP ATC Check, ABAP Cloud, S/4HANA Readiness, no-mix-returning, anti-patterns"
category: "anti-patterns"
ruleId: "no-mix-returning"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L3125"
---

# Do Not Mix RETURNING with EXPORTING or CHANGING

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Anti-Patterns & Bad Practices" />
  <Badge type="danger" text="#EC NO_MIX_RETURNING" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L3125" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Do not mix RETURNING with EXPORTING or CHANGING.

> **ATC Finding Message:** `Do not mix RETURNING with EXPORTING or CHANGING parameters in a single method`

## Rationale

A method that returns a value and also exports or changes parameters has a mixed contract: callers must capture the result and provide extra targets. This complicates expression use and suggests the method does more than one thing. Split it into a functional query and a separate command.

### Non-Compliant

```abap
METHODS get_data
  EXPORTING ev_count TYPE i
  RETURNING VALUE(rv_result) TYPE string.
```

### Compliant

```abap
METHODS get_data
  RETURNING VALUE(rv_result) TYPE string.
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC NO_MIX_RETURNING

" SAP CI_ prefix format:
... "#EC CI_NO_MIX_RETURNING
```


## Related Rules

* [Prefer Functional RETURNING Parameters](/rules/pref-returning) — <code>#EC PREF_RETURNING</code>
* [Omit Redundant EXPORTING in Method Calls](/rules/no-call-exporting) — <code>#EC NO_CALL_EXPORTING</code>
* [Do Not Ignore Return Value of Functional Methods](/rules/no-ignored-return) — <code>#EC NO_IGNORED_RETURN</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_NO_MIX_RETURNING`
* **ABAP Implementation:** [/skyl/cl_no_mix_returning.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_no_mix_returning.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 3125)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L3125)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_NO_MIX_RETURNING&title=%5BBug%5D%3A%20Issue%20in%20no-mix-returning)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20no-mix-returning)**
