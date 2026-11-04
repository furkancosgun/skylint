---
title: "Replace Single-Branch CASE Statements with IF Conditions"
description: "Detect CASE statements with only one WHEN branch and convert them into direct IF conditions in ABAP Cloud."
keywords: "no-single-when, CASE statement, IF condition, Clean ABAP, SAP ATC"
category: "anti-patterns"
ruleId: "no-single-when"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L948"
---

# Replace Single-Branch CASE Statements with IF Conditions

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Anti-Patterns & Bad Practices" />
  <Badge type="danger" text="#EC NO_SINGLE_WHEN" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L948" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Avoid CASE statements with only one WHEN branch.

> **ATC Finding Message:** `CASE statement has <= 1 WHEN branch; prefer IF`

## Rationale

A CASE construct signals to readers that a variable is matched against multiple mutually exclusive values, so a CASE with only one WHEN branch creates false complexity and unnecessary indentation. Clean ABAP rules recommend using IF for binary or single-value evaluations, which express the conditional logic directly and clearly. In ABAP Cloud and SAP S/4HANA codebases, reserving CASE for three or more alternatives keeps decision tables focused and simplifies subsequent maintenance. Suppress valid exceptions with #EC NO_SINGLE_WHEN.

### Non-Compliant

```abap
CASE lv_order_status.
  WHEN 'C'.
    close_sales_order( ).
ENDCASE.
```

### Compliant

```abap
IF lv_order_status = 'C'.
  close_sales_order( ).
ENDIF.
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC NO_SINGLE_WHEN

" SAP CI_ prefix format:
... "#EC CI_NO_SINGLE_WHEN
```

### Detection Details

The check scans all CASE structures within executable procedures and counts non-OTHERS WHEN branches:

- Any CASE statement containing zero WHEN branches or exactly one WHEN branch (even if accompanied by a WHEN OTHERS branch) is flagged with finding code `NO_SGL_WHN`.
- CASE blocks inside type or class definitions are skipped.
- When multiple alternatives exist (two or more WHEN branches), the statement is considered a genuine decision table and passes.

Suppress individual occurrences using the pseudo-comment `"#EC NO_SINGLE_WHEN`.


## Related Rules

* [Avoid Duplicate Conditions in Branching Statements and Logical Operators](/rules/no-dup-cond) — <code>#EC NO_DUP_COND</code>
* [Prefer CASE over Multiple IF / ELSEIF on the Same Variable](/rules/pref-case) — <code>#EC PREF_CASE</code>
* [Convert Pure CASE Mappings into SWITCH Expressions](/rules/pref-switch) — <code>#EC PREF_SWITCH</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_NO_SINGLE_WHEN`
* **ABAP Implementation:** [/skyl/cl_no_single_when.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_no_single_when.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 948)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L948)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_NO_SINGLE_WHEN&title=%5BBug%5D%3A%20Issue%20in%20no-single-when)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20no-single-when)**
