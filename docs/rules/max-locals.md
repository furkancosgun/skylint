---
title: "Limit Local Variable Count per Method"
description: "Count local DATA, FIELD-SYMBOLS and inline declarations per ABAP method and flag procedures that carry too much local state."
keywords: "ABAP too many locals, method local variables metric, Clean ABAP method size, SAP ATC metrics check, inline declaration count ABAP"
category: "metrics"
ruleId: "max-locals"
---

# Limit Local Variable Count per Method

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Metrics & Complexity Limits" />
  <Badge type="danger" text="#EC MAX_LOCALS" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Limit local variable count per procedure.

> **ATC Finding Message:** `Procedure declares too many local symbols`

## Rationale

A method with many local variables usually does several unrelated things at once and is hard to unit test. The count includes DATA, FIELD-SYMBOLS, STATICS and CONSTANTS declarations as well as inline `DATA(...)` and `FIELD-SYMBOL(...)` definitions, because each declared symbol is another piece of state a reader must track. Extract cohesive blocks into helper methods or introduce a dedicated result structure.

### Non-Compliant

```abap
METHOD process.
  DATA lv_a TYPE i.
  DATA lv_b TYPE i.
  DATA lv_c TYPE i.
  DATA lv_d TYPE i.
  DATA lv_e TYPE i.
ENDMETHOD.
```

### Compliant

```abap
METHOD process.
  DATA ls_totals TYPE ty_totals.
  ls_totals = calculate_totals( ).
  persist_totals( ls_totals ).
ENDMETHOD.
```

## Configuration & Thresholds

This check can be fine-tuned directly in the ATC Check Variant Editor (`CHKV`) in Eclipse ADT:

| Parameter Name | Data Type | Default Value | Description & Guidance |
|---|---|:---:|---|
| `MAX_LOCALS` | `Integer` | <code>15</code> | Maximum allowed number of local declarations per procedure (default: 15) |

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC MAX_LOCALS

" SAP CI_ prefix format:
... "#EC CI_MAX_LOCALS
```


## Related Rules

* [Eliminate Unused Local Variables and Symbols](/rules/no-unused-vars) — <code>#EC NO_UNUSED_VARS</code>
* [Limit Class Member Attribute Count (Prevent God Classes)](/rules/max-attributes) — <code>#EC MAX_ATTRIBUTES</code>
* [Limit Method and Constructor Statement Length](/rules/max-method-len) — <code>#EC MAX_METHOD_LEN</code>

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_MAX_LOCALS`
* **Implementation File:** [zcl_skylint_max_locals.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_max_locals.clas.abap)
