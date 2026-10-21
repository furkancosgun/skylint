---
description: "Avoid variable usage outside its declaring control block"
---

# Avoid Variable Scope Leaking from Inner Blocks

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="tip" text="Anti-Patterns & Bad Practices" />
  <Badge type="danger" text="#EC SCOPE_LEAK" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Avoid variable usage outside its declaring control block.

> **ATC Finding Message:** `Variable declared in inner block is referenced outside its scope`

## Rationale

In ABAP, variable declarations inside control blocks (`IF`, `LOOP`) have procedure-wide scope. Using an inner-declared variable outside its originating block creates confusing temporal dependencies.

### Non-Compliant

```abap
IF lv_condition = abap_true.
  DATA(lv_value) = 10.
ENDIF.
use_value( lv_value ). " Leaked outside block
```

### Compliant

```abap
DATA lv_value TYPE i.
IF lv_condition = abap_true.
  lv_value = 10.
ENDIF.
use_value( lv_value ).
```

## Transformation

```diff
- IF lv_condition = abap_true.
-   DATA(lv_value) = 10.
- ENDIF.
- use_value( lv_value ). " Leaked outside block
+ DATA lv_value TYPE i.
+ IF lv_condition = abap_true.
+   lv_value = 10.
+ ENDIF.
+ use_value( lv_value ).
```

## CLI & CI/CD Configuration

```yaml
checks:
  no-scope-leak:
    enabled: true
    severity: warning
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
