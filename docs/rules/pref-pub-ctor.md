---
title: "Declare Constructor in PUBLIC SECTION"
description: "Declare Constructor in PUBLIC SECTION - Clean ABAP guidelines, modern SAP syntax rules, and automated ATC code inspection for SAP S/4HANA and ABAP Cloud."
keywords: "Clean ABAP, SAP ATC Check, ABAP Cloud, S/4HANA Readiness, pref-pub-ctor, clean-abap"
---

# Declare Constructor in PUBLIC SECTION

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="danger" text="#EC PREF_PUB_CTOR" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Declare Constructor in PUBLIC SECTION.

> **ATC Finding Message:** `Declare constructor in PUBLIC SECTION, even if class is CREATE PRIVATE`

## Rationale

Even when a class uses CREATE PRIVATE or CREATE PROTECTED, its instance constructor must be declared in the public section so the runtime and frameworks can instantiate it. Declaring the constructor privately makes reflection and framework integration harder. Keep the constructor in PUBLIC and control creation through the CREATE addition.

### Non-Compliant

```abap
CLASS zcl_order_service DEFINITION PUBLIC CREATE PRIVATE.
  PRIVATE SECTION.
    METHODS constructor.
ENDCLASS.
```

### Compliant

```abap
CLASS zcl_order_service DEFINITION PUBLIC CREATE PRIVATE.
  PUBLIC SECTION.
    METHODS constructor.
ENDCLASS.
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC PREF_PUB_CTOR

" SAP CI_ prefix format:
... "#EC CI_PREF_PUB_CTOR
```

## References & Standards

* [Official SAP Clean ABAP Style Guide](https://github.com/SAP/styleguides/blob/main/clean-abap/CleanABAP.md)
* [SAP ABAP Keyword Documentation](https://help.sap.com/doc/abapdocu_cp_index_htm/CLOUD/en-US/index.htm)

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_PREF_PUB_CTOR`
* **Implementation File:** [zcl_skylint_pref_pub_ctor.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_pref_pub_ctor.clas.abap)
