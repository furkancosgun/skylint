---
title: "Prefer Early Return and CONTINUE Guard Clauses over Nesting"
description: "Flatten nested ABAP methods and loops with early RETURN and CONTINUE guard clauses, and remove ELSE branches that follow a terminating statement."
keywords: "pref-early-ret, guard clause, early return, Clean ABAP, SAP ATC"
category: "clean-abap"
ruleId: "pref-early-ret"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L2635"
---

# Prefer Early Return and CONTINUE Guard Clauses over Nesting

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="warning" text="QuickFix Ready" />
  <Badge type="danger" text="#EC PREF_GUARD_METHOD" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L2635" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Prefer early return or continue over nested IF blocks.

> **ATC Finding Messages:**
> - `Invert IF condition and use RETURN to reduce nesting in method`
> - `Invert IF condition and use CONTINUE to reduce nesting in loop`
> - `Remove ELSE after a terminating statement`

## Rationale

Wrapping the whole method body in IF is_valid( ) pushes the happy path one indentation level to the right and grows with every additional precondition. A guard clause rejects invalid input at the top, so the remaining code stays flat, has a single indentation level, and each precondition can be read and tested in isolation. The same reasoning applies inside loops, where an inverted IF with CONTINUE removes nesting, and to ELSE branches that follow a RETURN or RAISE and can never be reached in sequence.

### Non-Compliant

```abap
METHOD post_goods_issue.
  IF is_posting_allowed( ).
    create_material_document( ).
    update_stock_balance( ).
  ENDIF.
ENDMETHOD.
```

### Compliant

```abap
METHOD post_goods_issue.
  IF is_posting_allowed( ) = abap_false.
    RETURN.
  ENDIF.
  create_material_document( ).
  update_stock_balance( ).
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
| `CHECK_METHOD_RETURN` | `Boolean` | <code>true</code> | Report an IF that wraps the entire method body so it can be inverted into a RETURN guard clause. Enabled by default. |
| `CHECK_LOOP_CONTINUE` | `Boolean` | <code>true</code> | Report an IF that wraps the complete body of LOOP, DO or WHILE so it can be inverted into a CONTINUE guard clause. Enabled by default. |
| `REPORT_ELSEIF` | `Boolean` | <code>false</code> | Also report ELSEIF branches that directly follow a terminating statement such as RETURN or RAISE. Disabled by default because not every chain flattens safely. |

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC PREF_GUARD_METHOD

" SAP CI_ prefix format:
... "#EC CI_PREF_GUARD_METHOD
```

### Finding codes

| Code | Trigger | Suggestion |
| --- | --- | --- |
| `PREF_GRDMT` | first executable method statement is an `IF` wrapping the whole body | invert the condition and `RETURN` |
| `PREF_GRDLP` | an `IF` wraps the complete body of `LOOP`, `DO` or `WHILE` | invert the condition and `CONTINUE` |
| `NO_ELSEEXT` | `ELSE` or `ELSEIF` directly after `RETURN`, `EXIT`, `CONTINUE`, `LEAVE` or `RAISE` | drop the redundant branch |

`CHECK_METHOD_RETURN` and `CHECK_LOOP_CONTINUE` toggle the two guard-clause checks; `REPORT_ELSEIF` additionally reports `ELSEIF` after a terminator and is off by default. The `REM_ELSE` QuickFix replaces `ELSE` with `ENDIF` and deletes the original `ENDIF`, so nested `IF` blocks inside the branch are preserved. Pseudo-comments: `"#EC PREF_GUARD_METHOD`, `"#EC PREF_GUARD_LOOP`, `"#EC PREF_NO_ELSE_EXIT`.


## Related Rules

* [Use RETURN Instead of EXIT Outside Loops](/rules/pref-return) — <code>#EC PREF_RETURN</code>
* [Capture and Consume Return Values of Functional Method Calls](/rules/no-ignored-return) — <code>#EC NO_IGNORED_RETURN</code>
* [Omit Redundant RETURN Statement at the End of Routines](/rules/no-unnec-return) — <code>#EC NO_UNNEC_RETURN</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_PREF_EARLY_RET`
* **ABAP Implementation:** [/skyl/cl_pref_early_ret.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_pref_early_ret.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 2635)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L2635)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_PREF_EARLY_RET&title=%5BBug%5D%3A%20Issue%20in%20pref-early-ret)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20pref-early-ret)**
