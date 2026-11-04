---
title: "Collapse Value-Mapping IF Chains into COND"
description: "Convert IF/ELSEIF/ELSE chains that only assign one variable into a single COND constructor expression, with an automatic quickfix."
keywords: "pref-cond, COND, IF ELSEIF, constructor expression, Clean ABAP"
category: "clean-abap"
ruleId: "pref-cond"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L298"
---

# Collapse Value-Mapping IF Chains into COND

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="warning" text="QuickFix Ready" />
  <Badge type="danger" text="#EC PREF_COND" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L298" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Prefer COND #( ) expression over IF/ELSEIF/ELSE statement.

> **ATC Finding Message:** `Prefer COND #( ) constructor expression over IF/ELSEIF`

## Rationale

An IF/ELSEIF chain in which every branch only assigns the same variable spreads one decision over many lines, repeats the target and can leave it uninitialized when no branch matches. The check detects exactly that shape and reports PREF_COND, then offers a USECOND quickfix that rewrites the entire IF..ENDIF block into one COND expression. Assigning the result once makes the value mapping verifiable at a glance, composable in expressions and safe against a forgotten ELSE branch.

### Non-Compliant

```abap
IF lv_credit_score >= 800.
  lv_credit_rating = 'A'.
ELSEIF lv_credit_score >= 600.
  lv_credit_rating = 'B'.
ELSE.
  lv_credit_rating = 'C'.
ENDIF.
```

### Compliant

```abap
lv_credit_rating = COND string(
  WHEN lv_credit_score >= 800 THEN 'A'
  WHEN lv_credit_score >= 600 THEN 'B'
  ELSE                             'C' ).
```

## Automated QuickFix

This rule provides an **automated QuickFix** directly in Eclipse ABAP Development Tools (ADT):
1. Position the cursor on the flagged statement.
2. Press <kbd>Ctrl</kbd> + <kbd>1</kbd> (Quick Assist).
3. Select the automated refactoring to apply the clean syntax immediately.

## Configuration & Thresholds

This check can be fine-tuned directly in the ATC Check Variant Editor (`CHKV`) in Eclipse ADT:

| Parameter Name | Data Type | Default Value | Description & Guidance |
|---|---|:---:|---|
| `REQUIRE_ELSE` | `Boolean` | <code>false</code> | Only report IF chains that already contain an explicit ELSE branch. Enable when every COND replacement must define a total mapping; partial IF chains stay untouched. |

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC PREF_COND

" SAP CI_ prefix format:
... "#EC CI_PREF_COND
```

## When the Rule Fires

`PREF_COND` is raised only when the whole IF block is a pure value mapping:

- every branch contains exactly one statement,
- that statement is a plain assignment `target = expression`,
- every branch assigns the same target variable,
- the block ends directly with `ENDIF`.

A branch with a method call, `APPEND`, `RAISE`, several assignments or a nested block keeps the IF statement, because a COND expression cannot carry side effects. With `REQUIRE_ELSE` enabled only chains that already contain an explicit `ELSE` are reported, so a partial mapping is never silently completed by an implied ELSE.


## Related Rules

* [Avoid Negated IF Conditions with an ELSE Branch by Inverting Condition and Swapping Branches](/rules/no-neg-cond) — <code>#EC NO_NEG_COND</code>
* [Prefer CASE over Multiple IF / ELSEIF on the Same Variable](/rules/pref-case) — <code>#EC PREF_CASE</code>
* [Convert Pure CASE Mappings into SWITCH Expressions](/rules/pref-switch) — <code>#EC PREF_SWITCH</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_PREF_COND`
* **ABAP Implementation:** [/skyl/cl_pref_cond.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_pref_cond.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 298)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L298)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_PREF_COND&title=%5BBug%5D%3A%20Issue%20in%20pref-cond)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20pref-cond)**
