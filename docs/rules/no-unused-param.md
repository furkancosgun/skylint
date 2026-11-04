---
title: "Avoid Unused Parameters in Procedures"
description: "Avoid Unused Parameters in Procedures - Clean ABAP guidelines, modern SAP syntax rules, and automated ATC code inspection for SAP S/4HANA and ABAP Cloud."
keywords: "Clean ABAP, SAP ATC Check, ABAP Cloud, S/4HANA Readiness, no-unused-param, clean-abap"
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

* [Method Call Parameter Naming Style (Omit or Require)](/rules/pref-param-name) — <code>#EC PREF_PARAM_NAME</code>
* [Limit Method Parameter Count and Require Multi-Line Signatures](/rules/max-params) — <code>#EC MAX_PARAMS_COUNT</code>
* [Eliminate Unused Local Variables and Symbols](/rules/no-unused-vars) — <code>#EC NO_UNUSED_VARS</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_NO_UNUSED_PARAM`
* **Implementation File:** [#skyl#cl_no_unused_param.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_no_unused_param.clas.abap)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_NO_UNUSED_PARAM&title=%5BBug%5D%3A%20Issue%20in%20no-unused-param)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20no-unused-param)**
