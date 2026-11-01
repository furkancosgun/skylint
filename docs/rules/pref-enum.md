---
title: "Prefer Enumerations over Constants"
description: "Prefer ABAP 7.51+ ENUM definitions over structured constants for value sets."
keywords: "Clean ABAP, ENUM, constants, pref-enum"
category: "clean-abap"
ruleId: "pref-enum"
---

# Prefer Enumerations over Constants

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="danger" text="#EC PREF_ENUM" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Prefer ENUM over CONSTANTS for set of related values.

> **ATC Finding Message:** `Prefer ENUM over CONSTANTS for set of related values`

## Rationale

Use TYPES: BEGIN OF ENUM ... END OF ENUM for related discrete value sets instead of structured CONSTANTS for type safety and modern syntax.

### Non-Compliant

```abap
CONSTANTS:
  BEGIN OF c_status,
    open TYPE string VALUE 'O',
  END OF c_status.
```

### Compliant

```abap
TYPES:
  BEGIN OF ENUM ty_status,
    open,
  END OF ENUM ty_status.
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC PREF_ENUM

" SAP CI_ prefix format:
... "#EC CI_PREF_ENUM
```


## Related Rules

* [Avoid Magic Numbers; Use Named Constants](/rules/no-magic-numbers) — <code>#EC NO_MAGIC_NUMBERS</code>
* [Avoid Hardcoding System & Tenant Environment Checks (sy-sysid, sy-mandt)](/rules/no-hardcoded-env) — <code>#EC NO_HARDCODED_ENV</code>

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_PREF_ENUM`
* **Implementation File:** [zcl_skylint_pref_enum.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_pref_enum.clas.abap)
