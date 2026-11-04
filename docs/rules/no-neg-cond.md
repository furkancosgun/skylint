---
title: "Avoid Negated IF Conditions with ELSE"
description: "Avoid Negated IF Conditions with ELSE - Clean ABAP guidelines, modern SAP syntax rules, and automated ATC code inspection for SAP S/4HANA and ABAP Cloud."
keywords: "Clean ABAP, SAP ATC Check, ABAP Cloud, S/4HANA Readiness, no-neg-cond, clean-abap"
category: "clean-abap"
ruleId: "no-neg-cond"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L3776"
---

# Avoid Negated IF Conditions with ELSE

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="danger" text="#EC NO_NEG_COND" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L3776" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Avoid negated IF conditions with ELSE.

> **ATC Finding Message:** `Invert the condition and swap the branches`

## Rationale

A negated condition with an ELSE branch forces readers to negate the expression mentally before understanding the main path. Invert the condition and swap the branches, so the positive case comes first. This rule ignores ELSEIF chains and IS NOT predicates handled by the dedicated rule.

### Non-Compliant

```abap
IF NOT lv_is_valid.
  handle_error( ).
ELSE.
  process( ).
ENDIF.
```

### Compliant

```abap
IF lv_is_valid.
  process( ).
ELSE.
  handle_error( ).
ENDIF.
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC NO_NEG_COND

" SAP CI_ prefix format:
... "#EC CI_NO_NEG_COND
```


## Related Rules

* [Prefer COND #( ) Expression over IF/ELSEIF/ELSE](/rules/pref-cond) — <code>#EC PREF_COND</code>
* [Avoid Yoda Conditions](/rules/no-yoda-cond) — <code>#EC NO_YODA_COND</code>
* [Avoid Duplicate Branch Conditions](/rules/no-dup-cond) — <code>#EC NO_DUP_COND</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_NO_NEG_COND`
* **ABAP Implementation:** [/skyl/cl_no_neg_cond.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_no_neg_cond.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 3776)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L3776)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_NO_NEG_COND&title=%5BBug%5D%3A%20Issue%20in%20no-neg-cond)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20no-neg-cond)**
