---
title: "Prefer CASE over Multiple IF / ELSEIF on the Same Variable"
description: "Prefer CASE over Multiple IF / ELSEIF on the Same Variable - Clean ABAP guidelines, modern SAP syntax rules, and automated ATC code inspection for SAP S/4HANA and ABAP Cloud."
keywords: "Clean ABAP, SAP ATC Check, ABAP Cloud, S/4HANA Readiness, pref-case, clean-abap"
category: "clean-abap"
ruleId: "pref-case"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L2644"
---

# Prefer CASE over Multiple IF / ELSEIF on the Same Variable

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="warning" text="QuickFix Ready" />
  <Badge type="danger" text="#EC PREF_CASE" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L2644" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Use CASE instead of IF when checking multiple values.

> **ATC Finding Message:** `Multiple ELSEIF branches check the same variable; use CASE instead`

## Rationale

A chain of ELSEIF statements that compares the same variable to different values is harder to scan than a CASE statement. CASE groups all alternatives under one subject and makes a missing OTHERS branch visible. Use CASE for multi-value dispatch on a single expression.

### Non-Compliant

```abap
IF lv_payment_method = 'CARD'.
  process_card( ).
ELSEIF lv_payment_method = 'CASH'.
  process_cash( ).
ELSEIF lv_payment_method = 'TRANSFER'.
  process_transfer( ).
ENDIF.
```

### Compliant

```abap
CASE lv_payment_method.
  WHEN 'CARD'.
    process_card( ).
  WHEN 'CASH'.
    process_cash( ).
  WHEN 'TRANSFER'.
    process_transfer( ).
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
| `MIN_BRANCHES` | `Integer` | <code>3</code> | Minimum number of ELSEIF branches on the same variable before suggesting CASE (default: 2) |

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC PREF_CASE

" SAP CI_ prefix format:
... "#EC CI_PREF_CASE
```


## Related Rules

* [Prefer COND #( ) Expression over IF/ELSEIF/ELSE](/rules/pref-cond) — <code>#EC PREF_COND</code>
* [Prefer SWITCH #( ) Expression over CASE Statement](/rules/pref-switch) — <code>#EC PREF_SWITCH</code>
* [Avoid CASE with a Single WHEN Branch](/rules/no-single-when) — <code>#EC NO_SINGLE_WHEN</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_PREF_CASE`
* **ABAP Implementation:** [/skyl/cl_pref_case.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_pref_case.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 2644)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L2644)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_PREF_CASE&title=%5BBug%5D%3A%20Issue%20in%20pref-case)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20pref-case)**
