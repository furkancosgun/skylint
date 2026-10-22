---
description: "Method name overwrites built-in SAP function"
---

# Avoid Method Names That Overwrite Built-in Functions

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="tip" text="Anti-Patterns & Bad Practices" />
  <Badge type="danger" text="#EC NO_OVERW_BUILTIN" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Method name overwrites built-in SAP function.

> **ATC Finding Message:** `Method name overwrites built-in SAP function name`

## Rationale

Naming a method after a built-in ABAP function (e.g., LINES, STRLEN, MATCHES, XSDBOOL) obscures the standard SAP built-in and makes expressions ambiguous and difficult to read.

### Non-Compliant

```abap
METHODS matches RETURNING VALUE(rv_res) TYPE abap_bool.
```

### Compliant

```abap
METHODS do_match RETURNING VALUE(rv_res) TYPE abap_bool.
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC NO_OVERW_BUILTIN

" SAP CI_ prefix format:
... "#EC CI_NO_OVERW_BUILTIN
```

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_NO_OVERW_BUILTIN`
* **Implementation File:** [zcl_skylint_no_overw_builtin.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_no_overw_builtin.clas.abap)
