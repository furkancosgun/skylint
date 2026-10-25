---
title: "Avoid Method Names That Overwrite Built-in Functions"
description: "Avoid Method Names That Overwrite Built-in Functions - Clean ABAP guidelines, modern SAP syntax rules, and automated ATC code inspection for SAP S/4HANA and ABAP Cloud."
keywords: "Clean ABAP, SAP ATC Check, ABAP Cloud, S/4HANA Readiness, no-overw-builtin, anti-patterns"
---

# Avoid Method Names That Overwrite Built-in Functions

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Anti-Patterns & Bad Practices" />
  <Badge type="danger" text="#EC NO_OVERW_BUILTIN" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Method name overwrites built-in SAP function.

> **ATC Finding Message:** `Method name overwrites built-in SAP function name`

## Rationale

Naming a method LINES, STRLEN, or XSDBOOL shadows a well-known built-in and makes the call site ambiguous. Readers cannot tell whether the built-in or the method is intended. Use a descriptive verb that does not collide with language functions.

### Non-Compliant

```abap
METHODS matches
  RETURNING VALUE(rv_result) TYPE abap_bool.
```

### Compliant

```abap
METHODS matches_pattern
  RETURNING VALUE(rv_result) TYPE abap_bool.
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
