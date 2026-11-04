---
title: "Avoid Comparisons and Arithmetic with Identical Operands"
description: "Detect ABAP conditions and arithmetic where both operands resolve to the same symbol, a classic copy-paste defect that makes conditions meaningless."
keywords: "ABAP self comparison, identical operands check, Clean ABAP anti-pattern, SAP ATC check, copy paste bug ABAP"
category: "anti-patterns"
ruleId: "no-self-compare"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L4140"
---

# Avoid Comparisons and Arithmetic with Identical Operands

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Anti-Patterns & Bad Practices" />
  <Badge type="danger" text="#EC NO_SELF_COMPARE" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L4140" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Detect comparisons and arithmetic with identical operands.

> **ATC Finding Messages:**
> - `Both sides of the comparison resolve to the same symbol`
> - `Arithmetic operation uses the same symbol on both sides`

## Rationale

Comparing an expression with itself (`lv_status = lv_status`) always yields the same result, so the condition or assignment is meaningless and usually hides a copy-paste mistake. The same applies to arithmetic that always collapses to a constant (`lv_diff = lv_x - lv_x`). Operands are resolved through compiler symbols, so shadowed names and textually equal but different symbols are not confused. Statements with an AND/OR chain are left to no-dup-cond to avoid double findings.

### Non-Compliant

```abap
IF lv_status = lv_status.
  lv_count = lv_count + 1.
ENDIF.
lv_diff = lv_x - lv_x.
```

### Compliant

```abap
IF lv_status = c_status-done.
  lv_count = lv_count + 1.
ENDIF.
lv_diff = lv_x - lv_y.
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC NO_SELF_COMPARE

" SAP CI_ prefix format:
... "#EC CI_NO_SELF_COMPARE
```


## Related Rules

* [Avoid Dead Code with Constant Conditions](/rules/no-dead-code) — <code>#EC NO_DEAD_CODE</code>
* [Avoid Duplicate Branch Conditions](/rules/no-dup-cond) — <code>#EC NO_DUP_COND</code>
* [Remove Redundant Self-Assignments and Identity Moves](/rules/no-redun-assign) — <code>#EC NO_IDENTICAL_MOVE</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_NO_SELF_COMPARE`
* **ABAP Implementation:** [/skyl/cl_no_self_compare.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_no_self_compare.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 4140)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L4140)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_NO_SELF_COMPARE&title=%5BBug%5D%3A%20Issue%20in%20no-self-compare)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20no-self-compare)**
