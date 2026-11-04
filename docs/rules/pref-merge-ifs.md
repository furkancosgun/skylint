---
title: "Merge Nested IF Statements"
description: "Merge Nested IF Statements - Clean ABAP guidelines, modern SAP syntax rules, and automated ATC code inspection for SAP S/4HANA and ABAP Cloud."
keywords: "Clean ABAP, SAP ATC Check, ABAP Cloud, S/4HANA Readiness, pref-merge-ifs, clean-abap"
category: "clean-abap"
ruleId: "pref-merge-ifs"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L892"
---

# Merge Nested IF Statements

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="warning" text="QuickFix Ready" />
  <Badge type="danger" text="#EC PREF_MERGE_IFS" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L892" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Merge consecutive nested IF blocks using boolean AND.

> **ATC Finding Messages:**
> - `Nested IF block can be merged with outer IF using AND`
> - `Nested IF in ELSE block can be changed to ELSEIF`

## Rationale

Nested IF statements without intermediate statements add indentation without adding meaning. Merging them with AND or converting a nested IF in an ELSE block into ELSEIF flattens the control flow and makes the combined condition explicit. Less nesting reduces cyclomatic complexity and makes the happy path easier to test.

### Non-Compliant

```abap
IF is_active( ).
  IF is_authorized( ).
    process_order( ).
  ENDIF.
ENDIF.
```

### Compliant

```abap
IF is_active( ) AND is_authorized( ).
  process_order( ).
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
... "#EC PREF_MERGE_IFS

" SAP CI_ prefix format:
... "#EC CI_PREF_MERGE_IFS
```


## Related Rules

* [Prefer CASE over Multiple IF / ELSEIF on the Same Variable](/rules/pref-case) — <code>#EC PREF_CASE</code>
* [Prefer COND #( ) Expression over IF/ELSEIF/ELSE](/rules/pref-cond) — <code>#EC PREF_COND</code>
* [Prefer SWITCH #( ) Expression over CASE Statement](/rules/pref-switch) — <code>#EC PREF_SWITCH</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_PREF_MERGE_IFS`
* **ABAP Implementation:** [/skyl/cl_pref_merge_ifs.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_pref_merge_ifs.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 892)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L892)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_PREF_MERGE_IFS&title=%5BBug%5D%3A%20Issue%20in%20pref-merge-ifs)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20pref-merge-ifs)**
