---
title: "Prefer IS [NOT] INITIAL over lines( ) or Literal Comparisons"
description: "Prefer IS [NOT] INITIAL over lines( ) or Literal Comparisons - Clean ABAP guidelines, modern SAP syntax rules, and automated ATC code inspection for SAP S/4HANA and ABAP Cloud."
keywords: "Clean ABAP, SAP ATC Check, ABAP Cloud, S/4HANA Readiness, pref-is-initial, clean-abap"
category: "clean-abap"
ruleId: "pref-is-initial"
---

# Prefer IS [NOT] INITIAL over lines( ) or Literal Comparisons

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="warning" text="QuickFix Ready" />
  <Badge type="danger" text="#EC PREF_IS_INITIAL" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Prefer IS [NOT] INITIAL over lines( ) or empty literals.

> **ATC Finding Message:** `Use IS [NOT] INITIAL instead of lines( ) or empty literal comparison`

## Rationale

Comparing lines( ) to zero or a string to an empty literal asks an indirect question. IS INITIAL states emptiness directly and works for tables, strings, structures, and elementary values. It also avoids counting overhead and literal edge cases.

### Non-Compliant

```abap
IF lines( lt_items ) > 0.
  process( ).
ENDIF.
```

### Compliant

```abap
IF lt_items IS NOT INITIAL.
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
... "#EC PREF_IS_INITIAL

" SAP CI_ prefix format:
... "#EC CI_PREF_IS_INITIAL
```

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_PREF_IS_INITIAL`
* **Implementation File:** [zcl_skylint_pref_is_initial.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_pref_is_initial.clas.abap)
