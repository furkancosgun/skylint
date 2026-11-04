---
title: "Convert Pure CASE Mappings into SWITCH Expressions"
description: "Replace CASE blocks whose WHEN branches only assign one variable with a compact SWITCH constructor expression."
keywords: "pref-switch, SWITCH, CASE WHEN, constructor expression, ABAP Cloud"
category: "clean-abap"
ruleId: "pref-switch"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L329"
---

# Convert Pure CASE Mappings into SWITCH Expressions

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="warning" text="QuickFix Ready" />
  <Badge type="danger" text="#EC PREF_SWITCH" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L329" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Prefer SWITCH #( ) expression over CASE statement.

> **ATC Finding Message:** `Prefer SWITCH #( ) constructor expression over CASE`

## Rationale

A CASE statement whose WHEN branches only assign the same variable is a lookup table disguised as control flow: the operand, the branches and the ENDCASE all add noise around one value. The check verifies that every branch holds exactly one assignment to the same target and reports PREF_SWTCH, then the USESWITCH quickfix rewrites the complete CASE..ENDCASE block into a SWITCH expression. The result assigns once, cannot fall through and can be passed directly to a method or constructor expression.

### Non-Compliant

```abap
CASE lv_delivery_status.
  WHEN 'O'.
    lv_status_text = 'Open'.
  WHEN 'S'.
    lv_status_text = 'Shipped'.
  WHEN OTHERS.
    lv_status_text = 'Unknown'.
ENDCASE.
```

### Compliant

```abap
lv_status_text = SWITCH string( lv_delivery_status
  WHEN 'O' THEN 'Open'
  WHEN 'S' THEN 'Shipped'
  ELSE 'Unknown' ).
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
| `REQUIRE_OTHERS` | `Boolean` | <code>false</code> | Only report CASE blocks that already contain a WHEN OTHERS branch. Enable when the SWITCH replacement must be total and unhandled states must stay visible. |

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC PREF_SWITCH

" SAP CI_ prefix format:
... "#EC CI_PREF_SWITCH
```

## When the Rule Fires

The CASE block must consist only of `WHEN` branches, each containing exactly one assignment to the same target variable, followed directly by `ENDCASE`. Branches with several statements, method calls or different targets keep the CASE statement, which remains the correct tool for statement sequences and side effects.

With `REQUIRE_OTHERS` enabled only blocks that already contain `WHEN OTHERS` are reported, so the migration cannot hide an unhandled state behind an implicit ELSE. The `USESWITCH` quickfix replaces the entire block, including the fallback.


## Related Rules

* [Prefer CASE over Multiple IF / ELSEIF on the Same Variable](/rules/pref-case) — <code>#EC PREF_CASE</code>
* [Collapse Value-Mapping IF Chains into COND](/rules/pref-cond) — <code>#EC PREF_COND</code>
* [Replace Single-Branch CASE Statements with IF Conditions](/rules/no-single-when) — <code>#EC NO_SINGLE_WHEN</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_PREF_SWITCH`
* **ABAP Implementation:** [/skyl/cl_pref_switch.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_pref_switch.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 329)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L329)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_PREF_SWITCH&title=%5BBug%5D%3A%20Issue%20in%20pref-switch)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20pref-switch)**
