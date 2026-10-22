---
description: "Avoid COMMIT and ROLLBACK in application logic"
---

# Avoid Explicit COMMIT WORK in Business Logic

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Security & Robustness" />
  <Badge type="danger" text="#EC COMMIT_WORK" />
  <Badge type="warning" text="Local Only" />
</div>

## Overview

Avoid COMMIT and ROLLBACK in application logic.

> **ATC Finding Message:** `Avoid COMMIT/ROLLBACK WORK; transactional control belongs to framework`

## Rationale

COMMIT WORK inside business logic ends the SAP LUW at an arbitrary point, so later failures cannot roll back earlier changes. Frameworks such as RAP manage the save sequence and commit for you. Let the framework commit and keep the business logic transactional.

### Non-Compliant

```abap
METHOD save_order.
  UPDATE zorder SET status = @lv_status WHERE order_id = @lv_id.
  COMMIT WORK.
ENDMETHOD.
```

### Compliant

```abap
METHOD save_order.
  UPDATE zorder SET status = @lv_status WHERE order_id = @lv_id.
ENDMETHOD.
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC COMMIT_WORK

" SAP CI_ prefix format:
... "#EC CI_COMMIT_WORK
```

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_NO_COMMIT_WORK`
* **Implementation File:** [zcl_skylint_no_commit_work.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_no_commit_work.clas.abap)
