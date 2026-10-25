---
title: "Avoid Purely Static Utility Classes"
description: "Avoid Purely Static Utility Classes - Clean ABAP guidelines, modern SAP syntax rules, and automated ATC code inspection for SAP S/4HANA and ABAP Cloud."
keywords: "Clean ABAP, SAP ATC Check, ABAP Cloud, S/4HANA Readiness, no-static-cls, anti-patterns"
category: "anti-patterns"
ruleId: "no-static-cls"
---

# Avoid Purely Static Utility Classes

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Anti-Patterns & Bad Practices" />
  <Badge type="danger" text="#EC NO_STATIC_CLS" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Avoid static-only classes; use instantiable classes.

> **ATC Finding Message:** `Avoid static-only classes; declare instance methods and interfaces`

## Rationale

A class made only of static methods cannot be mocked through an interface, so every caller is tightly coupled to the implementation. Static state also leaks between tests and makes behavior order-dependent. Inject an instance through an interface and use instance methods instead.

### Non-Compliant

```abap
CLASS cl_math_util DEFINITION PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    CLASS-METHODS add IMPORTING a TYPE i b TYPE i RETURNING VALUE(r) TYPE i.
    CLASS-METHODS sub IMPORTING a TYPE i b TYPE i RETURNING VALUE(r) TYPE i.
ENDCLASS.
```

### Compliant

```abap
CLASS cl_math_util DEFINITION PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    INTERFACES if_math_util.
ENDCLASS.
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC NO_STATIC_CLS

" SAP CI_ prefix format:
... "#EC CI_NO_STATIC_CLS
```

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_NO_STATIC_CLS`
* **Implementation File:** [zcl_skylint_no_static_cls.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_no_static_cls.clas.abap)
