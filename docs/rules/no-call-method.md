---
title: "Avoid Obsolete CALL METHOD"
description: "Avoid Obsolete CALL METHOD - Clean ABAP guidelines, modern SAP syntax rules, and automated ATC code inspection for SAP S/4HANA and ABAP Cloud."
keywords: "Clean ABAP, SAP ATC Check, ABAP Cloud, S/4HANA Readiness, no-call-method, anti-patterns"
category: "anti-patterns"
ruleId: "no-call-method"
---

# Avoid Obsolete CALL METHOD

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Anti-Patterns & Bad Practices" />
  <Badge type="warning" text="QuickFix Ready" />
  <Badge type="danger" text="#EC NO_CALL_METHOD" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Avoid static CALL METHOD statements.

> **ATC Finding Message:** `Avoid static CALL METHOD; use functional method call instead`

## Rationale

CALL METHOD is the procedural call syntax from early ABAP Objects and needs explicit EXPORTING and RECEIVING sections. Functional syntax is shorter, can be used inside expressions, and removes visual clutter around parameter lists. Use ref->method( ) or class=>method( ) for all method calls.

### Non-Compliant

```abap
CALL METHOD lo_service->calculate_tax
  EXPORTING
    iv_amount = lv_amount
  RECEIVING
    rv_tax    = lv_tax.
```

### Compliant

```abap
lv_tax = lo_service->calculate_tax( lv_amount ).
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
... "#EC NO_CALL_METHOD

" SAP CI_ prefix format:
... "#EC CI_NO_CALL_METHOD
```


## Related Rules

* [Omit Redundant EXPORTING in Method Calls](/rules/no-call-exporting) — <code>#EC NO_CALL_EXPORTING</code>
* [Omit RECEIVING in Method Invocations](/rules/no-call-receiving) — <code>#EC NO_CALL_RECEIVING</code>
* [Avoid Redundant ME-> Self Reference](/rules/no-me-reference) — <code>#EC NO_ME_REFERENCE</code>

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_NO_CALL_METHOD`
* **Implementation File:** [zcl_skylint_no_call_method.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_no_call_method.clas.abap)
