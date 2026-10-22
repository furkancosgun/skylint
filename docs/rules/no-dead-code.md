---
description: "Detect Dead Code with Constant Condition"
---

# Avoid Dead Code with Constant Conditions

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="tip" text="Anti-Patterns & Bad Practices" />
  <Badge type="warning" text="⚡ QuickFix Ready" />
  <Badge type="danger" text="#EC NO_DEAD_CODE" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Detect Dead Code with Constant Condition.

> **ATC Finding Message:** `Condition is always false, creating dead code`

## Rationale

Conditional branches with constant expressions such as 1 = 2 or abap_false can never be executed, creating dead code that clutters the program and misleads maintainers.

### Non-Compliant

```abap
IF 1 = 2.
  DATA lv_dead TYPE i.
ENDIF.
```

### Compliant

```abap
IF lv_condition = abap_true.
  DATA lv_active TYPE i.
ENDIF.
```

## Transformation

```diff
- IF 1 = 2.
-   DATA lv_dead TYPE i.
- ENDIF.
+ IF lv_condition = abap_true.
+   DATA lv_active TYPE i.
+ ENDIF.
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
... "#EC NO_DEAD_CODE

" SAP CI_ prefix format:
... "#EC CI_NO_DEAD_CODE
```

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_NO_DEAD_CODE`
* **Implementation File:** [zcl_skylint_no_dead_code.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_no_dead_code.clas.abap)
