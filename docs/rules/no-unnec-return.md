---
title: "Omit Unnecessary RETURN Statement"
description: "Omit Unnecessary RETURN Statement - Clean ABAP guidelines, modern SAP syntax rules, and automated ATC code inspection for SAP S/4HANA and ABAP Cloud."
keywords: "Clean ABAP, SAP ATC Check, ABAP Cloud, S/4HANA Readiness, no-unnec-return, anti-patterns"
category: "anti-patterns"
ruleId: "no-unnec-return"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L3097"
---

# Omit Unnecessary RETURN Statement

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Anti-Patterns & Bad Practices" />
  <Badge type="warning" text="QuickFix Ready" />
  <Badge type="danger" text="#EC NO_UNNEC_RETURN" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L3097" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Omit unnecessary RETURN at end of routine.

> **ATC Finding Message:** `Omit optional RETURN at end of routine; routines return automatically`

## Rationale

A RETURN as the final statement of a method, form, or function changes nothing because the routine ends at ENDMETHOD, ENDFORM, or ENDFUNCTION anyway. It adds a line that implies a special exit and can obscure the real control flow. Remove trailing RETURN statements and keep early returns only where they are meaningful.

### Non-Compliant

```abap
METHOD get_total.
  rv_total = lv_subtotal + lv_tax.
  RETURN.
ENDMETHOD.
```

### Compliant

```abap
METHOD get_total.
  rv_total = lv_subtotal + lv_tax.
ENDMETHOD.
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
... "#EC NO_UNNEC_RETURN

" SAP CI_ prefix format:
... "#EC CI_NO_UNNEC_RETURN
```


## Related Rules

* [Do Not Ignore Return Value of Functional Methods](/rules/no-ignored-return) — <code>#EC NO_IGNORED_RETURN</code>
* [Prefer RETURN over EXIT in Methods](/rules/pref-return) — <code>#EC PREF_RETURN</code>
* [Omit Redundant EXPORTING in Method Calls](/rules/no-call-exporting) — <code>#EC NO_CALL_EXPORTING</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_NO_UNNEC_RETURN`
* **ABAP Implementation:** [/skyl/cl_no_unnec_return.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_no_unnec_return.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 3097)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L3097)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_NO_UNNEC_RETURN&title=%5BBug%5D%3A%20Issue%20in%20no-unnec-return)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20no-unnec-return)**
