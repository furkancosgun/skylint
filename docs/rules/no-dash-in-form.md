---
title: "Avoid Obsolete Dash (-) in Form Names"
description: "Avoid Obsolete Dash (-) in Form Names - Clean ABAP guidelines, modern SAP syntax rules, and automated ATC code inspection for SAP S/4HANA and ABAP Cloud."
keywords: "Clean ABAP, SAP ATC Check, ABAP Cloud, S/4HANA Readiness, no-dash-in-form, anti-patterns"
category: "anti-patterns"
ruleId: "no-dash-in-form"
---

# Avoid Obsolete Dash (-) in Form Names

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Anti-Patterns & Bad Practices" />
  <Badge type="warning" text="QuickFix Ready" />
  <Badge type="danger" text="#EC NO_DASH_IN_FORM" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

No Dashes in Form Names.

> **ATC Finding Message:** `Avoid dashes in FORM names`

## Rationale

A hyphen inside a form name is legacy ABAP and is easily confused with the component selector for structures. Use underscores in form names and reserve hyphens for component access.

### Non-Compliant

```abap
FORM check-auth.
ENDFORM.
```

### Compliant

```abap
FORM check_auth.
ENDFORM.
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
... "#EC NO_DASH_IN_FORM

" SAP CI_ prefix format:
... "#EC CI_NO_DASH_IN_FORM
```


## Related Rules

* [Avoid Obsolete Arithmetic and Assignment Statements](/rules/no-obs-arith) — <code>#EC NO_OBS_ARITH</code>
* [Avoid Obsolete Control Flow and Procedural Forms](/rules/no-obs-control) — <code>#EC NO_OBS_CONTROL</code>
* [Avoid Obsolete Declarations and Table Headers](/rules/no-obs-decl) — <code>#EC NO_OBS_DECL</code>

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_NO_DASH_IN_FORM`
* **Implementation File:** [zcl_skylint_no_dash_in_form.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_no_dash_in_form.clas.abap)
