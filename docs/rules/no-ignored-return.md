---
title: "Do Not Ignore Return Value of Functional Methods"
description: "Do Not Ignore Return Value of Functional Methods - Clean ABAP guidelines, modern SAP syntax rules, and automated ATC code inspection for SAP S/4HANA and ABAP Cloud."
keywords: "Clean ABAP, SAP ATC Check, ABAP Cloud, S/4HANA Readiness, no-ignored-return, anti-patterns"
category: "anti-patterns"
ruleId: "no-ignored-return"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L3209"
---

# Do Not Ignore Return Value of Functional Methods

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Anti-Patterns & Bad Practices" />
  <Badge type="danger" text="#EC NO_IGNORED_RETURN" />
  <Badge type="warning" text="Local Only" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L3209" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Disallow ignoring the return value of functional methods.

> **ATC Finding Message:** `Do not ignore return value of functional method; assign or use result`

## Rationale

A functional method is called for its RETURNING value, so discarding that value usually means the call is pointless or the method hides side effects. If the method intentionally has side effects, it should not return a value. Assign or consume the result, or refactor the method into a command.

### Non-Compliant

```abap
lo_calculator->get_total( ).
```

### Compliant

```abap
lv_total = lo_calculator->get_total( ).
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC NO_IGNORED_RETURN

" SAP CI_ prefix format:
... "#EC CI_NO_IGNORED_RETURN
```


## Related Rules

* [Prefer RETURN over EXIT in Methods](/rules/pref-return) — <code>#EC PREF_RETURN</code>
* [Omit Unnecessary RETURN Statement](/rules/no-unnec-return) — <code>#EC NO_UNNEC_RETURN</code>
* [Do Not Mix RETURNING with EXPORTING or CHANGING](/rules/no-mix-returning) — <code>#EC NO_MIX_RETURNING</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_NO_IGNORED_RETURN`
* **ABAP Implementation:** [/skyl/cl_no_ignored_return.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_no_ignored_return.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 3209)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L3209)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_NO_IGNORED_RETURN&title=%5BBug%5D%3A%20Issue%20in%20no-ignored-return)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20no-ignored-return)**
