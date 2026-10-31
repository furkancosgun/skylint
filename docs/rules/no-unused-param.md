---
title: "Avoid Unused Parameters in Procedures"
description: "Detect unused parameters in ABAP methods, forms, and functions to keep procedure signatures clean and unambiguous."
keywords: "ABAP unused parameter, Clean ABAP parameters, SAP ATC check unused parameter, no-unused-param"
category: "clean-abap"
ruleId: "no-unused-param"
---

# Avoid Unused Parameters in Procedures

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="danger" text="#EC NO_UNUSED_PARAM" />
  <Badge type="warning" text="Local Only" />
</div>

## Overview

Avoid unused parameters in procedures.

> **ATC Finding Message:** `Parameter(s) &1 never used in procedure`

## Rationale

Methods, form routines, and function modules should not declare parameters that are never accessed or assigned in their implementation. Unused parameters clutter the signature, confuse callers, and may indicate incomplete implementations. If a parameter is intentionally unused, prefix its name with an underscore.

### Non-Compliant

```abap
METHOD do_work IMPORTING iv_used TYPE i iv_unused TYPE string.
  DATA lv_val TYPE i.
  lv_val = iv_used.
ENDMETHOD.
```

### Compliant

```abap
METHOD do_work IMPORTING iv_used TYPE i.
  DATA lv_val TYPE i.
  lv_val = iv_used.
ENDMETHOD.
```

## Configuration & Thresholds

This check can be fine-tuned directly in the ATC Check Variant Editor (`CHKV`) in Eclipse ADT:

| Parameter Name | Data Type | Default Value | Description & Guidance |
|---|---|:---:|---|
| `CHECK_METHODS` | `Boolean` | <code>true</code> | Check method procedures for unused parameters (defaults to true) |
| `CHECK_FORMS` | `Boolean` | <code>true</code> | Check form routines for unused parameters (defaults to true) |
| `CHECK_FUNCS` | `Boolean` | <code>true</code> | Check function modules for unused parameters (defaults to true) |

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC NO_UNUSED_PARAM

" SAP CI_ prefix format:
... "#EC CI_NO_UNUSED_PARAM
```


## Related Rules

* [Eliminate Unused Local Variables and Symbols](/rules/no-unused-vars) — <code>#EC NO_UNUSED_VARS</code>
* [Avoid Dead Code with Constant Conditions](/rules/no-dead-code) — <code>#EC NO_DEAD_CODE</code>

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_NO_UNUSED_PARAM`
* **Implementation File:** [zcl_skylint_no_unused_param.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_no_unused_param.clas.abap)
