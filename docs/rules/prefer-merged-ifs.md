---
description: "Merge consecutive nested IF blocks using boolean AND"
---

# Merge Nested IF Statements

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="warning" text="⚡ QuickFix Ready" />
  <Badge type="danger" text="#EC MERGE_IFS" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Merge consecutive nested IF blocks using boolean AND.

> **ATC Finding Messages:**
> - `Nested IF block can be merged with outer IF using AND`
> - `Nested IF in ELSE block can be changed to ELSEIF`

## Rationale

Consecutive nested `IF` statements without intermediate statements can be combined with `AND`. A nested `IF` that is the sole statement in an `ELSE` block can be converted to `ELSEIF`. Both reduce nesting depth, flatten control flow, and simplify cyclomatic complexity.

### Non-Compliant

```abap
IF is_connected( ).
  IF has_permission( ).
    execute( ).
  ENDIF.
ENDIF.
```

### Compliant

```abap
IF is_connected( ) AND has_permission( ).
  execute( ).
ENDIF.
```

## Automated QuickFix

This rule provides an **automated QuickFix** directly in Eclipse ABAP Development Tools (ADT):
1. Position the cursor on the flagged statement.
2. Press <kbd>Ctrl</kbd> + <kbd>1</kbd> (Quick Assist).
3. Select the automated refactoring to apply the clean syntax immediately.

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC MERGE_IFS

" SAP CI_ prefix format:
... "#EC CI_MERGE_IFS
```

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_PREF_MERGE_IFS`
* **Implementation File:** [zcl_skylint_pref_merge_ifs.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_pref_merge_ifs.clas.abap)
