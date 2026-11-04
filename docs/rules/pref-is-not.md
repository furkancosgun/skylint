---
title: "Rewrite NOT ... IS Predicates as IS NOT"
description: "Rewrite negated predicates such as NOT lt_items IS INITIAL into the natural reading IS NOT INITIAL in IF, CHECK and WHILE."
keywords: "pref-is-not, IS NOT INITIAL, negated condition, predicate, Clean ABAP"
category: "clean-abap"
ruleId: "pref-is-not"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L444"
---

# Rewrite NOT ... IS Predicates as IS NOT

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="warning" text="QuickFix Ready" />
  <Badge type="danger" text="#EC PREF_IS_NOT" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L444" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Prefer IS NOT over NOT ... IS.

> **ATC Finding Message:** `Use IS NOT instead of NOT ... IS`

## Rationale

A leading NOT forces the reader to negate the whole predicate mentally, and in compound conditions the negation is easily attached to the wrong term. IS NOT keeps the subject first and reads in natural order, for example lo_instance IS NOT BOUND. The check inspects IF, ELSEIF, CHECK and WHILE statements for NOT followed by IS plus a supported predicate, reports PREF_ISNOT and offers an ISNOT quickfix that swaps the tokens in place.

### Non-Compliant

```abap
IF NOT lt_open_items IS INITIAL.
  process_open_items( lt_open_items ).
ENDIF.
```

### Compliant

```abap
IF lt_open_items IS NOT INITIAL.
  process_open_items( lt_open_items ).
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
... "#EC PREF_IS_NOT

" SAP CI_ prefix format:
... "#EC CI_PREF_IS_NOT
```

## Supported Predicates

The rewrite is offered for `IS INITIAL`, `IS BOUND`, `IS ASSIGNED`, `IS SUPPLIED`, `IS REQUESTED` and `IS INSTANCE`. Only keyword tokens are inspected, so a variable or component that happens to be named `not` or `is` never triggers a finding. The `ISNOT` quickfix is only created for the adjacent pattern `NOT x IS INITIAL`; longer negations are reported without a quickfix.


## Related Rules

* [Prefer IS [NOT] INITIAL Over lines( ) and Empty Literal Comparisons](/rules/pref-is-initial) — <code>#EC PREF_IS_INITIAL</code>
* [Prefer CASE over Multiple IF / ELSEIF on the Same Variable](/rules/pref-case) — <code>#EC PREF_CASE</code>
* [Collapse Value-Mapping IF Chains into COND](/rules/pref-cond) — <code>#EC PREF_COND</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_PREF_IS_NOT`
* **ABAP Implementation:** [/skyl/cl_pref_is_not.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_pref_is_not.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 444)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L444)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_PREF_IS_NOT&title=%5BBug%5D%3A%20Issue%20in%20pref-is-not)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20pref-is-not)**
