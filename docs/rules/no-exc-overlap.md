---
title: "Classic EXCEPTIONS must not map two errors to the same number"
description: "Classic EXCEPTIONS must not map two errors to the same number - Clean ABAP guidelines, modern SAP syntax rules, and automated ATC code inspection for SAP S/4HANA and ABAP Cloud."
keywords: "Clean ABAP, SAP ATC Check, ABAP Cloud, S/4HANA Readiness, no-exc-overlap, anti-patterns"
category: "anti-patterns"
ruleId: "no-exc-overlap"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L2869"
---

# Classic EXCEPTIONS must not map two errors to the same number

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Anti-Patterns & Bad Practices" />
  <Badge type="danger" text="#EC NO_EXC_OVERLAP" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L2869" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Classic EXCEPTIONS must not overlap.

> **ATC Finding Message:** `Two classic exceptions share the same error number`

## Rationale

When two classic exceptions map to the same sy-subrc number, the caller cannot tell which failure occurred. This makes error handling guesswork and can hide the real cause. Assign distinct numbers and reserve OTHERS for unexpected failures.

### Non-Compliant

```abap
CALL FUNCTION 'Z_PROCESS_ORDER'
  EXCEPTIONS
    system_failure        = 1 MESSAGE lv_message
    communication_failure = 1 MESSAGE lv_message
    OTHERS                = 1.
```

### Compliant

```abap
CALL FUNCTION 'Z_PROCESS_ORDER'
  EXCEPTIONS
    system_failure        = 1 MESSAGE lv_message
    communication_failure = 2 MESSAGE lv_message
    OTHERS                = 3.
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC NO_EXC_OVERLAP

" SAP CI_ prefix format:
... "#EC CI_NO_EXC_OVERLAP
```


## Related Rules

* [Prefer Class-Based Exceptions over Classic EXCEPTIONS](/rules/pref-class-exc) — <code>#EC PREF_CLASS_EXC</code>
* [Avoid Catching Generic CX_ROOT (Catch Specific Exceptions)](/rules/no-catch-root) — <code>#EC NO_CATCH_ROOT</code>
* [Avoid Raising System Exceptions Directly (CX_SY_*)](/rules/no-raise-cx-sy) — <code>#EC NO_RAISE_CX_SY</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_NO_EXC_OVERLAP`
* **ABAP Implementation:** [/skyl/cl_no_exc_overlap.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_no_exc_overlap.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 2869)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L2869)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_NO_EXC_OVERLAP&title=%5BBug%5D%3A%20Issue%20in%20no-exc-overlap)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20no-exc-overlap)**
