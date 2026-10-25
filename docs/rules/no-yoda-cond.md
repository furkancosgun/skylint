---
description: "Avoid Yoda conditions in comparison expressions"
---

# Avoid Yoda Conditions

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Anti-Patterns & Bad Practices" />
  <Badge type="warning" text="QuickFix Ready" />
  <Badge type="danger" text="#EC YODA_COND" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Avoid Yoda conditions in comparison expressions.

> **ATC Finding Message:** `Avoid Yoda conditions; place variable before literal in comparison`

## Rationale

Yoda conditions place the literal or constant on the left side of a comparison and break the natural ABAP reading order of subject, operator, and value. The habit comes from languages where an accidental assignment in a condition is possible, which is not the case for ABAP comparisons. Keep the variable or expression on the left so conditions read like plain language.

### Non-Compliant

```abap
IF 'ACTIVE' = lv_status.
  process( ).
ENDIF.
```

### Compliant

```abap
IF lv_status = 'ACTIVE'.
  process( ).
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
... "#EC YODA_COND

" SAP CI_ prefix format:
... "#EC CI_YODA_COND
```

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_NO_YODA_COND`
* **Implementation File:** [zcl_skylint_no_yoda_cond.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_no_yoda_cond.clas.abap)
