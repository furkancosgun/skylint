---
title: "Prefer Modern Class-Based APIs over Obsolete Function Modules"
description: "Prefer Modern Class-Based APIs over Obsolete Function Modules - Clean ABAP guidelines, modern SAP syntax rules, and automated ATC code inspection for SAP S/4HANA and ABAP Cloud."
keywords: "Clean ABAP, SAP ATC Check, ABAP Cloud, S/4HANA Readiness, pref-func-module, clean-abap"
category: "clean-abap"
ruleId: "pref-func-module"
---

# Prefer Modern Class-Based APIs over Obsolete Function Modules

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="danger" text="#EC PREF_FUNC_MOD" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Prefer class-based APIs over obsolete function modules.

> **ATC Finding Message:** `Use modern class-based API instead of obsolete function module`

## Rationale

Classic function modules are non-object-oriented procedural constructs. Modern ABAP provides robust, object-oriented class libraries (such as CL_SYSTEM_UUID, CL_ABAP_TSTMP, CL_ABAP_MESSAGE_DIGEST, and CL_BCS) that improve testability, type safety, and ABAP Cloud compatibility. Prefer recommended class-based APIs over obsolete function modules.

### Non-Compliant

```abap
CALL FUNCTION 'GUID_CREATE'
  IMPORTING
    ev_guid_32 = lv_guid.
```

### Compliant

```abap
lv_guid = cl_system_uuid=>create_uuid_c32_static( ).
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC PREF_FUNC_MOD

" SAP CI_ prefix format:
... "#EC CI_PREF_FUNC_MOD
```


## Related Rules

* [Avoid Obsolete CALL METHOD](/rules/no-call-method) — <code>#EC NO_CALL_METHOD</code>
* [Prefer Class-Based Exceptions over Classic EXCEPTIONS](/rules/pref-class-exc) — <code>#EC PREF_CLASS_EXC</code>
* [Avoid Obsolete Control Flow and Procedural Forms](/rules/no-obs-control) — <code>#EC NO_OBS_CONTROL</code>

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_PREF_FUNC_MODULE`
* **Implementation File:** [zcl_skylint_pref_func_module.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_pref_func_module.clas.abap)
