---
description: "No Dynamic Constructs (CALL, ASSIGN, CREATE, etc.)"
---

# Avoid Unnecessary Dynamic Programming Constructs

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Security & Robustness" />
  <Badge type="danger" text="#EC NO_DYNAMIC" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

No Dynamic Constructs (CALL, ASSIGN, CREATE, etc.).

> **ATC Finding Message:** `Avoid dynamic calls and language constructs`

## Rationale

Dynamic calls such as CALL FUNCTION lv_name, ASSIGN (lv_name), and CALL METHOD (lv_name) defer resolution to runtime. Compile-time checking is lost, refactoring cannot follow the call, and user-controlled input can become an injection vector. Prefer static calls and typed references, and sanitize any unavoidable dynamic access.

### Non-Compliant

```abap
CALL FUNCTION lv_function_name.
```

### Compliant

```abap
CALL FUNCTION 'BAPI_USER_GET_DETAIL'.
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC NO_DYNAMIC

" SAP CI_ prefix format:
... "#EC CI_NO_DYNAMIC
```

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_NO_DYNAMIC_STMT`
* **Implementation File:** [zcl_skylint_no_dynamic_stmt.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_no_dynamic_stmt.clas.abap)
