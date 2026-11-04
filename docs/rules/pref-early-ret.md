---
title: "Prefer Early Return to Reduce Nesting (Guard Clauses)"
description: "Prefer Early Return to Reduce Nesting (Guard Clauses) - Clean ABAP guidelines, modern SAP syntax rules, and automated ATC code inspection for SAP S/4HANA and ABAP Cloud."
keywords: "Clean ABAP, SAP ATC Check, ABAP Cloud, S/4HANA Readiness, pref-early-ret, clean-abap"
category: "clean-abap"
ruleId: "pref-early-ret"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L2583"
---

# Prefer Early Return to Reduce Nesting (Guard Clauses)

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="warning" text="QuickFix Ready" />
  <Badge type="danger" text="#EC PREF_GUARD_METHOD" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L2583" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Prefer early return or continue over nested IF blocks.

> **ATC Finding Messages:**
> - `Invert IF condition and use RETURN to reduce nesting in method`
> - `Invert IF condition and use CONTINUE to reduce nesting in loop`
> - `Remove ELSE after a terminating statement`

## Rationale

Wrapping the whole method body in IF is_valid( ) creates unnecessary nesting and pushes the happy path to the right. Guard clauses reject invalid input at the top and leave the main logic flat and easy to read. Return early for preconditions and error cases instead of indenting the successful path.

### Non-Compliant

```abap
METHOD process_order.
  IF is_valid( ).
    execute_order( ).
    log_order( ).
  ENDIF.
ENDMETHOD.
```

### Compliant

```abap
METHOD process_order.
  IF NOT is_valid( ).
    RETURN.
  ENDIF.
  execute_order( ).
  log_order( ).
ENDMETHOD.
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
| `CHECK_METHOD_RETURN` | `Boolean` | <code>true</code> | Suggest early RETURN guard clause for top-level method validation IFs |
| `CHECK_LOOP_CONTINUE` | `Boolean` | <code>true</code> | Suggest early CONTINUE guard clause for loop item validation IFs |
| `REPORT_ELSEIF` | `Boolean` | <code>false</code> | Also report ELSEIF branches that follow a terminating statement (default: disabled) |

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC PREF_GUARD_METHOD

" SAP CI_ prefix format:
... "#EC CI_PREF_GUARD_METHOD
```


## Related Rules

* [Prefer RETURN over EXIT in Methods](/rules/pref-return) — <code>#EC PREF_RETURN</code>
* [Do Not Ignore Return Value of Functional Methods](/rules/no-ignored-return) — <code>#EC NO_IGNORED_RETURN</code>
* [Omit Unnecessary RETURN Statement](/rules/no-unnec-return) — <code>#EC NO_UNNEC_RETURN</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_PREF_EARLY_RET`
* **ABAP Implementation:** [/skyl/cl_pref_early_ret.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_pref_early_ret.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 2583)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L2583)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_PREF_EARLY_RET&title=%5BBug%5D%3A%20Issue%20in%20pref-early-ret)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20pref-early-ret)**
