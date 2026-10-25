---
title: "Avoid Local Variables Shadowing Class Attributes"
description: "Avoid Local Variables Shadowing Class Attributes - Clean ABAP guidelines, modern SAP syntax rules, and automated ATC code inspection for SAP S/4HANA and ABAP Cloud."
keywords: "Clean ABAP, SAP ATC Check, ABAP Cloud, S/4HANA Readiness, no-shadow, anti-patterns"
---

# Avoid Local Variables Shadowing Class Attributes

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Anti-Patterns & Bad Practices" />
  <Badge type="danger" text="#EC NO_SHADOW" />
  <Badge type="warning" text="Local Only" />
</div>

## Overview

Avoid local variables shadowing class attributes.

> **ATC Finding Message:** `Local variable shadows a class attribute; rename it`

## Rationale

A local variable that repeats a class attribute name silently hides the member inside the method. Readers can no longer tell whether the code changes the object state or only a temporary copy, and a later refactoring may keep the wrong reference. Rename the local or use a distinct name that states its purpose.

### Non-Compliant

```abap
DATA mv_status TYPE string.
mv_status = 'OPEN'.
```

### Compliant

```abap
DATA lv_status TYPE string.
lv_status = 'OPEN'.
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC NO_SHADOW

" SAP CI_ prefix format:
... "#EC CI_NO_SHADOW
```

## References & Standards

* [Official SAP Clean ABAP Style Guide](https://github.com/SAP/styleguides/blob/main/clean-abap/CleanABAP.md)
* [SAP ABAP Keyword Documentation](https://help.sap.com/doc/abapdocu_cp_index_htm/CLOUD/en-US/index.htm)

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_NO_SHADOW`
* **Implementation File:** [zcl_skylint_no_shadow.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_no_shadow.clas.abap)
