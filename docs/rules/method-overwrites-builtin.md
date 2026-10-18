# Avoid Method Names That Overwrite Built-in Functions

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="tip" text="naming" />
  <Badge type="danger" text="Finding: BUILTIN" />
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

## Transformation

```diff
- METHODS matches RETURNING VALUE(rv_res) TYPE abap_bool.
+ METHODS do_match RETURNING VALUE(rv_res) TYPE abap_bool.
```

## CLI & CI/CD Configuration

```yaml
checks:
  method-overwrites-builtin:
    enabled: true
    severity: warning
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
* **Finding Code:** `BUILTIN`
* **Implementation File:** [zcl_skylint_no_overw_builtin.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_no_overw_builtin.clas.abap)
