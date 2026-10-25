---
title: "Avoid Obsolete ! Escape Prefix in Parameter Names"
description: "Avoid Obsolete ! Escape Prefix in Parameter Names - Clean ABAP guidelines, modern SAP syntax rules, and automated ATC code inspection for SAP S/4HANA and ABAP Cloud."
keywords: "Clean ABAP, SAP ATC Check, ABAP Cloud, S/4HANA Readiness, no-param-escape, anti-patterns"
---

# Avoid Obsolete ! Escape Prefix in Parameter Names

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Anti-Patterns & Bad Practices" />
  <Badge type="warning" text="QuickFix Ready" />
  <Badge type="danger" text="#EC NO_PARAM_ESCAPE" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Avoid unnecessary parameter escape (!param).

> **ATC Finding Message:** `Escape params with ! only on keyword clash`

## Rationale

The ! escape prefix is legacy syntax used to force a parameter name to be treated literally. It adds noise to signatures and is unnecessary in modern ABAP, where parameter names are unambiguous. Remove the ! and use a clear parameter name instead.

### Non-Compliant

```abap
METHODS process
  IMPORTING !iv_data TYPE string.
```

### Compliant

```abap
METHODS process
  IMPORTING iv_data TYPE string.
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
... "#EC NO_PARAM_ESCAPE

" SAP CI_ prefix format:
... "#EC CI_NO_PARAM_ESCAPE
```

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_NO_PARAM_ESCAPE`
* **Implementation File:** [zcl_skylint_no_param_escape.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_no_param_escape.clas.abap)
