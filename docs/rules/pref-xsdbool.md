---
title: "Prefer xsdbool( ) for Boolean Assignments"
description: "Prefer xsdbool( ) for Boolean Assignments - Clean ABAP guidelines, modern SAP syntax rules, and automated ATC code inspection for SAP S/4HANA and ABAP Cloud."
keywords: "Clean ABAP, SAP ATC Check, ABAP Cloud, S/4HANA Readiness, pref-xsdbool, clean-abap"
category: "clean-abap"
ruleId: "pref-xsdbool"
---

# Prefer xsdbool( ) for Boolean Assignments

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="warning" text="QuickFix Ready" />
  <Badge type="danger" text="#EC PREF_XSDBOOL" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Prefer xsdbool( ) expression over manual IF-ELSE assignment.

> **ATC Finding Message:** `Prefer xsdbool( ) over manual IF-ELSE assignment`

## Rationale

An IF/ELSE whose only task is to assign abap_true or abap_false uses many lines for a single boolean conversion. xsdbool( ) expresses the condition directly and assigns the result in one statement. This removes duplicated branches and makes the relationship between condition and flag obvious.

### Non-Compliant

```abap
IF lv_discount > 0.
  lv_has_discount = abap_true.
ELSE.
  lv_has_discount = abap_false.
ENDIF.
```

### Compliant

```abap
lv_has_discount = xsdbool( lv_discount > 0 ).
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
... "#EC PREF_XSDBOOL

" SAP CI_ prefix format:
... "#EC CI_PREF_XSDBOOL
```


## Related Rules

* [Limit Boolean Expression Complexity in Conditional Statements](/rules/max-bool-expr) — <code>#EC MAX_BOOL_EXPR</code>
* [Prefer CASE over Multiple IF / ELSEIF on the Same Variable](/rules/pref-case) — <code>#EC PREF_CASE</code>
* [Prefer COND #( ) Expression over IF/ELSEIF/ELSE](/rules/pref-cond) — <code>#EC PREF_COND</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_PREF_XSDBOOL`
* **Implementation File:** [#skyl#cl_pref_xsdbool.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_pref_xsdbool.clas.abap)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_PREF_XSDBOOL&title=%5BBug%5D%3A%20Issue%20in%20pref-xsdbool)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20pref-xsdbool)**
