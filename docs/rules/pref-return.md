---
title: "Use RETURN Instead of EXIT Outside Loops"
description: "Report EXIT statements that leave a procedure instead of a loop and offer a RETURN quickfix for explicit control flow."
keywords: "pref-return, EXIT, RETURN, loop control, Clean ABAP"
category: "clean-abap"
ruleId: "pref-return"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L738"
---

# Use RETURN Instead of EXIT Outside Loops

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="warning" text="QuickFix Ready" />
  <Badge type="danger" text="#EC PREF_RETURN" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L738" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Prefer RETURN over EXIT outside loop constructs.

> **ATC Finding Message:** `Use RETURN instead of EXIT when leaving a procedure`

## Rationale

EXIT is overloaded: inside a loop it terminates the iteration, outside a loop it leaves the whole procedure, and from inside a loop it even leaves the procedure as well. That context sensitivity makes EXIT easy to misjudge when surrounding code moves. The check tracks loop nesting across LOOP, DO, WHILE and row-by-row SELECT, reports PREF_RET only for an EXIT outside every loop and offers the EXIT2RET quickfix that keeps the indentation of the original statement.

### Non-Compliant

```abap
IF lv_order_is_locked = abap_true.
  EXIT.
ENDIF.
process_order( lv_order_id ).
```

### Compliant

```abap
IF lv_order_is_locked = abap_true.
  RETURN.
ENDIF.
process_order( lv_order_id ).
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
... "#EC PREF_RETURN

" SAP CI_ prefix format:
... "#EC CI_PREF_RETURN
```

## Loop Detection

`EXIT` is treated as loop control while inside `LOOP`, `DO`, `WHILE` or a row-by-row `SELECT`; a `SELECT SINGLE`, `SELECT ... INTO TABLE` or `SELECT ... APPENDING TABLE` does not open a loop. Only an `EXIT` outside that nesting is reported as `PREF_RET`. The `EXIT2RET` quickfix is created for a standalone `EXIT.` statement; an `EXIT` with an addition is reported without a quickfix.


## Related Rules

* [Capture and Consume Return Values of Functional Method Calls](/rules/no-ignored-return) — <code>#EC NO_IGNORED_RETURN</code>
* [Omit Redundant RETURN Statement at the End of Routines](/rules/no-unnec-return) — <code>#EC NO_UNNEC_RETURN</code>
* [Prefer Early Return and CONTINUE Guard Clauses over Nesting](/rules/pref-early-ret) — <code>#EC PREF_GUARD_METHOD</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_PREF_RETURN`
* **ABAP Implementation:** [/skyl/cl_pref_return.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_pref_return.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 738)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L738)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_PREF_RETURN&title=%5BBug%5D%3A%20Issue%20in%20pref-return)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20pref-return)**
