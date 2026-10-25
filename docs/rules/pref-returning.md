---
title: "Prefer Functional RETURNING Parameters"
description: "Prefer Functional RETURNING Parameters - Clean ABAP guidelines, modern SAP syntax rules, and automated ATC code inspection for SAP S/4HANA and ABAP Cloud."
keywords: "Clean ABAP, SAP ATC Check, ABAP Cloud, S/4HANA Readiness, pref-returning, clean-abap"
---

# Prefer Functional RETURNING Parameters

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="danger" text="#EC PREF_RETURNING" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Prefer RETURNING over single EXPORTING.

> **ATC Finding Message:** `Prefer functional RETURNING parameter over single EXPORTING parameter`

## Rationale

A single EXPORTING parameter forces callers to declare a target and invoke the method as a statement. A RETURNING parameter makes the method usable directly in assignments, expressions, and assertions. Prefer RETURNING for value-producing methods and reserve EXPORTING for methods that genuinely return several outputs.

### Non-Compliant

```abap
METHODS get_total
  EXPORTING ev_total TYPE i.
```

### Compliant

```abap
METHODS get_total
  RETURNING VALUE(rv_total) TYPE i.
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC PREF_RETURNING

" SAP CI_ prefix format:
... "#EC CI_PREF_RETURNING
```

## References & Standards

* [Official SAP Clean ABAP Style Guide](https://github.com/SAP/styleguides/blob/main/clean-abap/CleanABAP.md)
* [SAP ABAP Keyword Documentation](https://help.sap.com/doc/abapdocu_cp_index_htm/CLOUD/en-US/index.htm)

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_PREF_RETURNING`
* **Implementation File:** [zcl_skylint_pref_returning.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_pref_returning.clas.abap)
