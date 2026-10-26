---
title: "Prefer BETWEEN for Inclusive Range Checks"
description: "Simplify ABAP range checks from duplicated comparisons to the readable BETWEEN operator and avoid off-by-one mistakes."
keywords: "ABAP BETWEEN operator, range check ABAP, Clean ABAP condition simplification, SAP ATC check, off by one range ABAP"
category: "clean-abap"
ruleId: "pref-between"
---

# Prefer BETWEEN for Inclusive Range Checks

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="danger" text="#EC PREF_BETWEEN" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Prefer BETWEEN for inclusive range checks.

> **ATC Finding Message:** `Combine the duplicated range comparison with BETWEEN`

## Rationale

`lv_amount >= lv_min AND lv_amount <= lv_max` repeats the same operand and spells out a single inclusive range. `BETWEEN` expresses the intent directly, removes the duplicated operand and makes off-by-one mistakes easier to spot. The rule only reports inclusive `>=`/`<=` pairs by default; strict `>`/`<` pairs are optional because they are not semantically equivalent for fractional values.

### Non-Compliant

```abap
IF lv_amount >= lv_min AND lv_amount <= lv_max.
  approve( ).
ENDIF.
```

### Compliant

```abap
IF lv_amount BETWEEN lv_min AND lv_max.
  approve( ).
ENDIF.
```

## Configuration & Thresholds

This check can be fine-tuned directly in the ATC Check Variant Editor (`CHKV`) in Eclipse ADT:

| Parameter Name | Data Type | Default Value | Description & Guidance |
|---|---|:---:|---|
| `STRICT_RANGE` | `Boolean` | <code>false</code> | Also suggest BETWEEN for strict >/< pairs, which is not equivalent for decimals (default: disabled) |

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC PREF_BETWEEN

" SAP CI_ prefix format:
... "#EC CI_PREF_BETWEEN
```


## Related Rules

* [Limit Boolean Expression Complexity in Conditional Statements](/rules/max-bool-expr) — <code>#EC MAX_BOOL_EXPR</code>
* [Remove redundant parentheses](/rules/no-many-parens) — <code>#EC NO_MANY_PARENS</code>
* [Avoid Duplicate Branch Conditions](/rules/no-dup-cond) — <code>#EC NO_DUP_COND</code>

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_PREF_BETWEEN`
* **Implementation File:** [zcl_skylint_pref_between.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_pref_between.clas.abap)
