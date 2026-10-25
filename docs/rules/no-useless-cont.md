---
title: "Avoid Redundant CONTINUE at End of Loop"
description: "Avoid Redundant CONTINUE at End of Loop - Clean ABAP guidelines, modern SAP syntax rules, and automated ATC code inspection for SAP S/4HANA and ABAP Cloud."
keywords: "Clean ABAP, SAP ATC Check, ABAP Cloud, S/4HANA Readiness, no-useless-cont, clean-abap"
category: "clean-abap"
ruleId: "no-useless-cont"
---

# Avoid Redundant CONTINUE at End of Loop

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="warning" text="QuickFix Ready" />
  <Badge type="danger" text="#EC NO_USELESS_CONT" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Avoid Redundant CONTINUE at End of Loop.

> **ATC Finding Message:** `CONTINUE immediately before loop end is redundant`

## Rationale

A CONTINUE statement located immediately before ENDLOOP, ENDWHILE, or ENDDO has zero effect because loop execution naturally cycles at the end of the block. Remove redundant trailing CONTINUE statements to keep loop bodies concise and avoid misleading code reviewers into expecting remaining logic.

### Non-Compliant

```abap
LOOP AT lt_items ASSIGNING <ls_item>.
  do_work( <ls_item> ).
  CONTINUE.
ENDLOOP.
```

### Compliant

```abap
LOOP AT lt_items ASSIGNING <ls_item>.
  do_work( <ls_item> ).
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

* [Avoid Loops That Execute At Most Once](/rules/no-single-iter) — <code>#EC NO_SINGLE_ITER</code>
* [Avoid Dead Code with Constant Conditions](/rules/no-dead-code) — <code>#EC NO_DEAD_CODE</code>
* [Avoid Dead / Unreachable Code](/rules/no-unreachable) — <code>#EC NO_UNREACHABLE</code>

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_NO_USELESS_CONT`
* **Implementation File:** [zcl_skylint_no_useless_cont.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_no_useless_cont.clas.abap)
