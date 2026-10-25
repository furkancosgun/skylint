---
title: "Prefer FINAL( ) over DATA( ) when the variable is never written again"
description: "Prefer FINAL( ) over DATA( ) when the variable is never written again - Clean ABAP guidelines, modern SAP syntax rules, and automated ATC code inspection for SAP S/4HANA and ABAP Cloud."
keywords: "Clean ABAP, SAP ATC Check, ABAP Cloud, S/4HANA Readiness, pref-final-data, clean-abap"
category: "clean-abap"
ruleId: "pref-final-data"
---

# Prefer FINAL( ) over DATA( ) when the variable is never written again

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="warning" text="QuickFix Ready" />
  <Badge type="danger" text="#EC PREF_FINAL_DATA" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Declare inline variables as FINAL when never written again.

> **ATC Finding Message:** `Inline variable is never written again; declare it with FINAL( )`

## Rationale

An inline variable that is assigned once and never changed should be declared FINAL so the compiler enforces immutability. This prevents accidental later writes and documents that the value is a constant for the rest of the method. Use FINAL( ) for single-assignment locals.

### Non-Compliant

```abap
DATA(lv_count) = lines( lt_items ).
process( lv_count ).
```

### Compliant

```abap
FINAL(lv_count) = lines( lt_items ).
process( lv_count ).
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
... "#EC PREF_FINAL_DATA

" SAP CI_ prefix format:
... "#EC CI_PREF_FINAL_DATA
```


## Related Rules

* [Enforce Local Variable and Field-Symbol Naming Conventions](/rules/pref-naming-vars) — <code>#EC PREF_NAMING_VARS</code>
* [Avoid Single-Letter Variable Names](/rules/no-single-letter) — <code>#EC NO_SINGLE_LETTER</code>
* [Avoid Chained Declarations (DATA:, CONSTANTS:, TYPES:)](/rules/no-chained-decl) — <code>#EC NO_CHAINED_DECL</code>

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_PREF_FINAL_DATA`
* **Implementation File:** [zcl_skylint_pref_final_data.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_pref_final_data.clas.abap)
