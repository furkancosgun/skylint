---
description: "No Dashes in Form Names"
---

# Avoid Obsolete Dash (-) in Form Names

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Anti-Patterns & Bad Practices" />
  <Badge type="danger" text="#EC NO_DASH" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

No Dashes in Form Names.

> **ATC Finding Message:** `Avoid dashes in FORM names`

## Rationale

A hyphen inside a form name is legacy ABAP and is easily confused with the component selector for structures. Use underscores in form names and reserve hyphens for component access.

### Non-Compliant

```abap
FORM check-auth.
ENDFORM.
```

### Compliant

```abap
FORM check_auth.
ENDFORM.
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

* **Native ATC Class:** `ZCL_SKYLINT_NO_DASH_IN_FORM`
* **Implementation File:** [zcl_skylint_no_dash_in_form.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_no_dash_in_form.clas.abap)
