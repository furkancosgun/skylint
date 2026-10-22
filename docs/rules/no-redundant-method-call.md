---
description: "Omit redundant EXPORTING and RECEIVING in method calls"
---

# Omit Redundant Call Syntax (EXPORTING / RECEIVING / Single Param)

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="tip" text="Anti-Patterns & Bad Practices" />
  <Badge type="warning" text="⚡ QuickFix Ready" />
  <Badge type="danger" text="#EC EXPORTING" />
  <Badge type="warning" text="Local Only" />
</div>

## Overview

Omit redundant EXPORTING and RECEIVING in method calls.

> **ATC Finding Messages:**
> - `Omit explicit EXPORTING keyword in method invocation`
> - `Omit RECEIVING keyword; use functional call or omit parameter`
> - `Omit explicit parameter name in single parameter method call`

## Rationale

Modern ABAP allows omitting the `EXPORTING` and `RECEIVING` keywords in functional method calls. Furthermore, when calling a method with a single importing parameter, the parameter name can be omitted entirely to make code clean and concise.

### Non-Compliant

```abap
lo_calc->compute( EXPORTING iv_val = 10 ).
```

### Compliant

```abap
lo_calc->compute( 10 ).
```

## Transformation

```diff
- lo_calc->compute( EXPORTING iv_val = 10 ).
+ lo_calc->compute( 10 ).
```

## Automated QuickFix

This rule provides an **automated QuickFix** directly in Eclipse ABAP Development Tools (ADT):
1. Position the cursor on the flagged statement.
2. Press <kbd>Ctrl</kbd> + <kbd>1</kbd> (Quick Assist).
3. Select the automated refactoring to apply the clean syntax immediately.

## Configuration & Thresholds

This check can be fine-tuned directly in the ATC Check Variant Editor (`CHKV`) in Eclipse ADT:

| Parameter Name | Data Type | Default Value |
|---|---|:---:|
| `CHECK_EXPORTING` | `Boolean` | <code>true</code> |
| `CHECK_RECEIVING` | `Boolean` | <code>true</code> |
| `CHECK_PARAM_NAME` | `Boolean` | <code>true</code> |

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC EXPORTING

" SAP CI_ prefix format:
... "#EC CI_EXPORTING
```

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_NO_REDUNDANT_CALL`
* **Implementation File:** [zcl_skylint_no_redundant_call.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_no_redundant_call.clas.abap)
