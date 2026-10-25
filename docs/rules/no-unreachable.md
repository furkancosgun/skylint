---
title: "Avoid Dead / Unreachable Code"
description: "Avoid Dead / Unreachable Code - Clean ABAP guidelines, modern SAP syntax rules, and automated ATC code inspection for SAP S/4HANA and ABAP Cloud."
keywords: "Clean ABAP, SAP ATC Check, ABAP Cloud, S/4HANA Readiness, no-unreachable, anti-patterns"
---

# Avoid Dead / Unreachable Code

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Anti-Patterns & Bad Practices" />
  <Badge type="warning" text="QuickFix Ready" />
  <Badge type="danger" text="#EC NO_UNREACHABLE" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Detect unreachable code after jump or exit statements.

> **ATC Finding Message:** `Statement is unreachable`

## Rationale

Statements after an unconditional RETURN, RAISE EXCEPTION, or EXIT can never execute and often remain from debugging or an earlier design. They mislead maintainers and inflate apparent method size and coverage. Remove the statements or move them before the terminating statement if they are still needed.

### Non-Compliant

```abap
RETURN.
lv_count = lv_count + 1.
```

### Compliant

```abap
lv_count = lv_count + 1.
RETURN.
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
... "#EC NO_UNREACHABLE

" SAP CI_ prefix format:
... "#EC CI_NO_UNREACHABLE
```

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_NO_UNREACHABLE`
* **Implementation File:** [zcl_skylint_no_unreachable.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_no_unreachable.clas.abap)
