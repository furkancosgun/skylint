---
title: "Avoid Yoda Conditions"
description: "Avoid Yoda Conditions - Clean ABAP guidelines, modern SAP syntax rules, and automated ATC code inspection for SAP S/4HANA and ABAP Cloud."
keywords: "Clean ABAP, SAP ATC Check, ABAP Cloud, S/4HANA Readiness, no-yoda-cond, anti-patterns"
category: "anti-patterns"
ruleId: "no-yoda-cond"
---

# Avoid Yoda Conditions

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Anti-Patterns & Bad Practices" />
  <Badge type="warning" text="QuickFix Ready" />
  <Badge type="danger" text="#EC NO_YODA_COND" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Avoid Yoda conditions in comparison expressions.

> **ATC Finding Message:** `Avoid Yoda conditions; place variable before literal in comparison`

## Rationale

Yoda conditions place the literal or constant on the left side of a comparison and break the natural ABAP reading order of subject, operator, and value. The habit comes from languages where an accidental assignment in a condition is possible, which is not the case for ABAP comparisons. Keep the variable or expression on the left so conditions read like plain language.

### Non-Compliant

```abap
IF 'ACTIVE' = lv_status.
  process( ).
ENDIF.
```

### Compliant

```abap
IF lv_status = 'ACTIVE'.
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
... "#EC NO_YODA_COND

" SAP CI_ prefix format:
... "#EC CI_NO_YODA_COND
```


## Related Rules

* [Avoid Duplicate Branch Conditions](/rules/no-dup-cond) — <code>#EC NO_DUP_COND</code>
* [Avoid Negated IF Conditions with ELSE](/rules/no-neg-cond) — <code>#EC NO_NEG_COND</code>
* [Prefer COND #( ) Expression over IF/ELSEIF/ELSE](/rules/pref-cond) — <code>#EC PREF_COND</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_NO_YODA_COND`
* **Implementation File:** [#skyl#cl_no_yoda_cond.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_no_yoda_cond.clas.abap)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_NO_YODA_COND&title=%5BBug%5D%3A%20Issue%20in%20no-yoda-cond)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20no-yoda-cond)**
