---
title: "Avoid Duplicate Branch Conditions"
description: "Avoid Duplicate Branch Conditions - Clean ABAP guidelines, modern SAP syntax rules, and automated ATC code inspection for SAP S/4HANA and ABAP Cloud."
keywords: "Clean ABAP, SAP ATC Check, ABAP Cloud, S/4HANA Readiness, no-dup-cond, anti-patterns"
category: "anti-patterns"
ruleId: "no-dup-cond"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L864"
---

# Avoid Duplicate Branch Conditions

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Anti-Patterns & Bad Practices" />
  <Badge type="warning" text="QuickFix Ready" />
  <Badge type="danger" text="#EC NO_DUP_COND" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L864" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Avoid duplicate branch conditions in IF and CASE.

> **ATC Finding Messages:**
> - `Identical condition in branch; duplicate branch is unreachable`
> - `Identical operand in condition; remove the duplicate comparison`

## Rationale

A repeated IF/ELSEIF or WHEN condition can never be reached because the earlier branch already handles it. This is usually a copy-paste error and can leave the intended branch permanently dead. Remove the duplicate or correct the condition so every branch has a distinct purpose.

### Non-Compliant

```abap
IF lv_status = 'A'.
  process_a( ).
ELSEIF lv_status = 'A'.
  process_b( ).
ENDIF.
```

### Compliant

```abap
IF lv_status = 'A'.
  process_a( ).
ELSEIF lv_status = 'B'.
  process_b( ).
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
... "#EC NO_DUP_COND

" SAP CI_ prefix format:
... "#EC CI_NO_DUP_COND
```


## Related Rules

* [Avoid Yoda Conditions](/rules/no-yoda-cond) — <code>#EC NO_YODA_COND</code>
* [Avoid Negated IF Conditions with ELSE](/rules/no-neg-cond) — <code>#EC NO_NEG_COND</code>
* [Prefer COND #( ) Expression over IF/ELSEIF/ELSE](/rules/pref-cond) — <code>#EC PREF_COND</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_NO_DUP_COND`
* **ABAP Implementation:** [/skyl/cl_no_dup_cond.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_no_dup_cond.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 864)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L864)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_NO_DUP_COND&title=%5BBug%5D%3A%20Issue%20in%20no-dup-cond)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20no-dup-cond)**
