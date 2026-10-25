---
title: "Remove redundant parentheses"
description: "Remove redundant parentheses - Clean ABAP guidelines, modern SAP syntax rules, and automated ATC code inspection for SAP S/4HANA and ABAP Cloud."
keywords: "Clean ABAP, SAP ATC Check, ABAP Cloud, S/4HANA Readiness, no-many-parens, anti-patterns"
---

# Remove redundant parentheses

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Anti-Patterns & Bad Practices" />
  <Badge type="warning" text="QuickFix Ready" />
  <Badge type="danger" text="#EC NO_MANY_PARENS" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Remove redundant parentheses.

> **ATC Finding Message:** `Parentheses wrap a complete expression and can be removed`

## Rationale

Parentheses that wrap an entire condition or arithmetic expression do not change evaluation order but add visual noise. They often remain after refactoring and make expressions look more complex than they are. Remove redundant outer parentheses and keep only those needed for precedence.

### Non-Compliant

```abap
IF ( lv_status = 'A' ).
  process_a( ).
ENDIF.
```

### Compliant

```abap
IF lv_status = 'A'.
  process_a( ).
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
... "#EC NO_MANY_PARENS

" SAP CI_ prefix format:
... "#EC CI_NO_MANY_PARENS
```

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_NO_MANY_PARENS`
* **Implementation File:** [zcl_skylint_no_many_parens.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_no_many_parens.clas.abap)
