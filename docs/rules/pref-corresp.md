---
title: "Prefer CORRESPONDING #( ) Operator"
description: "Prefer CORRESPONDING #( ) Operator - Clean ABAP guidelines, modern SAP syntax rules, and automated ATC code inspection for SAP S/4HANA and ABAP Cloud."
keywords: "Clean ABAP, SAP ATC Check, ABAP Cloud, S/4HANA Readiness, pref-corresp, clean-abap"
category: "clean-abap"
ruleId: "pref-corresp"
---

# Prefer CORRESPONDING #( ) Operator

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="warning" text="QuickFix Ready" />
  <Badge type="danger" text="#EC PREF_CORRESP" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Prefer CORRESPONDING Expression over MOVE-CORRESPONDING.

> **ATC Finding Message:** `Prefer functional CORRESPONDING #( ... ) over MOVE-CORRESPONDING`

## Rationale

MOVE-CORRESPONDING is a procedural statement that copies same-named fields implicitly and cannot be nested in expressions. CORRESPONDING #( ) is expression-capable and supports EXCEPT, MAPPING, and DISCARDING to control the mapping explicitly. Use it to make structure transfers visible and type-safe.

### Non-Compliant

```abap
MOVE-CORRESPONDING ls_customer_api TO ls_customer_db.
```

### Compliant

```abap
ls_customer_db = CORRESPONDING #( ls_customer_api ).
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
... "#EC PREF_CORRESP

" SAP CI_ prefix format:
... "#EC CI_PREF_CORRESP
```


## Related Rules

* [Routine Declaration Hygiene (Top Placement & Order)](/rules/pref-declarations) — <code>#EC DEF_TOP</code>
* [Prefer Modern Inline Declarations in ABAP 7.40+](/rules/pref-inline) — <code>#EC PREF_INLINE</code>
* [Prefer FINAL( ) over DATA( ) when the variable is never written again](/rules/pref-final-data) — <code>#EC PREF_FINAL_DATA</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_PREF_CORRESP`
* **Implementation File:** [#skyl#cl_pref_corresp.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_pref_corresp.clas.abap)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_PREF_CORRESP&title=%5BBug%5D%3A%20Issue%20in%20pref-corresp)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20pref-corresp)**
