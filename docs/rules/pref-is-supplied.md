---
title: "Prefer IS SUPPLIED over IS REQUESTED"
description: "Prefer IS SUPPLIED over IS REQUESTED - Clean ABAP guidelines, modern SAP syntax rules, and automated ATC code inspection for SAP S/4HANA and ABAP Cloud."
keywords: "Clean ABAP, SAP ATC Check, ABAP Cloud, S/4HANA Readiness, pref-is-supplied, clean-abap"
category: "clean-abap"
ruleId: "pref-is-supplied"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L3636"
---

# Prefer IS SUPPLIED over IS REQUESTED

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="warning" text="QuickFix Ready" />
  <Badge type="danger" text="#EC PREF_IS_SUPPLIED" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L3636" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Prefer IS SUPPLIED over the obsolete IS REQUESTED.

> **ATC Finding Message:** `Use IS SUPPLIED instead of IS REQUESTED`

## Rationale

IS REQUESTED is obsolete and only reports whether an output parameter was requested by the caller, not whether an input was actually supplied. IS SUPPLIED works for every parameter direction and states the real condition. Replace IS REQUESTED with IS SUPPLIED.

### Non-Compliant

```abap
IF iv_currency IS REQUESTED.
  convert_amount( iv_currency ).
ENDIF.
```

### Compliant

```abap
IF iv_currency IS SUPPLIED.
  convert_amount( iv_currency ).
ENDIF.
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
... "#EC PREF_IS_SUPPLIED

" SAP CI_ prefix format:
... "#EC CI_PREF_IS_SUPPLIED
```


## Related Rules

* [Prefer Functional RETURNING Parameters](/rules/pref-returning) — <code>#EC PREF_RETURNING</code>
* [Method Call Parameter Naming Style (Omit or Require)](/rules/pref-param-name) — <code>#EC PREF_PARAM_NAME</code>
* [Prefer RETURN over EXIT in Methods](/rules/pref-return) — <code>#EC PREF_RETURN</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_PREF_IS_SUPPLIED`
* **ABAP Implementation:** [/skyl/cl_pref_is_supplied.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_pref_is_supplied.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 3636)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L3636)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_PREF_IS_SUPPLIED&title=%5BBug%5D%3A%20Issue%20in%20pref-is-supplied)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20pref-is-supplied)**
