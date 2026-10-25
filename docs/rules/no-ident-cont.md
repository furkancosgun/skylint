---
title: "Avoid Identical Statements in IF Branches"
description: "Avoid Identical Statements in IF Branches - Clean ABAP guidelines, modern SAP syntax rules, and automated ATC code inspection for SAP S/4HANA and ABAP Cloud."
keywords: "Clean ABAP, SAP ATC Check, ABAP Cloud, S/4HANA Readiness, no-ident-cont, anti-patterns"
category: "anti-patterns"
ruleId: "no-ident-cont"
---

# Avoid Identical Statements in IF Branches

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Anti-Patterns & Bad Practices" />
  <Badge type="danger" text="#EC NO_IDENT_CONT" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Avoid identical code in IF and ELSE branches.

> **ATC Finding Message:** `Identical statement in IF and ELSE branches; extract common code`

## Rationale

Statements repeated in every branch of an IF/ELSEIF/ELSE carry no branch-specific meaning and duplicate maintenance. If the same statement starts or ends every branch, extract it before or after the IF so it is written once and stays in sync.

### Non-Compliant

```abap
IF lv_is_active = abap_true.
  process( ).
ELSE.
  process( ).
ENDIF.
```

### Compliant

```abap
IF lv_is_active = abap_true.
  process_active( ).
ELSE.
  process_inactive( ).
ENDIF.
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC NO_IDENT_CONT

" SAP CI_ prefix format:
... "#EC CI_NO_IDENT_CONT
```


## Related Rules

* [Avoid CASE with a Single WHEN Branch](/rules/no-single-when) — <code>#EC NO_SINGLE_WHEN</code>
* [Avoid CHECK Statements](/rules/no-check-stmt) — <code>#EC NO_CHECK_IN_LOOP</code>
* [Avoid Comparing to abap_true / abap_false](/rules/no-bool-compare) — <code>#EC NO_BOOL_COMPARE</code>

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_NO_IDENT_CONT`
* **Implementation File:** [zcl_skylint_no_ident_cont.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_no_ident_cont.clas.abap)
