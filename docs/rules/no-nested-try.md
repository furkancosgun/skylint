---
title: "Avoid Deeply Nested TRY ... CATCH Blocks"
description: "Avoid Deeply Nested TRY ... CATCH Blocks - Clean ABAP guidelines, modern SAP syntax rules, and automated ATC code inspection for SAP S/4HANA and ABAP Cloud."
keywords: "Clean ABAP, SAP ATC Check, ABAP Cloud, S/4HANA Readiness, no-nested-try, anti-patterns"
category: "anti-patterns"
ruleId: "no-nested-try"
---

# Avoid Deeply Nested TRY ... CATCH Blocks

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Anti-Patterns & Bad Practices" />
  <Badge type="danger" text="#EC NO_NESTED_TRY" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Avoid nested TRY blocks; extract to helper methods.

> **ATC Finding Message:** `Avoid nested TRY blocks; extract to dedicated method`

## Rationale

A TRY block inside another TRY block makes it unclear which handler owns which failure and often duplicates cleanup logic. The inner operation should have its own exception contract behind a method boundary. Extract it into a focused helper and keep one TRY per responsibility.

### Non-Compliant

```abap
TRY.
  step1( ).
  TRY.
    step2( ).
  CATCH cx_step2_error.
    handle_step2( ).
  ENDTRY.
CATCH cx_step1_error.
  handle_step1( ).
ENDTRY.
```

### Compliant

```abap
TRY.
  step1( ).
  execute_step2( ).
CATCH cx_step1_error.
  handle_step1( ).
ENDTRY.
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC NO_NESTED_TRY

" SAP CI_ prefix format:
... "#EC CI_NO_NESTED_TRY
```

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_NO_NESTED_TRY`
* **Implementation File:** [zcl_skylint_no_nested_try.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_no_nested_try.clas.abap)
