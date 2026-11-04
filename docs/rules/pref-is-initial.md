---
title: "Prefer IS [NOT] INITIAL over lines( ) or Literal Comparisons"
description: "Prefer IS [NOT] INITIAL over lines( ) or Literal Comparisons - Clean ABAP guidelines, modern SAP syntax rules, and automated ATC code inspection for SAP S/4HANA and ABAP Cloud."
keywords: "Clean ABAP, SAP ATC Check, ABAP Cloud, S/4HANA Readiness, pref-is-initial, clean-abap"
category: "clean-abap"
ruleId: "pref-is-initial"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L3181"
---

# Prefer IS [NOT] INITIAL over lines( ) or Literal Comparisons

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="warning" text="QuickFix Ready" />
  <Badge type="danger" text="#EC PREF_IS_INITIAL" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L3181" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Prefer IS [NOT] INITIAL over lines( ) or empty literals.

> **ATC Finding Message:** `Use IS [NOT] INITIAL instead of lines( ) or empty literal comparison`

## Rationale

Comparing lines( ) to zero or a string to an empty literal asks an indirect question. IS INITIAL states emptiness directly and works for tables, strings, structures, and elementary values. It also avoids counting overhead and literal edge cases.

### Non-Compliant

```abap
IF lines( lt_items ) > 0.
  process( ).
ENDIF.
```

### Compliant

```abap
IF lt_items IS NOT INITIAL.
  process( ).
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
... "#EC PREF_IS_INITIAL

" SAP CI_ prefix format:
... "#EC CI_PREF_IS_INITIAL
```


## Related Rules

* [Prefer IS NOT over NOT ... IS](/rules/pref-is-not) — <code>#EC PREF_IS_NOT</code>
* [Prefer CASE over Multiple IF / ELSEIF on the Same Variable](/rules/pref-case) — <code>#EC PREF_CASE</code>
* [Prefer COND #( ) Expression over IF/ELSEIF/ELSE](/rules/pref-cond) — <code>#EC PREF_COND</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_PREF_IS_INITIAL`
* **ABAP Implementation:** [/skyl/cl_pref_is_initial.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_pref_is_initial.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 3181)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L3181)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_PREF_IS_INITIAL&title=%5BBug%5D%3A%20Issue%20in%20pref-is-initial)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20pref-is-initial)**
