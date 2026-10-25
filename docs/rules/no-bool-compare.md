---
title: "Avoid Comparing to abap_true / abap_false"
description: "Avoid Comparing to abap_true / abap_false - Clean ABAP guidelines, modern SAP syntax rules, and automated ATC code inspection for SAP S/4HANA and ABAP Cloud."
keywords: "Clean ABAP, SAP ATC Check, ABAP Cloud, S/4HANA Readiness, no-bool-compare, anti-patterns"
---

# Avoid Comparing to abap_true / abap_false

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Anti-Patterns & Bad Practices" />
  <Badge type="warning" text="QuickFix Ready" />
  <Badge type="danger" text="#EC NO_BOOL_COMPARE" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Avoid comparing boolean method calls to boolean literals.

> **ATC Finding Message:** `Avoid boolean comparison for method calls; call method directly`

## Rationale

A boolean expression already evaluates to true or false, so comparing it to abap_true is redundant. The comparison hides predicate intent and can mask a missing method call or an accidental assignment. Test the expression directly and use NOT when the negative case is needed.

### Non-Compliant

```abap
IF is_valid( ) = abap_false.
  RETURN.
ENDIF.
```

### Compliant

```abap
IF NOT is_valid( ).
  RETURN.
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
... "#EC NO_BOOL_COMPARE

" SAP CI_ prefix format:
... "#EC CI_NO_BOOL_COMPARE
```

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_NO_BOOL_COMPARE`
* **Implementation File:** [zcl_skylint_no_bool_compare.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_no_bool_compare.clas.abap)
