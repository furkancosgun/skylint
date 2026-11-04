---
title: "Avoid Nesting COND and SWITCH Constructor Expressions"
description: "Flag COND and SWITCH expressions nested inside another constructor expression and flatten them into readable WHEN branches."
keywords: "no-nested-cond, COND, SWITCH, constructor expression, ABAP Cloud"
category: "clean-abap"
ruleId: "no-nested-cond"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L142"
---

# Avoid Nesting COND and SWITCH Constructor Expressions

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="danger" text="#EC NO_NESTED_COND" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L142" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Avoid Nested COND or SWITCH Expressions.

> **ATC Finding Message:** `Avoid nesting COND or SWITCH expressions inside each other`

## Rationale

A COND or SWITCH inside the parentheses of another constructor expression forces the reader to resolve an expression tree instead of a decision table, and every nesting level multiplies the number of branches a reviewer has to verify. The check walks the tokens of each statement, locates COND/SWITCH followed by an opening parenthesis and reports NO_NEST_CD for every COND/SWITCH found inside that group. Flattening the mapping into additional WHEN branches, or extracting a small helper method, keeps the logic testable and readable.

### Non-Compliant

```abap
lv_delivery_priority = COND string(
  WHEN lv_is_express = abap_true
    THEN COND string( WHEN lv_is_priority_customer = abap_true THEN 'P1' ELSE 'P2' )
  ELSE 'P3' ).
```

### Compliant

```abap
lv_delivery_priority = COND string(
  WHEN lv_is_express = abap_true AND lv_is_priority_customer = abap_true THEN 'P1'
  WHEN lv_is_express = abap_true                                     THEN 'P2'
  ELSE                                                                    'P3' ).
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC NO_NESTED_COND

" SAP CI_ prefix format:
... "#EC CI_NO_NESTED_COND
```

## Reported Nesting

Only COND and SWITCH expressions that appear inside the parentheses of another COND or SWITCH are reported. A COND nested in a `VALUE #( )`, `CORRESPONDING #( )` or in a method argument is out of scope, because those are separate expressions rather than branches of the same mapping. When flattening is not possible without repeating long conditions, extract a private helper method and call it from the WHEN branch.


## Related Rules

* [Collapse Value-Mapping IF Chains into COND](/rules/pref-cond) — <code>#EC PREF_COND</code>
* [Convert Pure CASE Mappings into SWITCH Expressions](/rules/pref-switch) — <code>#EC PREF_SWITCH</code>
* [Limit Control Flow Block Nesting Depth](/rules/max-nesting) — <code>#EC MAX_NESTING</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_NO_NESTED_COND`
* **ABAP Implementation:** [/skyl/cl_no_nested_cond.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_no_nested_cond.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 142)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L142)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_NO_NESTED_COND&title=%5BBug%5D%3A%20Issue%20in%20no-nested-cond)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20no-nested-cond)**
