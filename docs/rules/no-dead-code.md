---
title: "Avoid Dead Code with Constant Conditions"
description: "Avoid Dead Code with Constant Conditions - Clean ABAP guidelines, modern SAP syntax rules, and automated ATC code inspection for SAP S/4HANA and ABAP Cloud."
keywords: "Clean ABAP, SAP ATC Check, ABAP Cloud, S/4HANA Readiness, no-dead-code, anti-patterns"
category: "anti-patterns"
ruleId: "no-dead-code"
---

# Avoid Dead Code with Constant Conditions

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Anti-Patterns & Bad Practices" />
  <Badge type="warning" text="QuickFix Ready" />
  <Badge type="danger" text="#EC NO_DEAD_CODE" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Detect Dead Code with Constant Condition.

> **ATC Finding Message:** `Condition is always false, creating dead code`

## Rationale

A condition that is always false, such as 1 = 2 or abap_false, makes the branch impossible to reach. Dead branches hide unfinished logic and can contain declarations that confuse scope analysis. Remove the branch or replace the constant with the real runtime condition.

### Non-Compliant

```abap
IF 1 = 2.
  process( ).
ENDIF.
```

### Compliant

```abap
IF is_enabled( ).
  process( ).
ENDIF.
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
... "#EC NO_DEAD_CODE

" SAP CI_ prefix format:
... "#EC CI_NO_DEAD_CODE
```

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_NO_DEAD_CODE`
* **Implementation File:** [zcl_skylint_no_dead_code.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_no_dead_code.clas.abap)
