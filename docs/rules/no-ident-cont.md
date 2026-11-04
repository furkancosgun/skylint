---
title: "Avoid Identical Statements in IF Branches"
description: "Avoid Identical Statements in IF Branches - Clean ABAP guidelines, modern SAP syntax rules, and automated ATC code inspection for SAP S/4HANA and ABAP Cloud."
keywords: "Clean ABAP, SAP ATC Check, ABAP Cloud, S/4HANA Readiness, no-ident-cont, anti-patterns"
category: "anti-patterns"
ruleId: "no-ident-cont"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L836"
---

# Avoid Identical Statements in IF Branches

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Anti-Patterns & Bad Practices" />
  <Badge type="danger" text="#EC NO_IDENT_CONT" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L836" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Avoid identical code in IF and ELSE branches.

> **ATC Finding Message:** `Identical statement in IF and ELSE branches; extract common code`

## Rationale

Statements repeated in every branch of an IF/ELSEIF/ELSE carry no branch-specific meaning and duplicate maintenance. If the same statement starts or ends every branch, extract it before or after the IF so it is written once and stays in sync.

### Non-Compliant

```abap
IF lv_is_active = abap_true.
  process( ).
ELSE.
  process( ).
ENDIF.
```

### Compliant

```abap
IF lv_is_active = abap_true.
  process_active( ).
ELSE.
  process_inactive( ).
ENDIF.
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC NO_IDENT_CONT

" SAP CI_ prefix format:
... "#EC CI_NO_IDENT_CONT
```


## Related Rules

* [Avoid CASE with a Single WHEN Branch](/rules/no-single-when) — <code>#EC NO_SINGLE_WHEN</code>
* [Avoid CHECK Statements](/rules/no-check-stmt) — <code>#EC NO_CHECK_IN_LOOP</code>
* [Avoid Comparing to abap_true / abap_false](/rules/no-bool-compare) — <code>#EC NO_BOOL_COMPARE</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_NO_IDENT_CONT`
* **ABAP Implementation:** [/skyl/cl_no_ident_cont.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_no_ident_cont.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 836)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L836)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_NO_IDENT_CONT&title=%5BBug%5D%3A%20Issue%20in%20no-ident-cont)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20no-ident-cont)**
