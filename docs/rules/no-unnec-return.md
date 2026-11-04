---
title: "Omit Redundant RETURN Statement at the End of Routines"
description: "Eliminate useless RETURN statements at routine ends in ABAP code to maintain clean control flow with automated quickfixes."
keywords: "no-unnec-return, Clean ABAP, ABAP Cloud, RETURN statement, control flow, SAP ATC"
category: "anti-patterns"
ruleId: "no-unnec-return"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L3169"
---

# Omit Redundant RETURN Statement at the End of Routines

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Anti-Patterns & Bad Practices" />
  <Badge type="warning" text="QuickFix Ready" />
  <Badge type="danger" text="#EC NO_UNNEC_RETURN" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L3169" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Omit unnecessary RETURN at end of routine.

> **ATC Finding Message:** `Omit optional RETURN at end of routine; routines return automatically`

## Rationale

A RETURN statement placed immediately before the closing ENDMETHOD, ENDFORM, or ENDFUNCTION statement is completely superfluous because control flow returns automatically to the caller when reaching the routine boundary. Leaving redundant trailing returns adds visual noise, misleads reviewers into suspecting early exit logic or missing downstream code, and violates Clean ABAP simplicity principles. The ATC check flags trailing RETURN statements with NO_UNN_RET and provides the REMOVE_RET quickfix to safely delete them.

### Non-Compliant

```abap
METHOD calculate_tax.
  DATA lv_tax TYPE decfloat34.
  lv_tax = iv_net_amount * '0.19'.
  RETURN.
ENDMETHOD.
```

### Compliant

```abap
METHOD calculate_tax.
  DATA lv_tax TYPE decfloat34.
  lv_tax = iv_net_amount * '0.19'.
ENDMETHOD.
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
... "#EC NO_UNNEC_RETURN

" SAP CI_ prefix format:
... "#EC CI_NO_UNNEC_RETURN
```

## Detection and Quickfix Details

The check evaluates executable statements in procedures. If a `RETURN` keyword is detected at the penultimate position directly preceding the closing routine delimiter (`ENDMETHOD`, `ENDFORM`, `ENDFUNCTION`), finding code `NO_UNN_RET` is reported.

The automated `REMOVE_RET` quickfix deletes the statement cleanly without affecting routine execution.

### Valid Return Usage
Early `RETURN` statements used as guard clauses to exit a routine upon invalid preconditions or edge cases remain valid and are not flagged by this check.

### Suppression
Suppress with pseudo comment `"#EC NO_UNNEC_RETURN`.


## Related Rules

* [Capture and Consume Return Values of Functional Method Calls](/rules/no-ignored-return) — <code>#EC NO_IGNORED_RETURN</code>
* [Use RETURN Instead of EXIT Outside Loops](/rules/pref-return) — <code>#EC PREF_RETURN</code>
* [Omit Redundant EXPORTING Keyword in Method Invocations](/rules/no-call-exporting) — <code>#EC NO_CALL_EXPORTING</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_NO_UNNEC_RETURN`
* **ABAP Implementation:** [/skyl/cl_no_unnec_return.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_no_unnec_return.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 3169)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L3169)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_NO_UNNEC_RETURN&title=%5BBug%5D%3A%20Issue%20in%20no-unnec-return)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20no-unnec-return)**
