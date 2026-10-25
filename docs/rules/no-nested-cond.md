---
title: "Avoid Nested COND or SWITCH Expressions"
description: "Avoid Nested COND or SWITCH Expressions - Clean ABAP guidelines, modern SAP syntax rules, and automated ATC code inspection for SAP S/4HANA and ABAP Cloud."
keywords: "Clean ABAP, SAP ATC Check, ABAP Cloud, S/4HANA Readiness, no-nested-cond, clean-abap"
category: "clean-abap"
ruleId: "no-nested-cond"
---

# Avoid Nested COND or SWITCH Expressions

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="danger" text="#EC NO_NESTED_COND" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Avoid Nested COND or SWITCH Expressions.

> **ATC Finding Message:** `Avoid nesting COND or SWITCH expressions inside each other`

## Rationale

Nesting COND or SWITCH constructor expressions inside each other creates deeply indented, hard-to-read expression trees. Modern Clean ABAP guidelines explicitly recommend avoiding nested constructor expressions; instead, separate complex decision branches into focused helper methods or classic CASE constructs.

### Non-Compliant

```abap
lv_val = COND #( WHEN cond1 THEN COND #( WHEN cond2 THEN 'A' ELSE 'B' ) ELSE 'C' ).
```

### Compliant

```abap
lv_val = COND #( WHEN cond1 AND cond2 THEN 'A'
                 WHEN cond1           THEN 'B'
                 ELSE                      'C' ).
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC NO_NESTED_COND

" SAP CI_ prefix format:
... "#EC CI_NO_NESTED_COND
```


## Related Rules

* [Prefer COND #( ) Expression over IF/ELSEIF/ELSE](/rules/pref-cond) — <code>#EC PREF_COND</code>
* [Prefer SWITCH #( ) Expression over CASE Statement](/rules/pref-switch) — <code>#EC PREF_SWITCH</code>
* [Limit Control Flow Nesting Depth (Guard Clause Enforcement)](/rules/max-nesting) — <code>#EC MAX_NESTING</code>

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_NO_NESTED_COND`
* **Implementation File:** [zcl_skylint_no_nested_cond.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_no_nested_cond.clas.abap)
