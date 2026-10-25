---
title: "Do Not Mix RETURNING with EXPORTING or CHANGING"
description: "Do Not Mix RETURNING with EXPORTING or CHANGING - Clean ABAP guidelines, modern SAP syntax rules, and automated ATC code inspection for SAP S/4HANA and ABAP Cloud."
keywords: "Clean ABAP, SAP ATC Check, ABAP Cloud, S/4HANA Readiness, no-mix-returning, anti-patterns"
---

# Do Not Mix RETURNING with EXPORTING or CHANGING

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Anti-Patterns & Bad Practices" />
  <Badge type="danger" text="#EC NO_MIX_RETURNING" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Do not mix RETURNING with EXPORTING or CHANGING.

> **ATC Finding Message:** `Do not mix RETURNING with EXPORTING or CHANGING parameters in a single method`

## Rationale

A method that returns a value and also exports or changes parameters has a mixed contract: callers must capture the result and provide extra targets. This complicates expression use and suggests the method does more than one thing. Split it into a functional query and a separate command.

### Non-Compliant

```abap
METHODS get_data
  EXPORTING ev_count TYPE i
  RETURNING VALUE(rv_result) TYPE string.
```

### Compliant

```abap
METHODS get_data
  RETURNING VALUE(rv_result) TYPE string.
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC NO_MIX_RETURNING

" SAP CI_ prefix format:
... "#EC CI_NO_MIX_RETURNING
```

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_NO_MIX_RETURNING`
* **Implementation File:** [zcl_skylint_no_mix_returning.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_no_mix_returning.clas.abap)
