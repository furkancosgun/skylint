---
title: "Avoid Generic and Implicit ANY Types"
description: "Disallow untyped field symbols and generic ANY parameters in ABAP code."
keywords: "Clean ABAP, implicit any, generic type, no-implicit-any"
category: "clean-abap"
ruleId: "no-implicit-any"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L4900"
---

# Avoid Generic and Implicit ANY Types

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="danger" text="#EC NO_IMPLICIT_ANY" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L4900" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Specify concrete types instead of generic or implicit ANY.

> **ATC Finding Message:** `Specify explicit concrete types instead of generic or implicit ANY`

## Rationale

Untyped FIELD-SYMBOLS or method parameters defaulting to ANY sacrifice compile-time type safety. Always specify explicit concrete types.

### Non-Compliant

```abap
FIELD-SYMBOLS <fs>.
```

### Compliant

```abap
FIELD-SYMBOLS <fs> TYPE string.
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC NO_IMPLICIT_ANY

" SAP CI_ prefix format:
... "#EC CI_NO_IMPLICIT_ANY
```


## Related Rules

* [Require Fully Typed Variables and Parameters](/rules/pref-full-typed) — <code>#EC PREF_FULL_TYPED</code>
* [Prefer FINAL( ) over DATA( ) when the variable is never written again](/rules/pref-final-data) — <code>#EC PREF_FINAL_DATA</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_NO_IMPLICIT_ANY`
* **ABAP Implementation:** [/skyl/cl_no_implicit_any.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_no_implicit_any.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 4900)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L4900)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_NO_IMPLICIT_ANY&title=%5BBug%5D%3A%20Issue%20in%20no-implicit-any)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20no-implicit-any)**
