---
title: "Avoid Concrete Class References in Interfaces"
description: "Prevent interfaces from referencing concrete classes via RTTI inspection."
keywords: "Clean ABAP, interface class reference, no-intf-class-ref"
category: "clean-abap"
ruleId: "no-intf-class-ref"
---

# Avoid Concrete Class References in Interfaces

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="danger" text="#EC NO_INTF_CLASS_REF" />
  <Badge type="warning" text="Local Only" />
</div>

## Overview

Interfaces should not reference concrete classes.

> **ATC Finding Message:** `Interface references concrete class; use an interface reference instead`

## Rationale

Interfaces should adhere to the Dependency Inversion Principle and not couple directly to concrete class implementations. Use interface references instead.

### Non-Compliant

```abap
INTERFACE lif_demo.
  DATA mo_obj TYPE REF TO cl_concrete.
ENDINTERFACE.
```

### Compliant

```abap
INTERFACE lif_demo.
  DATA mo_obj TYPE REF TO if_contract.
ENDINTERFACE.
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC NO_INTF_CLASS_REF

" SAP CI_ prefix format:
... "#EC CI_NO_INTF_CLASS_REF
```


## Related Rules

* [Prefer Interface Segregation (Small, Focused Interfaces)](/rules/pref-intf-segreg) — <code>#EC PREF_INTF_SEGREG</code>
* [Avoid Exposed Mutable Data in Classes and Interfaces](/rules/no-exposed-data) — <code>#EC PUBLIC_ATTR</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_NO_INTF_CLASS_REF`
* **Implementation File:** [#skyl#cl_no_intf_class_ref.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_no_intf_class_ref.clas.abap)
