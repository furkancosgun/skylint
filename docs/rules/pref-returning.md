---
title: "Prefer Functional RETURNING Parameters"
description: "Prefer Functional RETURNING Parameters - Clean ABAP guidelines, modern SAP syntax rules, and automated ATC code inspection for SAP S/4HANA and ABAP Cloud."
keywords: "Clean ABAP, SAP ATC Check, ABAP Cloud, S/4HANA Readiness, pref-returning, clean-abap"
category: "clean-abap"
ruleId: "pref-returning"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L1799"
---

# Prefer Functional RETURNING Parameters

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="danger" text="#EC PREF_RETURNING" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L1799" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Prefer RETURNING over single EXPORTING.

> **ATC Finding Message:** `Prefer functional RETURNING parameter over single EXPORTING parameter`

## Rationale

A single EXPORTING parameter forces callers to declare a target and invoke the method as a statement. A RETURNING parameter makes the method usable directly in assignments, expressions, and assertions. Prefer RETURNING for value-producing methods and reserve EXPORTING for methods that genuinely return several outputs.

### Non-Compliant

```abap
METHODS get_total
  EXPORTING ev_total TYPE i.
```

### Compliant

```abap
METHODS get_total
  RETURNING VALUE(rv_total) TYPE i.
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC PREF_RETURNING

" SAP CI_ prefix format:
... "#EC CI_PREF_RETURNING
```


## Related Rules

* [Do Not Mix RETURNING with EXPORTING or CHANGING](/rules/no-mix-returning) — <code>#EC NO_MIX_RETURNING</code>
* [Do Not Ignore Return Value of Functional Methods](/rules/no-ignored-return) — <code>#EC NO_IGNORED_RETURN</code>
* [Method Call Parameter Naming Style (Omit or Require)](/rules/pref-param-name) — <code>#EC PREF_PARAM_NAME</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_PREF_RETURNING`
* **ABAP Implementation:** [/skyl/cl_pref_returning.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_pref_returning.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 1799)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L1799)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_PREF_RETURNING&title=%5BBug%5D%3A%20Issue%20in%20pref-returning)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20pref-returning)**
