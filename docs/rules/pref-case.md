---
title: "Prefer CASE over Multiple IF / ELSEIF on the Same Variable"
description: "Convert IF/ELSEIF chains that compare one variable against many values into a readable CASE statement with an explicit WHEN OTHERS branch."
keywords: "pref-case, CASE statement, ELSEIF chain, Clean ABAP, SAP ATC"
category: "clean-abap"
ruleId: "pref-case"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L2697"
---

# Prefer CASE over Multiple IF / ELSEIF on the Same Variable

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="warning" text="QuickFix Ready" />
  <Badge type="danger" text="#EC PREF_CASE" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L2697" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Use CASE instead of IF when checking multiple values.

> **ATC Finding Message:** `Multiple ELSEIF branches check the same variable; use CASE instead`

## Rationale

A chain of ELSEIF statements that compares the same variable against different constants is harder to scan than a CASE statement: the subject is repeated in every branch and a missing alternative is easy to overlook. CASE names the subject once, groups all alternatives under it, and makes a deliberate WHEN OTHERS branch visible in the code review. The check counts the branches against a configurable threshold, so simple two-way decisions stay as IF and only real multi-value dispatches are converted.

### Non-Compliant

```abap
IF lv_shipping_type = 'STANDARD'.
  schedule_standard_delivery( ).
ELSEIF lv_shipping_type = 'EXPRESS'.
  schedule_express_delivery( ).
ELSEIF lv_shipping_type = 'PICKUP'.
  confirm_store_pickup( ).
ENDIF.
```

### Compliant

```abap
CASE lv_shipping_type.
  WHEN 'STANDARD'.
    schedule_standard_delivery( ).
  WHEN 'EXPRESS'.
    schedule_express_delivery( ).
  WHEN 'PICKUP'.
    confirm_store_pickup( ).
  WHEN OTHERS.
    RAISE EXCEPTION NEW zcx_invalid_shipping_type( ).
ENDCASE.
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
| `MIN_BRANCHES` | `Integer` | <code>3</code> | Number of comparisons on the same variable required before CASE is suggested. Default 3 means one IF plus two ELSEIF branches; set it to 2 for a stricter dispatch style. |

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC PREF_CASE

" SAP CI_ prefix format:
... "#EC CI_PREF_CASE
```

### Threshold and detection

`MIN_BRANCHES` counts the `IF` plus every `ELSEIF` that compares the same variable with `=` or `EQ`. With the default of `3`, two `ELSEIF` branches are required before `PREF_CASE` is raised, so a plain `IF/ELSE` is never reported. Chains that mix variables, or that use `AND`, `OR`, `BETWEEN`, `IN` or `IS` in the condition, are left alone because they are not a single-subject dispatch.

The `USE_CASE` QuickFix replaces the whole `IF/ELSEIF/ENDIF` range, converts `ELSE` to `WHEN OTHERS` and keeps the original indentation and nested statements. If the branches compare different fields, restructure the code manually instead of suppressing with `"#EC PREF_CASE`.


## Related Rules

* [Collapse Value-Mapping IF Chains into COND](/rules/pref-cond) — <code>#EC PREF_COND</code>
* [Convert Pure CASE Mappings into SWITCH Expressions](/rules/pref-switch) — <code>#EC PREF_SWITCH</code>
* [Replace Single-Branch CASE Statements with IF Conditions](/rules/no-single-when) — <code>#EC NO_SINGLE_WHEN</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_PREF_CASE`
* **ABAP Implementation:** [/skyl/cl_pref_case.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_pref_case.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 2697)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L2697)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_PREF_CASE&title=%5BBug%5D%3A%20Issue%20in%20pref-case)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20pref-case)**
