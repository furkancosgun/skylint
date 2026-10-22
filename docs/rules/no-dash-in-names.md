---
description: "No Dashes in Variable and Form Names"
---

# Avoid Obsolete Dash (-) in Program Identifiers

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Anti-Patterns & Bad Practices" />
  <Badge type="danger" text="#EC NO_DASH" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

No Dashes in Variable and Form Names.

> **ATC Finding Message:** `Avoid dashes in variable, constant, and field-symbol names`

## Rationale

A hyphen inside an identifier is legacy ABAP and is easily confused with the component selector for structures. It also complicates searching, refactoring, and tooling that treats the name as an expression. Use underscores in identifier names and reserve hyphens for component access.

### Non-Compliant

```abap
DATA customer-name TYPE string.
```

### Compliant

```abap
DATA customer_name TYPE string.
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC NO_DASH

" SAP CI_ prefix format:
... "#EC CI_NO_DASH
```

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_NO_DASH_IN_NAMES`
* **Implementation File:** [zcl_skylint_no_dash_in_names.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_no_dash_in_names.clas.abap)
