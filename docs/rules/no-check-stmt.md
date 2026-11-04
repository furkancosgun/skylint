---
title: "Avoid CHECK Statements"
description: "Avoid CHECK Statements - Clean ABAP guidelines, modern SAP syntax rules, and automated ATC code inspection for SAP S/4HANA and ABAP Cloud."
keywords: "Clean ABAP, SAP ATC Check, ABAP Cloud, S/4HANA Readiness, no-check-stmt, anti-patterns"
category: "anti-patterns"
ruleId: "no-check-stmt"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L766"
---

# Avoid CHECK Statements

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Anti-Patterns & Bad Practices" />
  <Badge type="warning" text="QuickFix Ready" />
  <Badge type="danger" text="#EC NO_CHECK_IN_LOOP" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L766" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Avoid CHECK statements; prefer IF with RETURN or CONTINUE.

> **ATC Finding Messages:**
> - `Avoid CHECK inside loop; use IF ... CONTINUE instead`
> - `Avoid CHECK outside loop; use IF ... RETURN instead`

## Rationale

CHECK behaves like CONTINUE inside a loop but like RETURN outside a loop, so moving the statement between contexts silently changes control flow. That dual meaning makes refactoring and reviews hazardous. Replace it with an explicit IF ... CONTINUE or IF ... RETURN that states the intended behavior.

### Non-Compliant

```abap
LOOP AT lt_orders INTO ls_order.
  CHECK ls_order-status = 'OPEN'.
  process_order( ls_order ).
ENDLOOP.
```

### Compliant

```abap
LOOP AT lt_orders INTO ls_order.
  IF ls_order-status <> 'OPEN'.
    CONTINUE.
  ENDIF.
  process_order( ls_order ).
ENDLOOP.
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
| `CHECK_IN_LOOP` | `Boolean` | <code>true</code> | Detect CHECK inside loops and suggest IF NOT ... CONTINUE guard clause |
| `CHECK_OUTSIDE_LOOP` | `Boolean` | <code>true</code> | Detect CHECK outside loops and suggest IF NOT ... RETURN guard clause |

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC NO_CHECK_IN_LOOP

" SAP CI_ prefix format:
... "#EC CI_NO_CHECK_IN_LOOP
```


## Related Rules

* [Avoid CASE with a Single WHEN Branch](/rules/no-single-when) — <code>#EC NO_SINGLE_WHEN</code>
* [Avoid Comparing to abap_true / abap_false](/rules/no-bool-compare) — <code>#EC NO_BOOL_COMPARE</code>
* [Avoid Yoda Conditions](/rules/no-yoda-cond) — <code>#EC NO_YODA_COND</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_NO_CHECK_STMT`
* **ABAP Implementation:** [/skyl/cl_no_check_stmt.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_no_check_stmt.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 766)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L766)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_NO_CHECK_STMT&title=%5BBug%5D%3A%20Issue%20in%20no-check-stmt)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20no-check-stmt)**
