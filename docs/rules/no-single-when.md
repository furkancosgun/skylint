---
title: "Avoid CASE with a Single WHEN Branch"
description: "Avoid CASE with a Single WHEN Branch - Clean ABAP guidelines, modern SAP syntax rules, and automated ATC code inspection for SAP S/4HANA and ABAP Cloud."
keywords: "Clean ABAP, SAP ATC Check, ABAP Cloud, S/4HANA Readiness, no-single-when, anti-patterns"
category: "anti-patterns"
ruleId: "no-single-when"
---

# Avoid CASE with a Single WHEN Branch

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Anti-Patterns & Bad Practices" />
  <Badge type="danger" text="#EC NO_SINGLE_WHEN" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Avoid CASE statements with only one WHEN branch.

> **ATC Finding Message:** `CASE statement has <= 1 WHEN branch; prefer IF`

## Rationale

CASE implies that a value is compared against several alternatives, so a single WHEN makes readers look for missing branches. An IF with the same condition is shorter and states the intent directly. Use CASE only when there are multiple distinct branches or when a value mapping is genuinely clearer.

### Non-Compliant

```abap
CASE lv_order_status.
  WHEN 'C'.
    close_order( ).
ENDCASE.
```

### Compliant

```abap
IF lv_order_status = 'C'.
  close_order( ).
ENDIF.
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC NO_SINGLE_WHEN

" SAP CI_ prefix format:
... "#EC CI_NO_SINGLE_WHEN
```


## Related Rules

* [Avoid Duplicate Branch Conditions](/rules/no-dup-cond) — <code>#EC NO_DUP_COND</code>
* [Prefer CASE over Multiple IF / ELSEIF on the Same Variable](/rules/pref-case) — <code>#EC PREF_CASE</code>
* [Prefer SWITCH #( ) Expression over CASE Statement](/rules/pref-switch) — <code>#EC PREF_SWITCH</code>

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_NO_SINGLE_WHEN`
* **Implementation File:** [zcl_skylint_no_single_when.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_no_single_when.clas.abap)
