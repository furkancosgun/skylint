---
description: "Avoid MESSAGE ... RAISING; use class-based exceptions"
---

# Avoid Obsolete MESSAGE ... RAISING in Methods

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="tip" text="Anti-Patterns & Bad Practices" />
  <Badge type="danger" text="#EC MSG_RAISING" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Avoid MESSAGE ... RAISING; use class-based exceptions.

> **ATC Finding Message:** `Avoid obsolete MESSAGE ... RAISING; raise class-based exceptions`

## Rationale

`MESSAGE ... RAISING` combines procedural exception handling with UI messaging, preventing proper separation of concerns. Raise modern class-based exceptions instead.

### Non-Compliant

```abap
MESSAGE e001(zmsg) RAISING not_found.
```

### Compliant

```abap
RAISE EXCEPTION NEW cx_not_found( textid = cx_not_found=>c_item_missing ).
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC MSG_RAISING

" SAP CI_ prefix format:
... "#EC CI_MSG_RAISING
```

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_NO_MSG_RAISING`
* **Implementation File:** [zcl_skylint_no_msg_raising.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_no_msg_raising.clas.abap)
