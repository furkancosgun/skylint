---
description: "Detect unused local variables and field symbols"
---

# Eliminate Unused Local Variables and Symbols

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Anti-Patterns & Bad Practices" />
  <Badge type="danger" text="#EC NEEDED" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Detect unused local variables and field symbols.

> **ATC Finding Message:** `Local variable or field symbol is declared but never read`

## Rationale

An unused variable or field symbol adds noise and suggests incomplete refactoring or a missing assignment. It keeps dead objects alive longer than necessary and makes reviews harder. Remove the declaration, or mark it with ##NEEDED when an external contract requires it.

### Non-Compliant

```abap
DATA lv_message TYPE string.
process_order( ).
```

### Compliant

```abap
DATA lv_message TYPE string.
lv_message = |Order { lv_id }|.
log_message( lv_message ).
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC NEEDED

" SAP CI_ prefix format:
... "#EC CI_NEEDED
```

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_NO_UNUSED_VARS`
* **Implementation File:** [zcl_skylint_no_unused_vars.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_no_unused_vars.clas.abap)
