---
description: "Avoid MESSAGE ... RAISING; use class-based exceptions"
---

# Avoid Obsolete MESSAGE ... RAISING in Methods

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Anti-Patterns & Bad Practices" />
  <Badge type="danger" text="#EC MSG_RAISING" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Avoid MESSAGE ... RAISING; use class-based exceptions.

> **ATC Finding Message:** `Avoid obsolete MESSAGE ... RAISING; raise class-based exceptions`

## Rationale

MESSAGE ... RAISING mixes UI message output with exception propagation and depends on classic exception numbers. It separates poorly from business logic and is unsuitable for APIs that should return typed failures. Raise a class-based exception that references the message class text instead.

### Non-Compliant

```abap
MESSAGE e002(zorder) RAISING not_found.
```

### Compliant

```abap
RAISE EXCEPTION NEW cx_order_not_found( textid = cx_order_not_found=>c_order_missing ).
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
