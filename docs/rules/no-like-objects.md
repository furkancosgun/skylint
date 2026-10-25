---
title: "Avoid LIKE Typing on Global Dictionary Objects"
description: "Avoid LIKE Typing on Global Dictionary Objects - Clean ABAP guidelines, modern SAP syntax rules, and automated ATC code inspection for SAP S/4HANA and ABAP Cloud."
keywords: "Clean ABAP, SAP ATC Check, ABAP Cloud, S/4HANA Readiness, no-like-objects, anti-patterns"
---

# Avoid LIKE Typing on Global Dictionary Objects

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Anti-Patterns & Bad Practices" />
  <Badge type="danger" text="#EC NO_LIKE_OBJECTS" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Avoid LIKE referencing data objects; use explicit TYPE.

> **ATC Finding Message:** `Avoid LIKE for data declarations; specify TYPE explicitly`

## Rationale

LIKE copies the type of a data object, which couples the new declaration to an implementation detail rather than to a type contract. For Dictionary objects, TYPE references the type directly and stays stable when the referenced object changes. Use LIKE only for local data objects whose type is intentionally shared.

### Non-Compliant

```abap
DATA lv_material LIKE mara-matnr.
```

### Compliant

```abap
DATA lv_material TYPE mara-matnr.
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC NO_LIKE_OBJECTS

" SAP CI_ prefix format:
... "#EC CI_NO_LIKE_OBJECTS
```

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_NO_LIKE_OBJECTS`
* **Implementation File:** [zcl_skylint_no_like_objects.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_no_like_objects.clas.abap)
