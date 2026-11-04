---
title: "Prefer Enumerations over Constants"
description: "Prefer ABAP 7.51+ ENUM definitions over structured constants for value sets."
keywords: "Clean ABAP, ENUM, constants, pref-enum"
category: "clean-abap"
ruleId: "pref-enum"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L4824"
---

# Prefer Enumerations over Constants

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="danger" text="#EC PREF_ENUM" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L4824" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Prefer ENUM over CONSTANTS for set of related values.

> **ATC Finding Message:** `Prefer ENUM over CONSTANTS for set of related values`

## Rationale

Use TYPES: BEGIN OF ENUM ... END OF ENUM for related discrete value sets instead of structured CONSTANTS for type safety and modern syntax.

### Non-Compliant

```abap
CONSTANTS:
  BEGIN OF c_status,
    open TYPE string VALUE 'O',
  END OF c_status.
```

### Compliant

```abap
TYPES:
  BEGIN OF ENUM ty_status,
    open,
  END OF ENUM ty_status.
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC PREF_ENUM

" SAP CI_ prefix format:
... "#EC CI_PREF_ENUM
```


## Related Rules

* [Avoid Magic Numbers; Use Named Constants](/rules/no-magic-numbers) — <code>#EC NO_MAGIC_NUMBERS</code>
* [Avoid Hardcoding System & Tenant Environment Checks (sy-sysid, sy-mandt)](/rules/no-hardcoded-env) — <code>#EC NO_HARDCODED_ENV</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_PREF_ENUM`
* **ABAP Implementation:** [/skyl/cl_pref_enum.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_pref_enum.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 4824)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L4824)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_PREF_ENUM&title=%5BBug%5D%3A%20Issue%20in%20pref-enum)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20pref-enum)**
