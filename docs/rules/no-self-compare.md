---
title: "Avoid Comparisons and Arithmetic with Identical Operands"
description: "Detect ABAP conditions and arithmetic where both operands resolve to the same symbol, a classic copy-paste defect that makes conditions meaningless."
keywords: "ABAP self comparison, identical operands check, Clean ABAP anti-pattern, SAP ATC check, copy paste bug ABAP"
category: "anti-patterns"
ruleId: "no-self-compare"
---

# Avoid Comparisons and Arithmetic with Identical Operands

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Anti-Patterns & Bad Practices" />
  <Badge type="danger" text="#EC NO_SELF_COMPARE" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Detect comparisons and arithmetic with identical operands.

> **ATC Finding Messages:**
> - `Both sides of the comparison resolve to the same symbol`
> - `Arithmetic operation uses the same symbol on both sides`

## Rationale

Comparing an expression with itself (`lv_status = lv_status`) always yields the same result, so the condition or assignment is meaningless and usually hides a copy-paste mistake. The same applies to arithmetic that always collapses to a constant (`lv_diff = lv_x - lv_x`). Operands are resolved through compiler symbols, so shadowed names and textually equal but different symbols are not confused. Statements with an AND/OR chain are left to no-dup-cond to avoid double findings.

### Non-Compliant

```abap
IF lv_status = lv_status.
  lv_count = lv_count + 1.
ENDIF.
lv_diff = lv_x - lv_x.
```

### Compliant

```abap
IF lv_status = c_status-done.
  lv_count = lv_count + 1.
ENDIF.
lv_diff = lv_x - lv_y.
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC NO_SELF_COMPARE

" SAP CI_ prefix format:
... "#EC CI_NO_SELF_COMPARE
```


## Related Rules

* [Avoid Dead Code with Constant Conditions](/rules/no-dead-code) — <code>#EC NO_DEAD_CODE</code>
* [Avoid Duplicate Branch Conditions](/rules/no-dup-cond) — <code>#EC NO_DUP_COND</code>
* [Remove Redundant Self-Assignments and Identity Moves](/rules/no-redun-assign) — <code>#EC NO_IDENTICAL_MOVE</code>

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_NO_SELF_COMPARE`
* **Implementation File:** [zcl_skylint_no_self_compare.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_no_self_compare.clas.abap)
