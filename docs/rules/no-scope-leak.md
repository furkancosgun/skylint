---
description: "Avoid variable usage outside its declaring control block"
---

# Avoid Variable Scope Leaking from Inner Blocks

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Anti-Patterns & Bad Practices" />
  <Badge type="danger" text="#EC SCOPE_LEAK" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Avoid variable usage outside its declaring control block.

> **ATC Finding Message:** `Variable declared in inner block is referenced outside its scope`

## Rationale

A variable declared inside an IF or LOOP block is still visible after the block ends, so using it later creates a hidden dependency on whether the branch executed. This makes behavior hard to reason about and can leave the variable uninitialized. Declare the variable in the enclosing scope and assign it explicitly inside the branch.

### Non-Compliant

```abap
IF is_valid( ).
  DATA(lv_message) = |Order { lv_id }|.
ENDIF.
log_message( lv_message ).
```

### Compliant

```abap
DATA lv_message TYPE string.
IF is_valid( ).
  lv_message = |Order { lv_id }|.
ENDIF.
log_message( lv_message ).
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC SCOPE_LEAK

" SAP CI_ prefix format:
... "#EC CI_SCOPE_LEAK
```

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_NO_SCOPE_LEAK`
* **Implementation File:** [zcl_skylint_no_scope_leak.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_no_scope_leak.clas.abap)
