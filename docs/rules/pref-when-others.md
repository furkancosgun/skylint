---
title: "Require WHEN OTHERS as the Last Branch of CASE"
description: "Enforce a WHEN OTHERS fallback as the last branch of ABAP CASE statements to avoid silently ignored unexpected values."
keywords: "ABAP CASE WHEN OTHERS, default branch SAP, Clean ABAP CASE statement, SAP ATC check, unexpected value handling ABAP"
category: "clean-abap"
ruleId: "pref-when-others"
---

# Require WHEN OTHERS as the Last Branch of CASE

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="warning" text="QuickFix Ready" />
  <Badge type="danger" text="#EC PREF_WHEN_OTHERS" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Require WHEN OTHERS as the last CASE branch.

> **ATC Finding Messages:**
> - `CASE statement has no WHEN OTHERS fallback branch`
> - `WHEN OTHERS should be the last branch of the CASE statement`

## Rationale

A CASE statement without WHEN OTHERS silently ignores unexpected values, which turns enum or status changes into hard-to-find bugs. Adding WHEN OTHERS with a RAISE or a safe default makes the state machine total and documents the fallback. WHEN OTHERS should also be the last branch so that readers immediately see the default path instead of hunting for it between explicit branches.

### Non-Compliant

```abap
CASE lv_status.
  WHEN c_status-new.
    process_new( ).
  WHEN c_status-done.
    process_done( ).
ENDCASE.
```

### Compliant

```abap
CASE lv_status.
  WHEN c_status-new.
    process_new( ).
  WHEN c_status-done.
    process_done( ).
  WHEN OTHERS.
    RAISE EXCEPTION NEW zcx_illegal_status( ).
ENDCASE.
```

## Automated QuickFix

This rule provides an **automated QuickFix** directly in Eclipse ABAP Development Tools (ADT):
1. Position the cursor on the flagged statement.
2. Press <kbd>Ctrl</kbd> + <kbd>1</kbd> (Quick Assist).
3. Select the automated refactoring to apply the clean syntax immediately.

## Configuration & Thresholds

This check can be fine-tuned directly in the ATC Check Variant Editor (`CHKV`) in Eclipse ADT:

| Parameter Name | Data Type | Default Value | Description & Guidance |
|---|---|:---:|---|
| `MIN_BRANCHES` | `Integer` | <code>2</code> | Minimum number of explicit WHEN branches before WHEN OTHERS is required (default: 2) |
| `REQUIRE_LAST` | `Boolean` | <code>true</code> | Require WHEN OTHERS to be the final branch of the CASE statement (default: enabled) |

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC PREF_WHEN_OTHERS

" SAP CI_ prefix format:
... "#EC CI_PREF_WHEN_OTHERS
```


## Related Rules

* [Prefer CASE over Multiple IF / ELSEIF on the Same Variable](/rules/pref-case) — <code>#EC PREF_CASE</code>
* [Avoid CASE with a Single WHEN Branch](/rules/no-single-when) — <code>#EC NO_SINGLE_WHEN</code>
* [Avoid Empty Control Blocks](/rules/no-empty-block) — <code>#EC NO_EMPTY_BLOCK</code>

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_PREF_WHEN_OTHERS`
* **Implementation File:** [zcl_skylint_pref_when_others.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_pref_when_others.clas.abap)
