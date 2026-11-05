---
title: "Avoid Variable Names with Numeric Suffixes"
description: "Report variables with trailing numeric suffixes such as lv_count1 or ls_tmp2."
keywords: "no-numbered-var, numbered variables, variable naming, numeric suffix, Clean ABAP naming"
category: "clean-abap"
ruleId: "no-numbered-var"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L6090"
---

# Avoid Variable Names with Numeric Suffixes

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="danger" text="#EC NO_NUMBERED_VAR" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L6090" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Avoid variable names with numeric suffixes.

> **ATC Finding Message:** `Avoid numbered variable names like lv_count1; use descriptive names`

## Rationale

Numbered variable names like lv_count1, lv_idx2, or ls_tmp3 often indicate poor naming or the need for a dedicated collection or internal table. Use descriptive names that convey intent or use structured types.

### Non-Compliant

```abap
DATA lv_count1 TYPE i VALUE 0.
```

### Compliant

```abap
DATA lv_source_count TYPE i VALUE 0.
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC NO_NUMBERED_VAR

" SAP CI_ prefix format:
... "#EC CI_NO_NUMBERED_VAR
```


## Related Rules

* [Enforce Configured Naming Conventions for Local Variables and Field-Symbols](/rules/pref-naming-vars) — <code>#EC PREF_NAMING_VARS</code>
* [Avoid Single-Letter Identifiers in Declarations](/rules/no-single-letter) — <code>#EC NO_SINGLE_LETTER</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_NO_NUMBERED_VAR`
* **ABAP Implementation:** [/skyl/cl_no_numbered_var.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_no_numbered_var.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 6090)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L6090)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_NO_NUMBERED_VAR&title=%5BBug%5D%3A%20Issue%20in%20no-numbered-var)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20no-numbered-var)**
