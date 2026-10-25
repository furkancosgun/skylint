---
title: "Method Call Parameter Naming Style (Omit or Require)"
description: "Method Call Parameter Naming Style (Omit or Require) - Clean ABAP guidelines, modern SAP syntax rules, and automated ATC code inspection for SAP S/4HANA and ABAP Cloud."
keywords: "Clean ABAP, SAP ATC Check, ABAP Cloud, S/4HANA Readiness, pref-param-name, clean-abap"
category: "clean-abap"
ruleId: "pref-param-name"
---

# Method Call Parameter Naming Style (Omit or Require)

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="warning" text="QuickFix Ready" />
  <Badge type="danger" text="#EC PREF_PARAM_NAME" />
  <Badge type="warning" text="Local Only" />
</div>

## Overview

Method Call Parameter Naming Style.

> **ATC Finding Messages:**
> - `Omit explicit parameter name in single parameter method call`
> - `Add explicit parameter name to positional method call`

## Rationale

Methods with a single importing parameter can be invoked positionally without naming the parameter, reducing verbosity for self-explanatory methods. Alternatively, teams requiring explicit naming can enable REQUIRE_PARAM_NAME to enforce explicit parameter naming for clarity and future signature extension.

### Non-Compliant

```abap
lo_pricing->apply_discount( iv_percent = 10 ).
```

### Compliant

```abap
lo_pricing->apply_discount( 10 ).
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
| `CHECK_PARAM_NAME` | `Boolean` | <code>true</code> | Suggest omitting parameter name when invoking single-parameter methods |
| `REQUIRE_PARAM_NAME` | `Boolean` | <code>false</code> | Require explicit parameter names when calling multi-parameter methods |

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC PREF_PARAM_NAME

" SAP CI_ prefix format:
... "#EC CI_PREF_PARAM_NAME
```

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_PREF_PARAM_NAME`
* **Implementation File:** [zcl_skylint_pref_param_name.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_pref_param_name.clas.abap)
