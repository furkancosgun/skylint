---
description: "Avoid duplicate branch conditions in IF and CASE"
---

# Avoid Duplicate Branch Conditions

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Anti-Patterns & Bad Practices" />
  <Badge type="danger" text="#EC DUP_COND" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Avoid duplicate branch conditions in IF and CASE.

> **ATC Finding Message:** `Identical condition in branch; duplicate branch is unreachable`

## Rationale

A repeated IF/ELSEIF or WHEN condition can never be reached because the earlier branch already handles it. This is usually a copy-paste error and can leave the intended branch permanently dead. Remove the duplicate or correct the condition so every branch has a distinct purpose.

### Non-Compliant

```abap
IF lv_status = 'A'.
  process_a( ).
ELSEIF lv_status = 'A'.
  process_b( ).
ENDIF.
```

### Compliant

```abap
IF lv_status = 'A'.
  process_a( ).
ELSEIF lv_status = 'B'.
  process_b( ).
ENDIF.
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC DUP_COND

" SAP CI_ prefix format:
... "#EC CI_DUP_COND
```

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_NO_DUP_COND`
* **Implementation File:** [zcl_skylint_no_dup_cond.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_no_dup_cond.clas.abap)
