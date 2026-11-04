---
title: "Remove CONTINUE Immediately Before a Loop End"
description: "Detect CONTINUE statements directly before ENDLOOP, ENDWHILE or ENDDO and remove the dead loop control with an ATC quickfix."
keywords: "no-useless-cont, CONTINUE, ENDLOOP, dead code, Clean ABAP"
category: "clean-abap"
ruleId: "no-useless-cont"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L114"
---

# Remove CONTINUE Immediately Before a Loop End

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="warning" text="QuickFix Ready" />
  <Badge type="danger" text="#EC NO_USELESS_CONT" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L114" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Avoid Redundant CONTINUE at End of Loop.

> **ATC Finding Message:** `CONTINUE immediately before loop end is redundant`

## Rationale

A CONTINUE that directly precedes ENDLOOP, ENDWHILE or ENDDO never changes behaviour, because the loop would cycle at that point anyway. Leaving it in the code adds a dead statement that suggests additional logic was removed or is still missing, and reviewers spend time proving that nothing is skipped. The check reports NO_USE_CNT and the RMCONT quickfix deletes the statement, keeping loop bodies minimal and honest. Early CONTINUE statements that guard further processing remain untouched.

### Non-Compliant

```abap
LOOP AT lt_order_items ASSIGNING <ls_order_item>.
  IF <ls_order_item>-quantity = 0.
    CONTINUE.
  ENDIF.
  accumulate_net_value( <ls_order_item> ).
  CONTINUE.
ENDLOOP.
```

### Compliant

```abap
LOOP AT lt_order_items ASSIGNING <ls_order_item>.
  IF <ls_order_item>-quantity = 0.
    CONTINUE.
  ENDIF.
  accumulate_net_value( <ls_order_item> ).
ENDLOOP.
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
... "#EC NO_USELESS_CONT

" SAP CI_ prefix format:
... "#EC CI_NO_USELESS_CONT
```


## Related Rules

* [Avoid Loops That Execute At Most Once Due to Unconditional Exit](/rules/no-single-iter) — <code>#EC NO_SINGLE_ITER</code>
* [Eliminate Unreachable Dead Code Caused by Constant False Conditions](/rules/no-dead-code) — <code>#EC NO_DEAD_CODE</code>
* [Avoid Unreachable Statements Following Unconditional Exit or Jump Operations](/rules/no-unreachable) — <code>#EC NO_UNREACHABLE</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_NO_USELESS_CONT`
* **ABAP Implementation:** [/skyl/cl_no_useless_cont.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_no_useless_cont.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 114)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L114)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_NO_USELESS_CONT&title=%5BBug%5D%3A%20Issue%20in%20no-useless-cont)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20no-useless-cont)**
