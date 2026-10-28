---
title: "Require Fully Typed Variables and Parameters"
description: "Require Fully Typed Variables and Parameters - Clean ABAP guidelines, modern SAP syntax rules, and automated ATC code inspection for SAP S/4HANA and ABAP Cloud."
keywords: "Clean ABAP, SAP ATC Check, ABAP Cloud, S/4HANA Readiness, pref-full-typed, clean-abap"
category: "clean-abap"
ruleId: "pref-full-typed"
---

# Require Fully Typed Variables and Parameters

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="warning" text="QuickFix Ready" />
  <Badge type="danger" text="#EC PREF_FULL_TYPED" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Enforce fully typed constant declarations.

> **ATC Finding Message:** `Constant declaration should explicitly specify TYPE`

## Rationale

Untyped constants and data objects receive an implicit type whose length and value range are easy to misjudge. A later change to the literal can silently truncate data or alter comparisons. Declare explicit TYPE and LENGTH so the contract is visible to readers and checked by the compiler.

### Non-Compliant

```abap
CONSTANTS c_status VALUE 'A'.
```

### Compliant

```abap
CONSTANTS c_status TYPE c LENGTH 1 VALUE 'A'.
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
... "#EC PREF_FULL_TYPED

" SAP CI_ prefix format:
... "#EC CI_PREF_FULL_TYPED
```


## Related Rules

* [Eliminate Unused Local Variables and Symbols](/rules/no-unused-vars) — <code>#EC NO_UNUSED_VARS</code>
* [Avoid Hungarian Notation and Type Prefixes](/rules/no-hungarian) — <code>#EC NO_HUNGARIAN</code>
* [Enforce Local Variable and Field-Symbol Naming Conventions](/rules/pref-naming-vars) — <code>#EC PREF_NAMING_VARS</code>

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_PREF_FULL_TYPED`
* **Implementation File:** [zcl_skylint_pref_full_typed.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_pref_full_typed.clas.abap)
